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
#import "EvercamCamera.h"
#import "AFEvercamAPIClient.h"

#import "UIAlertView+AFNetworking.h"

static EvercamShell *instance = nil;

@implementation EvercamShell
@synthesize keyPair;

+ (EvercamShell *) shell
{
    if (instance == nil)
    {
        instance = [[EvercamShell alloc] init];
        instance.keyPair = [[EvercamApiKeyPair alloc] init];
    }
    return instance;
}

- (void) requestEvercamAPIKeyFromEvercamUser:(NSString*) username
                                                      Password:(NSString*) password
                                                        WithBlock:(void (^)(EvercamApiKeyPair *userKeyPair, NSError *error))block {
   
    NSString *strURL = [NSString stringWithFormat:@"users/%@/credentials",username];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:password, @"password", nil];
    
    NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] GET:strURL parameters:parameters success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
        
        if (r.statusCode == CODE_OK)
        {
            keyPair.apiId = [JSON valueForKeyPath:@"api_id"];
            keyPair.apiKey = [JSON valueForKeyPath:@"api_key"];
            
            if (block)
                block(keyPair, nil);
        }
        else
        {
            NSString *message = [JSON valueForKeyPath:@"message"];
            NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : message };
            NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                  code:r.statusCode userInfo:errorDictionary];
            if (block)
                block(nil, error);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
    [task resume];
}

- (void) createUser:(EvercamUser*) user WithBlock:(void (^)(EvercamUser *newuser, NSError *error))block {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[user.firstname mutableCopy], @"firstname",
                                [user.lastname mutableCopy], @"lastname",
                                [user.email mutableCopy], @"email",
                                [user.country mutableCopy], @"country",
                                [user.username mutableCopy], @"username",
                                [user.password mutableCopy], @"password",
                                nil];
    
    NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] POST:@"users" parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
        NSArray *userArray = [JSON valueForKeyPath:@"users"];
        NSDictionary *user0 = userArray[0];

        NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
        NSLog( @"%@", JSON );

        if (r.statusCode == CODE_CREATE)
        {
            EvercamUser *newUser = [[EvercamUser alloc] initWithDictionary:user0];
            if (block) {
                block(newUser, nil);
            }
        }
        else if (r.statusCode == CODE_UNAUTHORISED || r.statusCode == CODE_FORBIDDEN)
        {
            NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_INVALID_USER_KEY };
            NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                  code:r.statusCode userInfo:errorDictionary];
            if (block) {
                block(nil, error);
            }
        }
        else
        {
            NSString *message = [JSON valueForKeyPath:@"message"];
            NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : message };
            NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                  code:r.statusCode userInfo:errorDictionary];
            if (block) {
                block(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
    
    [task resume];
}

/**
 * Returns the set of cameras associated with given conditions
 * API key pair has to be specified before calling this method
 *
 * @param userId           unique Evercam username of the user, can be null
 * @param includeShared    whether or not to include cameras shared with the user in the fetch.
 * @param includeThumbnail whether or not to get base64 encoded 150x150 thumbnail with camera view for each camera
 * @return the camera list that associated with the specified user
 * @throws EvercamException
 */
- (void)getAllCameras: (NSString*)userId includeShared:(BOOL)includeShared includeThumbnail:(BOOL) includeThumbnail withBlock:(void (^)(NSArray *cameras, NSError *error))block
{
    if (keyPair)
    {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyPair.apiId, @"api_id",
                                keyPair.apiKey, @"api_key",
                                includeShared ? @"true" : @"false", @"include_shared",
                                includeThumbnail ? @"true" : @"false", @"thumbnail",
                                nil];
        
        [EvercamCamera getByUrl:@"cameras" Parameters:parameters WithBlock:block];
    }
}

@end
