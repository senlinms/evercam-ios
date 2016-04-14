//
//  CommonUtil.h
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

+ (NSString *)uuidString;
+ (NSArray *)snapshotFiles:(NSString *)cameraId;

@end
