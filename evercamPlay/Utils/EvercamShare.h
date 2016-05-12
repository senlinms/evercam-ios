//
//  EvercamShare.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/10/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KBASEURL @"https://api.evercam.io/v1/"
@interface EvercamShare : NSObject{
    
}

+(void)getCameraShareDetails:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block;

+(void)updateUserRights:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block;

+(void)deleteCameraShare:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;
+(void)New_Resend_CameraShare:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

+(void)changeCameraStatus:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

+(void)getCameraPendingRequest:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

@end
