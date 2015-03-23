//
//  EvercamCamera.h
//  evercamPlay
//
//  Created by jw on 3/22/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamCamera : NSObject

+ (void) getByUrl:(NSString*) url Parameters:(NSDictionary *) parameters WithBlock:(void (^)(NSArray *cameras, NSError *error))block;

@end
