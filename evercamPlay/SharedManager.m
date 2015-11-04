//
//  SharedManager.m
//  evercamPlay
//
//  Created by Vocal Matrix on 26/10/2015.
//  Copyright © 2015 evercom. All rights reserved.
//

#import "SharedManager.h"
#import "AFHTTPRequestOperationManager.h"


@implementation SharedManager


+(void)get:(NSString*)url params:(NSDictionary*)params callback:(void (^)(NSString* status, NSMutableDictionary* responseObject))callback
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setObject:[error userInfo] forKey:@"JSON"];
        callback(@"error", dict);
    }];    
}


@end
