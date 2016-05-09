//
//  EvercamTestSnapShot.m
//  evercamPlay
//
//  Created by NainAwan on 15/04/2016.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamTestSnapShot.h"
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif
@implementation EvercamTestSnapShot

+(void)testSnapShot:(NSDictionary *)parameterDictionary withBlock:(void (^) (UIImage *snapeImage,NSString *statusMessage,NSError *error))block{
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:parameterDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = @"https://media.evercam.io/v1/cameras/test";
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPMethod: @"POST"];
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
                if (block) {
                    block(nil,@"Failed",nil);
                }
            }
        }else{
            if (block) {
                block(nil,nil,error);
            }
        }
    });
    
    
}
@end
