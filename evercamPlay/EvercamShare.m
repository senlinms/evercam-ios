//
//  EvercamShare.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/10/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamShare.h"
#import "EvercamApiUtility.h"
@implementation EvercamShare

-(void)getCameraShareDetails:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block{
    
    NSString *cameraId  = parameterDictionary[@"camId"];
    NSString *api_id    = parameterDictionary[@"api_id"];
    NSString *api_key   = parameterDictionary[@"api_Key"];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"GET"];
        
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

-(void)updateUserRights:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block{
    
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    BOOL isPendingUser              = [parameterDictionary[@"isPending"] boolValue];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *jsonUrlString;
        if (isPendingUser) {
            jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares/requests?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        }else{
            jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        }
        
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

-(void)New_Resend_CameraShare:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    BOOL isPendingUser              = [parameterDictionary[@"isPending"] boolValue];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString;
        if (isPendingUser) {
            jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares/requests?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        }else{
            jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        }
        
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


-(void)deleteCameraShare:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    
    NSString *cameraId      = parameterDictionary[@"camId"];
    NSString *api_id        = parameterDictionary[@"api_id"];
    NSString *api_key       = parameterDictionary[@"api_Key"];
    NSString *userEmail     = parameterDictionary[@"user_Email"];
    BOOL isPendingRequest   = [parameterDictionary[@"isPending"] boolValue];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString;
        if (isPendingRequest) {
            jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares/requests?email=%@&api_id=%@&api_key=%@",KBASEURL,cameraId,userEmail,api_id,api_key];
        }else{
            jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares?email=%@&api_id=%@&api_key=%@",KBASEURL,cameraId,userEmail,api_id,api_key];
        }
        
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"DELETE"];
        
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

-(void)changeCameraStatus:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    
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

-(void)getCameraPendingRequest:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSString *cameraId  = parameterDictionary[@"camId"];
    NSString *api_id    = parameterDictionary[@"api_id"];
    NSString *api_key   = parameterDictionary[@"api_Key"];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@/shares/requests?status=PENDING&api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"GET"];
        
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

-(void)transferCameraOwner:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block{
    NSString *cameraId              = parameterDictionary[@"camId"];
    NSString *api_id                = parameterDictionary[@"api_id"];
    NSString *api_key               = parameterDictionary[@"api_Key"];
    NSDictionary *postDictionary    = parameterDictionary[@"Post_Param"];
    
    NSData *putData         = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *jsonUrlString = [NSString stringWithFormat:@"%@cameras/%@?api_id=%@&api_key=%@",KBASEURL,cameraId,api_id,api_key];
        NSMutableURLRequest *request = [APIUtility createRequestWithUrl:jsonUrlString withType:@"PUT"];
        
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
