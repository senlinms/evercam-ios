//
//  SharedManager.h
//  evercamPlay
//
//  Created by Vocal Matrix on 26/10/2015.
//  Copyright © 2015 Evercam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedManager : NSObject

+(NSString*)getCheckPortUrl;
+(NSString*)getIPUrl;

+(void)get:(NSString*)url params:(NSDictionary*)params callback:(void (^)(NSString* status, NSMutableDictionary* responseObject))callback;

@end
