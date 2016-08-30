//
//  EvercamRefreshCamera.h
//  evercamPlay
//
//  Created by Zulqarnain on 8/30/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamRefreshCamera : NSObject

-(void)refreshOfflineCamera:(NSDictionary *)parameterDictionary withBlock:(void(^)(id details,NSError *error))block;

@end
