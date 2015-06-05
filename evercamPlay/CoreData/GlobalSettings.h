
#import <Foundation/Foundation.h>

@interface GlobalSettings : NSObject
+(GlobalSettings *)sharedInstance;

@property (nonatomic) BOOL isPhone;

@end
