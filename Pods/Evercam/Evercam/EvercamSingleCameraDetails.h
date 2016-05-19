//
//  EvercamSingleCameraDetails.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/12/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KBASEURL @"https://api.evercam.io/v1/"

@interface EvercamSingleCameraDetails : NSObject

+(void)getCameraDetails:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block;

@end
