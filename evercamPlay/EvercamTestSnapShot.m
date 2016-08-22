//
//  EvercamTestSnapShot.m
//  evercamPlay
//
//  Created by NainAwan on 15/04/2016.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamTestSnapShot.h"
#import "EvercamApiUtility.h"
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif
@implementation EvercamTestSnapShot

-(void)testSnapShot:(NSDictionary *)parameterDictionary withBlock:(void (^) (UIImage *snapeImage,NSString *statusMessage,NSError *error))block{
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:parameterDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/test",KBASEURL];
        
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"POST"];
        
        [request setHTTPBody:putData];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            if ([response statusCode] == 200){
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                NSRange stringRange = [responseDictionary[@"data"] rangeOfString:@"data:image/jpeg;base64,"];
                UIImage *test_Snap_Image;
                if(stringRange.location != NSNotFound){
                    NSString *imageString = [responseDictionary[@"data"] stringByReplacingOccurrencesOfString:@"data:image/jpeg;base64," withString:@""];
                    NSData *data = [[NSData alloc]initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    test_Snap_Image = [UIImage imageWithData:data];
                }
                if (block) {
                    block(test_Snap_Image,@"Success",nil);
                }
            }else{
                [APIUtility createErrorFromApi:responseData withStatusCode:[response statusCode] withBlock:^(NSError *error) {
                    if (block) {
                        block(nil,nil,error);
                    }
                }];
            }
        }else{
            if (block) {
                block(nil,nil,error);
            }
        }
    });
    
    
}
@end
