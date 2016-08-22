//
//  CameraBuilder.h
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamCameraBuilder : NSObject

@property (nonatomic, readonly, strong) NSString *cameraId;
@property (nonatomic, readonly) BOOL isPublic;
@property (nonatomic, readonly, strong) NSString *name;

@property (nonatomic, strong) NSString *vendor;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *timezone;
@property (nonatomic, strong) NSString *macAddress;
@property (nonatomic, strong) NSString *jpgUrl;
@property (nonatomic, strong) NSString *h264Url;
@property (nonatomic, strong) NSString *mjpgUrl;
@property (nonatomic, strong) NSString *mpegUrl;
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *internalHost;
@property (nonatomic) NSInteger internalHttpPort;
@property (nonatomic) NSInteger internalRtspPort;
@property (nonatomic, strong) NSString *externalHost;
@property (nonatomic) NSInteger externalHttpPort;
@property (nonatomic) NSInteger externalRtspPort;
@property (nonatomic, strong) NSString *cameraUsername;
@property (nonatomic, strong) NSString *cameraPassword;
@property (nonatomic) float locationLng;
@property (nonatomic) float locationLat;
@property (nonatomic) BOOL isOnline;

- (id)initWithCameraId:(NSString *)cameraId andCameraName:(NSString *)cameraName andIsPublic:(BOOL)isPublic;
- (NSDictionary *)toDictionary;
@end
