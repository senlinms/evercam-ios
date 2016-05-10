//
//
//  Utility
//
//  Created by Zulqarnain on 12/4/12.
//  Copyright (c) 2012 Zulqarnain Mustafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#define AppUtility [EvercamUtility sharedLRUtility]
#define MainWindow [[[UIApplication sharedApplication] delegate] window]
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define KUSERDEFAULTS [NSUserDefaults standardUserDefaults]

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface EvercamUtility : NSObject{
}

+(EvercamUtility *)sharedLRUtility;
-(void)displayAlertWithTitle:(NSString *)title AndMessage:(NSString *)msg;
-(BOOL)InternetReachable;
-(UIColor *)colorWithHexString:(NSString *)stringToConvert;
- (NSString *)encodeToBase64String:(UIImage *)image;
//________________________________________


@end

static inline BOOL isCompletelyEmpty (id text) {
    BOOL isBlank;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        isBlank = YES;
    }else{
        isBlank = NO;
    }
    
    return isBlank;
}


static inline BOOL isEmpty(id thing) {
    return thing == nil
    || [thing isMemberOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


static inline BOOL isEmail(id email)
{
    NSString *strEmailMatchstring=@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strEmailMatchstring];
    if(!isEmpty(email) && [regExPredicate evaluateWithObject:email])
        return YES;
    else
        return NO;
}