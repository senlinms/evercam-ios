//
//  EvercamPtzControls.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamPtzControls : NSObject


//set camera to Home
-(void)ptz_Home:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;


//set camera Directions
-(void)set_CameraDirection:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

//get Preset list
-(void)getPresetList:(NSDictionary *)parameterDictionary withBlock:(void (^)(id details,NSError *error))block;

//set camera direction to the selected preset
-(void)setPreset:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

//create new preset
-(void)createPreset:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;
@end
