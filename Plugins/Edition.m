#import "ZipArchive/ZipArchive.h"
#import "Edition.h"


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
    
    // allocate a memory pool for our NSString Objects
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString* issueName = [arguments objectAtIndex:2];
    
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://173.230.134.125/%@.zip", issueName]]];
    [data writeToFile: [NSString stringWithFormat:@"./%@.zip", issueName] atomically:NO];
    
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile: [NSString stringWithFormat:@"./%@.zip", issueName]]) {
        BOOL ret = [za UnzipFileTo: @"./editions" overWrite: YES];
        if (NO == ret){} [za UnzipCloseFile];
    }

	[self writeJavascript: [NSString stringWithFormat:@"%@(\"Successfully retrieved issue: %@\");", self.successCallback, issueName]];
    
    [za release];
    [pool release];
}

@end



