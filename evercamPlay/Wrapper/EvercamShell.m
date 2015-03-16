//
//  EvercamShell.m
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamShell.h"
#import "EvercamApiKeyPair.h"
#import "EvercamUser.h"
#import "AFEvercamAPIClient.h"

#import "UIAlertView+AFNetworking.h"

static EvercamShell *instance = nil;

@implementation EvercamShell

+ (EvercamShell *) shell
{
    if (instance == nil)
    {
        instance = [[EvercamShell alloc] init];
    }
    return instance;
}

- (void) requestEvercamAPIKeyFromEvercamUser:(NSString*) username
                                                      Password:(NSString*) password
                                                        WithBlock:(void (^)(EvercamApiKeyPair *userKeyPair, NSError *error))block {
   
    NSString *strURL = [NSString stringWithFormat:@"users/%@/credentials",username];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:password, @"password", nil];
    
    NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] GET:strURL parameters:parameters success:^(NSURLSessionDataTask * __unused task, id JSON) {
        keyPair.apiId = [JSON valueForKeyPath:@"api_id"];
        keyPair.apiKey = [JSON valueForKeyPath:@"api_key"];

        if (block) {
            block(keyPair, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
    [task resume];
}

- (void) createUser:(EvercamUser*) user WithBlock:(void (^)(EvercamUser *newuser, NSError *error))block {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:user.firstname, @"firstname",
                                user.lastname, @"lastname",
                                user.email, @"email",
                                user.country, @"country",
                                user.username, @"username",
                                user.password, @"password",
                                nil];
    
    NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] POST:@"users" parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
        NSArray *userArray = [JSON valueForKeyPath:@"users"];
        NSDictionary *user0 = userArray[0];

        EvercamUser *newUser = [[EvercamUser alloc] initWithDictionary:user0];
        if (block) {
            block(newUser, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil, error);
        }

    }];
    
    [task resume];
}



@end
