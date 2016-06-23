//
//  EvercamCreateCamera.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/13/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamCreateCamera.h"
#import "EvercamConstant.h"
@implementation EvercamCreateCamera

+(void)createCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras?api_id=%@&api_key=%@",KBASEURL,api_id,api_key];
        
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody:putData];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            if ([response statusCode] == 201){
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                if (block) {
                    block(responseDictionary,nil);
                }
            }else if ([response statusCode] == 409){
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                NSError *customError = [NSError errorWithDomain:@"api.evercam.io" code:[response statusCode] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:responseDictionary[@"message"],@"Error_Server", nil]];
                if (block) {
                    block(nil,customError);
                }
            }else{
                NSError *customError = [NSError errorWithDomain:@"api.evercam.io" code:[response statusCode] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Error detail unavailable",@"Error_Description", nil]];
                if (block) {
                    block(nil,customError);
                }
            }
        }else{
            if (block) {
                block(nil,error);
            }
        }
    });
}

+(void)EditCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod: @"PATCH"];
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
                NSError *customError = [NSError errorWithDomain:@"api.evercam.io" code:[response statusCode] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Error detail unavailable",@"Error_Description", nil]];
                if (block) {
                    block(nil,customError);
                }
            }
        }else{
            if (block) {
                block(nil,error);
            }
        }
    });
}

@end
