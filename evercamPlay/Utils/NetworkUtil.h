//
//  NetworkUtil.h
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUtil : NSObject

+ (NSString *)getNetworkString;
BOOL isPortReachable(NSString *url, NSInteger port);

@end
