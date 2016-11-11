//
//
//  Utility
//
//  Created by Zulqarnain on 12/4/12.
//  Copyright (c) 2012 Zulqarnain. All rights reserved.
//

#import "EvercamUtility.h"
#import "Reachability.h"

#import "Reachability.h"
@interface EvercamUtility() {
    
    
}
@end

@implementation EvercamUtility
@synthesize isFullyDismiss,isFromScannedScreen;
+(EvercamUtility *)sharedLRUtility
{
    static EvercamUtility *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EvercamUtility alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(EvercamUtility *)init
{
    NSLog(@"LRUtility Init Called");
    if ((self = [super init])) {
        
        
        
    }
    return self;
}

-(void)displayAlertWithTitle:(NSString *)title AndMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(BOOL)InternetReachable{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status != NotReachable)
    {
        return YES;
    }
    [self displayAlertWithTitle:@"No internet connection found" AndMessage:@"Please check your internet connection"];
    return NO;
}

-(UIColor *)colorWithHexString:(NSString *)stringToConvert{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


-(NSString *)getCameraRights:(NSString *)rights{
    NSString *userRights = @"";
    if ([rights rangeOfString:@"edit" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        userRights = @"Full Rights";
    }else{
        userRights = @"Read Only";
    }
    return userRights;
}
@end
