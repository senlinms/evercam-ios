//
//  SharedManager.m
//  evercamPlay
//
//  Created by Musaab Qamar on 26/10/2015.
//  Copyright © 2015 Evercam. All rights reserved.
//

#import "SharedManager.h"
#import "AFNetworking.h"
#import "EvercamShell.h"
#import "AppDelegate.h"

@implementation SharedManager

+(NSString*)getCheckPortUrl
{
    return @"https://media.evercam.io/v1/cameras/port-check?";
}

+(NSString*)getIPUrl
{
    return @"http://ipinfo.io/ip";
}

+(void)get:(NSString*)url params:(NSDictionary*)params callback:(void (^)(NSString* status, NSMutableDictionary* responseObject))callback
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSMutableDictionary* dict = [NSMutableDictionary new];
        
        NSError* error = nil;
        NSArray *arrayJson = [NSArray arrayWithObjects:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error],nil];
        if(error){
            error = nil;
            NSDictionary *dictJson = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            if(error){
                NSString* newStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                [dict setObject:newStr forKey:@"JSON"];
                
            }
            else {
                [dict setObject:dictJson forKey:@"JSON"];
            }
        }
        else {
            [dict setObject:arrayJson forKey:@"JSON"];
        }
        
        callback(@"success", dict);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setObject:[error userInfo] forKey:@"JSON"];
        callback(@"error", dict);
    }];
}

@end
