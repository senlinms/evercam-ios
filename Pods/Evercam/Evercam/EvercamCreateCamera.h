//
//  EvercamCreateCamera.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/13/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamCreateCamera : NSObject

+(void)createCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

+(void)EditCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

@end
