//
//  EvercamCameraModelInfo.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KBASEURL @"https://api.evercam.io/v1/"
@interface EvercamCameraModelInfo : NSObject

//Get camera model details
+(void)getCameraModelInformation:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block;
@end
