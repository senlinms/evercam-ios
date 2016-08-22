//
//  EvercamCreateCamera.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/13/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamCreateCamera.h"
#import "EvercamApiUtility.h"
@implementation EvercamCreateCamera

-(void)createCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras?api_id=%@&api_key=%@",KBASEURL,api_id,api_key];
        
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"POST"];
        
        [request setHTTPBody:putData];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            if ([response statusCode] == 201 || [response statusCode] == 200){
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                if (block) {
                    block(responseDictionary,nil);
                }
            }else {
                [APIUtility createErrorFromApi:responseData withStatusCode:[response statusCode] withBlock:^(NSError *error) {
                    if (block) {
                        block(nil,error);
                    }
                }];
            }
        }else{
            if (block) {
                block(nil,error);
            }
        }
    });
}

-(void)EditCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"PATCH"];
        
        [request setHTTPBody:putData];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            if ([response statusCode] == 200){
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                if (block) {
                    block(responseDictionary,nil);
                }
            }else{
                [APIUtility createErrorFromApi:responseData withStatusCode:[response statusCode] withBlock:^(NSError *error) {
                    if (block) {
                        block(nil,error);
                    }
                }];
            }
        }else{
            if (block) {
                block(nil,error);
            }
        }
    });
}

@end
