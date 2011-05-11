//#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"

@interface Edition : PhoneGapCommand {
    NSString* successCallback;
	NSString* failCallback;
}

@property (nonatomic, copy) NSString* successCallback;
@property (nonatomic, copy) NSString* failCallback;

-(void) download:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
@end