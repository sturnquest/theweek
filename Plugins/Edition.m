#import "Edition.h"
#import "Objective-Zip/ZipFile.h"
#import "Objective-Zip/ZipException.h"
#import "Objective-Zip/FileInZipInfo.h"
#import "Objective-Zip/ZipWriteStream.h"
#import "Objective-Zip/ZipReadStream.h"


@implementation Edition

@synthesize successCallback, failCallback;

-(void) download:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    NSUInteger argc = [arguments count];
    
	if(argc < 2) {
		return;	
	}
    
	self.successCallback = [arguments objectAtIndex:0];
	self.failCallback = [arguments objectAtIndex:1];
    
    if(argc < 3) {
		[self writeJavascript: [NSString stringWithFormat:@"%@(\"Argument error\");", self.failCallback]];
		return;
	}
    
    NSString* issueName = [arguments objectAtIndex:2];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *editionsDirectory = [NSString stringWithFormat:@"%@/editions", [paths objectAtIndex:0]];
    NSLog(@"Editions directory: %@", editionsDirectory);
    NSString *editionZipFilePath = [NSString stringWithFormat:@"%@/%@.zip", editionsDirectory, issueName];
    NSString *editionDirectoryPath = [NSString stringWithFormat:@"%@/%@", editionsDirectory, issueName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:editionsDirectory withIntermediateDirectories:YES attributes:nil error:&error]){
        NSLog(@"Could not create directory: %@ error: \r\n%@", editionsDirectory, error);
    }
    
    error = nil;
    NSDictionary *permissions = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"one", [NSNumber numberWithInt: 1],
                                @"two", [NSNumber numberWithInt: 2],
                                @"three", [NSNumber numberWithInt: 3],
                                nil];
    if(![fileManager createDirectoryAtPath:editionDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]){
        NSLog(@"Could not create edition directory: %@ error: \r\n%@", editionDirectoryPath, error);
    }
    
    NSURL *srcURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://173.230.134.125/%@.zip", issueName]];
    NSURL *destinationURL = [NSURL fileURLWithPath: editionZipFilePath];
    
    NSLog(@"Copy from: %@ to: %@", srcURL, destinationURL);
    
    error = nil;
    if (![fileManager copyItemAtURL:srcURL toURL:destinationURL error:&error]) {
        NSLog(@"Could not copy zip file to: %@ error: \r\n%@", destinationURL, error);
    }
    
    NSLog(@"Unzip");
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:editionZipFilePath mode:ZipFileModeUnzip];
    NSArray *infos= [unzipFile listFileInZipInfos];
    for (FileInZipInfo *info in infos) {
        NSLog(@"Zip file info: %@ %@ %d (%d)", info.name, info.date, info.size, info.level);
        
        // Locate the file in the zip
        [unzipFile locateFileInZip:info.name];
        
        // Expand the file in memory
        ZipReadStream *read= [unzipFile readCurrentFileInZip];
        NSMutableData *buffer= [[NSMutableData alloc] initWithLength:256];
        NSString *itemFilePath = [NSString stringWithFormat:@"%@/%@", editionDirectoryPath, info.name];
        NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:itemFilePath];
        
        // Read-then-write buffered loop
        do {
            
            // Reset buffer length
            [buffer setLength:256];
            
            // Expand next chunk of bytes
            int bytesRead= [read readDataWithBuffer:buffer];
            if (bytesRead > 0) {
                // Write what we have read
                [buffer setLength:bytesRead];
                [file writeData:buffer];
                
            } else
                break;
            
        } while (YES);
        
        [read finishedReading];
        [file closeFile];
        [buffer release];
        
        if(![fileManager isReadableFileAtPath: itemFilePath]) {
            NSLog(@"File is not readable! File path: %@", itemFilePath);
        }
        
    }

	[self writeJavascript: [NSString stringWithFormat:@"%@(\"Successfully retrieved issue: %@\");", self.successCallback, issueName]];
    
    [unzipFile close];
    [unzipFile release];
}

@end



