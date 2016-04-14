//
//  PreferenceUtil.h
//  evercamPlay
//
//  Created by jw on 4/11/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceUtil : NSObject

+(NSInteger) getCameraPerRow;
+(void) setCameraPerRow:(NSInteger)cameraPerRow;
+(NSInteger) getSleepTimerSecs;
+(void) setSleepTimerSecs:(NSInteger)secs;
+(BOOL) isForceLandscape;
+(void) setIsForceLandscape:(BOOL)val;

+(BOOL) isShowOfflineCameras;
+(void) setIsShowOfflineCameras:(BOOL)val;
@end
