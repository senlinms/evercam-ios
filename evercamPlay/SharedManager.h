//
//  SharedManager.h
//  evercamPlay
//
//  Created by Vocal Matrix on 26/10/2015.
//  Copyright © 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedManager : NSObject

+(void)get:(NSString*)url params:(NSDictionary*)params callback:(void (^)(NSString* status, NSMutableDictionary* responseObject))callback;

@end
