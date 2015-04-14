//
//  NetworkUtil.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "NetworkUtil.h"
#import "Reachability.h"

@implementation NetworkUtil

+ (NSString *)getNetworkString {
    NetworkStatus networkStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) {
        return @"WiFi";
    } else if (networkStatus == ReachableViaWWAN) {
        return @"3G";
    } else {
        return @"";
    }
}

@end
