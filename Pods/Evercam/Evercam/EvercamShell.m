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
#import "EvercamVendor.h"
#import "EvercamModel.h"
#import "EvercamCamera.h"
#import "EvercamCameraBuilder.h"
#import "EvercamCameraUtil.h"
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

- (void)setUserKeyPairWithApiId:(NSString *)apiId andApiKey:(NSString *)apiKey {
    keyPair.apiId = apiId;
    keyPair.apiKey = apiKey;
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

- (void) getUserFromId:(NSString *) userId withBlock:(void (^)(EvercamUser *newuser, NSError *error))block {
    if (keyPair && userId) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyPair.apiId, @"api_id",
                                                 keyPair.apiKey, @"api_key",
                                                 nil];
        
        NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%@", userId] parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
            NSArray *userArray = [JSON valueForKeyPath:@"users"];
            NSDictionary *user0 = userArray[0];
            
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
            NSLog( @"%@", JSON );
            
            if (r.statusCode == CODE_OK)
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
        NSDictionary *parameters;
        if (userId)
            parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyPair.apiId, @"api_id",
                                keyPair.apiKey, @"api_key",
                                includeShared ? @"true" : @"false", @"include_shared",
                                includeThumbnail ? @"true" : @"false", @"thumbnail",
                                userId, @"user_id",
                                nil];
        else
            parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyPair.apiId, @"api_id",
                                        keyPair.apiKey, @"api_key",
                                        includeShared ? @"true" : @"false", @"include_shared",
                                        includeThumbnail ? @"true" : @"false", @"thumbnail",
                                        nil];

        [EvercamCameraUtil getByUrl:@"cameras" Parameters:parameters WithBlock:block];
    }
}

- (void)createCamera:(EvercamCameraBuilder *)cameraBuilder withBlock:(void (^)(EvercamCamera *camera, NSError *error))block {
    if (keyPair) {
        NSDictionary *parameters = [cameraBuilder toDictionary];
        
        NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] POST:@"cameras" parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
            
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
            NSLog( @"%@", JSON );
            
            if (r.statusCode == CODE_CREATE)
            {
                NSArray *jsonCameraArray = [JSON valueForKeyPath:@"cameras"];
                NSDictionary *jsonCamera = [jsonCameraArray objectAtIndex:0];
                EvercamCamera *camera = [[EvercamCamera alloc] initWithDictionary:jsonCamera];
                if (block) {
                    block(camera, nil);
                }
            }
            else if (r.statusCode == CODE_UNAUTHORISED)
            {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_INVALID_AUTH };
                NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                      code:r.statusCode userInfo:errorDictionary];
                if (block) {
                    block(nil, error);
                }
            }
            else if (r.statusCode == CODE_SERVER_ERROR)
            {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_SERVER_ERROR };
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
}

- (void)deleteCamera:(NSString *)cameraId withBlock:(void (^)(BOOL success, NSError *error))block {
    if (keyPair) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyPair.apiId, @"api_id",
                                    keyPair.apiKey, @"api_key",
                                    nil];
        
        NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"cameras/%@", cameraId] parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
            
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
            NSLog( @"%@", JSON );
            
            if (r.statusCode == CODE_OK)
            {
                if (block) {
                    block(true, nil);
                }
            }
            else if (r.statusCode == CODE_UNAUTHORISED)
            {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_INVALID_USER_KEY };
                NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                      code:r.statusCode userInfo:errorDictionary];
                if (block) {
                    block(NO, error);
                }
            }
            else if (r.statusCode == CODE_SERVER_ERROR)
            {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_SERVER_ERROR };
                NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                      code:r.statusCode userInfo:errorDictionary];
                if (block) {
                    block(NO, error);
                }
            }
            else
            {
                NSString *message = [JSON valueForKeyPath:@"message"];
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : message };
                NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                      code:r.statusCode userInfo:errorDictionary];
                if (block) {
                    block(NO, error);
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (block) {
                block(NO, error);
            }
        }];
        
        [task resume];
    }
}

- (void)deleteShareCamera:(NSString *)cameraId andUserId:(NSNumber *)userId withBlock:(void (^)(BOOL success, NSError *error))block {
    if (keyPair) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyPair.apiId, @"api_id",
                                    keyPair.apiKey, @"api_key",
                                    userId, @"email",
                                    nil];
        
        NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"cameras/%@/shares", cameraId] parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
            
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
            NSLog( @"%@", JSON );
            
            if (r.statusCode == CODE_OK)
            {
                if (block) {
                    block(true, nil);
                }
            }
            else
            {
                NSString *message = [JSON valueForKeyPath:@"message"];
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : message };
                NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                      code:r.statusCode userInfo:errorDictionary];
                if (block) {
                    block(NO, error);
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (block) {
                block(NO, error);
            }
        }];
        
        [task resume];
    }
}

- (void)patchCamera:(EvercamCameraBuilder *)cameraBuilder withBlock:(void (^)(EvercamCamera *camera, NSError *error))block {
    if (keyPair) {
        NSDictionary *parameters = [cameraBuilder toDictionary];
        
        NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] PATCH:[NSString stringWithFormat:@"cameras/%@", cameraBuilder.cameraId] parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
            
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
            NSLog( @"%@", JSON );
            
            if (r.statusCode == CODE_OK)
            {
                NSArray *jsonCameraArray = [JSON valueForKeyPath:@"cameras"];
                NSDictionary *jsonCamera = [jsonCameraArray objectAtIndex:0];
                EvercamCamera *camera = [[EvercamCamera alloc] initWithDictionary:jsonCamera];
                if (block) {
                    block(camera, nil);
                }
            }
            else if (r.statusCode == CODE_UNAUTHORISED || r.statusCode == CODE_FORBIDDEN)
            {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_INVALID_AUTH };
                NSError *error  = [NSError errorWithDomain:@"api.evercam.io"
                                                      code:r.statusCode userInfo:errorDictionary];
                if (block) {
                    block(nil, error);
                }
            }
            else if (r.statusCode == CODE_SERVER_ERROR)
            {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_SERVER_ERROR };
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
}

- (NSString *)getSnapshotLink:(NSString *)cameraID {
    NSString *url = [NSString stringWithFormat:@"%@cameras/%@/live/snapshot.jpg?api_id=%@&api_key=%@",
                     [AFEvercamAPIClient sharedClient].baseUrl,
                     cameraID,
                     keyPair.apiId,
                     keyPair.apiKey];
    return url;
}

- (void)getSnapshotFromEvercam:(EvercamCamera *)camera withBlock:(void (^)(NSData *imgData, NSError *error))block {
    return [self getSnapshotFromCamId:camera.camId withBlock:block];
}

- (void)getSnapshotFromCamId:(NSString *)cameraID withBlock:(void (^)(NSData *imgData, NSError *error))block {
    if (keyPair)
    {
        NSString *url = [NSString stringWithFormat:@"%@cameras/%@/live/snapshot.jpg?api_id=%@&api_key=%@",
                         [AFEvercamAPIClient sharedClient].baseUrl,
                         cameraID,
                         keyPair.apiId,
                         keyPair.apiKey];
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                // WARNING: is the cell still using the same data by this point??
                if (block) {
                    block(data, nil);
                }
            });
        });
        
    }
}

#pragma mark - Model Functions
- (void)getAllModelsByVendorId:(NSString *)vendorId withBlock:(void (^)(NSArray *models, NSError *error))block {
    [self getAllModelsByVendorId:vendorId andLimit:100 andPage:0 andCurrentModelsArray:[NSMutableArray new] withBlock:block];
}

- (void)getAllModelsByVendorId:(NSString *)vendorId andLimit:(NSInteger)limit andPage:(NSInteger)page andCurrentModelsArray:(NSMutableArray *)currentModelsArray withBlock:(void (^)(NSArray *models, NSError *error))block {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:vendorId, @"vendor_id",
                                [NSString stringWithFormat:@"%ld", (long)limit], @"limit",
                                [NSString stringWithFormat:@"%ld", (long)page], @"page",
                                nil];
    NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] GET:@"models" parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
        
        NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
        NSLog( @"%@", JSON );
        
        if (r.statusCode == CODE_OK)
        {
            NSArray *jsonModelsArray = [JSON valueForKeyPath:@"models"];
            NSMutableArray *modelsArray = [NSMutableArray  new];
            for (NSDictionary *jsonModelDict in jsonModelsArray) {
                EvercamModel *model = [[EvercamModel alloc] initWithDictionary:jsonModelDict];
                [modelsArray addObject:model];
            }
            
            NSInteger pageCount = 0;
            if ([JSON valueForKey:@"pages"]) {
                pageCount = [[JSON valueForKey:@"pages"] integerValue];
            }
            
            [currentModelsArray addObjectsFromArray:modelsArray];
            if (pageCount > 0 && page <= pageCount) {                
                [self getAllModelsByVendorId:vendorId andLimit:limit andPage:page+1 andCurrentModelsArray:currentModelsArray withBlock:block];
            } else {
                if (block) {
                    block(currentModelsArray, nil);
                }
            }
        }
        else
        {
            if (block) {
                block(currentModelsArray, nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(currentModelsArray, nil);
        }
    }];
    
    [task resume];
}

#pragma mark - Vendor Functions
- (void)getAllVendors:(void (^)(NSArray *vendors, NSError *error))block {
    [self getVendors:@"vendors" withBlock:block];
}

- (void)getVendors:(NSString *)URLString withBlock:(void (^)(NSArray *vendors, NSError *error))block {
    NSURLSessionDataTask *task= [[AFEvercamAPIClient sharedClient] GET:URLString parameters:nil success:^(NSURLSessionDataTask *task, id JSON) {
        
        NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
        NSLog( @"%@", JSON );
        
        if (r.statusCode == CODE_OK)
        {
            NSArray *jsonVendorsArray = [JSON valueForKeyPath:@"vendors"];
            NSMutableArray *vendorsArray = [NSMutableArray  new];
            for (NSDictionary *jsonVendorDict in jsonVendorsArray) {
                EvercamVendor *vendor = [[EvercamVendor alloc] initWithDictionary:jsonVendorDict];
                [vendorsArray addObject:vendor];
            }
            if (block) {
                block(vendorsArray, nil);
            }
        }
        else if (r.statusCode == CODE_SERVER_ERROR)
        {
            NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : MSG_SERVER_ERROR };
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
@end
