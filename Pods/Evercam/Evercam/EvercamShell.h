//
//  EvercamShell.h
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EvercamApiKeyPair;
@class EvercamUser;
@class EvercamCamera;
@class EvercamCameraBuilder;

@interface EvercamShell : NSObject
{
}
@property (nonatomic, strong) EvercamApiKeyPair *keyPair;

+ (EvercamShell *) shell;
- (void)setUserKeyPairWithApiId:(NSString *)apiId andApiKey:(NSString *)apiKey;

- (void) requestEvercamAPIKeyFromEvercamUser:(NSString*) username
                                    Password:(NSString*) password
                                   WithBlock:(void (^)(EvercamApiKeyPair *userKeyPair, NSError *error))block;
- (void) createUser:(EvercamUser*) user WithBlock:(void (^)(EvercamUser *newuser, NSError *error))block;
- (void) getUserFromId:(NSString *) userId withBlock:(void (^)(EvercamUser *newuser, NSError *error))block;

- (void)getAllCameras: (NSString*)userId includeShared:(BOOL)includeShared includeThumbnail:(BOOL) includeThumbnail withBlock:(void (^)(NSArray *cameras, NSError *error))block;
- (void)createCamera:(EvercamCameraBuilder *)cameraBuilder withBlock:(void (^)(EvercamCamera *camera, NSError *error))block;
- (void)deleteCamera:(NSString *)cameraId withBlock:(void (^)(BOOL success, NSError *error))block;
- (void)deleteShareCamera:(NSString *)cameraId andUserId:(NSNumber *)userId withBlock:(void (^)(BOOL success, NSError *error))block;
- (void)patchCamera:(EvercamCameraBuilder *)cameraBuilder withBlock:(void (^)(EvercamCamera *camera, NSError *error))block ;
- (NSString *)getSnapshotLink:(NSString *)cameraID;
- (void)getSnapshotFromEvercam:(EvercamCamera *)camera withBlock:(void (^)(NSData *imgData, NSError *error))block;
- (void)getSnapshotFromCamId:(NSString *)cameraID withBlock:(void (^)(NSData *imgData, NSError *error))block;

// for models
- (void)getAllModelsByVendorId:(NSString *)vendorId withBlock:(void (^)(NSArray *models, NSError *error))block;

// for vendors
- (void)getAllVendors:(void (^)(NSArray *vendors, NSError *error))block;

@end
