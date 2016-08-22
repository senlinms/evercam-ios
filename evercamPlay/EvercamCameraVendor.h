//
//  EvercamCameraVendor.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/1/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamCameraVendor : NSObject

//pass Mac Address of device and get details
-(void)getVendorName:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block;

@end
