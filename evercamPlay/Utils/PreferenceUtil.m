//
//  PreferenceUtil.m
//  evercamPlay
//
//  Created by jw on 4/11/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "PreferenceUtil.h"

#define CAMERA_PER_ROW_KEY @"cameraPerRow"
#define SLEEP_TIME_SECS @"sleepTime"
#define FORCE_LANDSCAPE @"forceLandscape"

@implementation PreferenceUtil

+(NSInteger) getCameraPerRow {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger cameraPerRow = [userDefaults integerForKey:CAMERA_PER_ROW_KEY];
    if (cameraPerRow == 0) {
        return 2;
    }
    return cameraPerRow;
}

+(void) setCameraPerRow:(NSInteger)cameraPerRow {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:cameraPerRow forKey:CAMERA_PER_ROW_KEY];
    [userDefaults synchronize];
}

+(NSInteger) getSleepTimerSecs {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:SLEEP_TIME_SECS];
}

+(void) setSleepTimerSecs:(NSInteger)secs {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:secs forKey:SLEEP_TIME_SECS];
    [userDefaults synchronize];

}

+(BOOL) isForceLandscape {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:FORCE_LANDSCAPE];
}

+(void) setIsForceLandscape:(BOOL)val {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:val forKey:FORCE_LANDSCAPE];
    [userDefaults synchronize];
}


@end
