//
//  EvercamPtzControls.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamPtzControls.h"

@implementation EvercamPtzControls


+(void)ptz_Home:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/ptz/home?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod: @"POST"];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
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


+(void)set_CameraDirection:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSString *direction             = parameterDictionary[@"camera_Direction"];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/ptz/relative?%@&api_id=%@&api_key=%@",KBASEURL,cameraId,direction,api_id,api_key];
        
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod: @"POST"];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
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

+(void)getPresetList:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block{
    
    NSString *cameraId  = parameterDictionary[@"camId"];
    NSString *api_id    = parameterDictionary[@"api_id"];
    NSString *api_key   = parameterDictionary[@"api_Key"];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/ptz/presets?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod: @"GET"];
        
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


+(void)setPreset:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSString *presetToken           = parameterDictionary[@"token"];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/ptz/presets/go/%@?api_id=%@&api_key=%@",KBASEURL,cameraId,presetToken,api_id,api_key];
        
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod: @"POST"];
        
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
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

@end
