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
    if ([fileManager removeItemAtPath:editionDirectoryPath error:&error]) {
        NSLog(@"Deleted edition directory at: %@", editionDirectoryPath);
    }
    
    if(![fileManager createDirectoryAtPath:editionDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]){
        NSLog(@"Could not create edition directory: %@ error: \r\n%@", editionDirectoryPath, error);
    }
    
    NSURL *srcURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://173.230.134.125/%@.zip", issueName]];
    NSURL *destinationURL = [NSURL fileURLWithPath: editionZipFilePath];
    
    error = nil;
    if ([fileManager removeItemAtURL:destinationURL error:&error]) {
        NSLog(@"Deleted file at: %@", destinationURL);
    }
    
    NSData *data = [NSData dataWithContentsOfURL: srcURL];
    if (![fileManager createFileAtPath:editionZipFilePath contents:data attributes:nil]) {
        NSLog(@"Could not create zip file at: %@", editionZipFilePath);
    } else {
        NSLog(@"Created zip file at: %@", editionZipFilePath);
        
    }
    
    NSLog(@"Unzip");
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:editionZipFilePath mode:ZipFileModeUnzip];
    NSArray *infos= [unzipFile listFileInZipInfos];
    for (FileInZipInfo *info in infos) {
        
        NSRange range = [info.name rangeOfString:@"__MACOSX" options:NSCaseInsensitiveSearch];
        if( range.location != NSNotFound ) {
            continue;
        }
        
        // Locate the file in the zip
        [unzipFile locateFileInZip:info.name];
        
        NSString *itemFilePath = [NSString stringWithFormat:@"%@/%@", editionDirectoryPath, info.name];
        
        if([itemFilePath hasSuffix:@"/"]){
            error = nil;
            NSLog(@"Create item directory: %@", itemFilePath);
            if(![fileManager createDirectoryAtPath:itemFilePath withIntermediateDirectories:YES attributes:nil error:&error]){
                NSLog(@"Could not create item directory: %@ error: \r\n%@", itemFilePath, error);
            }
            continue;
        } else if(![fileManager createFileAtPath:itemFilePath contents:nil attributes:nil]) {
            NSLog(@"Could not create content file at: %@", itemFilePath);
        }
        
        // Expand the file in memory
        ZipReadStream *read= [unzipFile readCurrentFileInZip];
        int bufferLength = 20480;
        NSMutableData *buffer= [[NSMutableData alloc] initWithLength:bufferLength];
        NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:itemFilePath];
        
        // Read-then-write buffered loop
        do {
            
            // Reset buffer length
            [buffer setLength:bufferLength];
            
            // Expand next chunk of bytes
            int bytesRead= [read readDataWithBuffer:buffer];
            if (bytesRead > 0) {
                // Write what we have read
                [buffer setLength:bytesRead];
                [file writeData:buffer];
                
            } else
                break;
            
        } while (YES);
         
         [file closeFile];
        
        [read finishedReading];
        [buffer release];
        
        if(![fileManager fileExistsAtPath: itemFilePath]) {
            NSLog(@"File does not exist! File path: %@", itemFilePath);
        }
        
        if(![fileManager isReadableFileAtPath: itemFilePath]) {
            NSLog(@"File is not readable! File path: %@", itemFilePath);
        }
        
    }
    
    [unzipFile close];
    [unzipFile release];
    
    error = nil;
    if ([fileManager removeItemAtPath:editionZipFilePath error:&error]) {
        NSLog(@"Deleted edition zip file at: %@", editionDirectoryPath);
    }
    
    
    NSString *editionIndexPath = [NSString stringWithFormat:@"%@/%@.html", editionDirectoryPath, issueName];
    [self writeJavascript: [NSString stringWithFormat:@"%@(\"%@\");", self.successCallback, editionIndexPath]];
}

@end



