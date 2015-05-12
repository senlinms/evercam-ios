//
//  CameraBuilder.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamCameraBuilder.h"
#import "EvercamShell.h"
#import "EvercamApiKeyPair.h"

@implementation EvercamCameraBuilder

- (id)initWithCameraId:(NSString *)cameraId andCameraName:(NSString *)cameraName andIsPublic:(BOOL)isPublic {
    self = [super init];
    if (self) {
        _cameraId = cameraId;
        _name = cameraName;
        _isPublic = isPublic;
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:[EvercamShell shell].keyPair.apiKey forKey:@"api_key"];
    [dict setValue:[EvercamShell shell].keyPair.apiId forKey:@"api_id"];
    [dict setValue:self.cameraId forKey:@"id"];
    if (self.internalHost.length > 0) {
        [dict setValue:self.internalHost forKey:@"internal_host"];
    }
    if (self.internalHttpPort > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", self.internalHttpPort] forKey:@"internal_http_port"];
    }
    if (self.internalRtspPort > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", self.internalRtspPort] forKey:@"internal_rtsp_port"];
    }
    if (self.externalHost.length > 0) {
        [dict setValue:self.externalHost forKey:@"external_host"];
    }
    if (self.externalHttpPort > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", self.externalHttpPort] forKey:@"external_http_port"];
    }
    if (self.externalRtspPort > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", self.externalRtspPort] forKey:@"external_rtsp_port"];
    }
    if (self.jpgUrl.length > 0) {
        [dict setValue:self.jpgUrl forKey:@"jpg_url"];
    }
    if (self.mjpgUrl.length > 0) {
        [dict setValue:self.mjpgUrl forKey:@"mjpg_url"];
    }
    if (self.mpegUrl.length > 0) {
        [dict setValue:self.mpegUrl forKey:@"mpeg_url"];
    }
    if (self.h264Url.length > 0) {
        [dict setValue:self.h264Url forKey:@"h264_url"];
    }
    if (self.audioUrl.length > 0) {
        [dict setValue:self.audioUrl forKey:@"audio_url"];
    }
    if (self.isPublic) {
        [dict setValue:@"1" forKey:@"is_public"];
    } else {
        [dict setValue:@"0" forKey:@"is_public"];
    }
//    if (self.isOnline) {
//        [dict setValue:@"1" forKey:@"is_online"];
//    } else {
//        [dict setValue:@"0" forKey:@"is_online"];
//    }
    if (self.cameraUsername.length > 0) {
        [dict setValue:self.cameraUsername forKey:@"cam_username"];
    }
    if (self.cameraPassword.length > 0) {
        [dict setValue:self.cameraPassword forKey:@"cam_password"];
    }
    if (self.name.length > 0) {
        [dict setValue:self.name forKey:@"name"];
    }
    if (self.model.length > 0) {
        [dict setValue:self.model forKey:@"model"];
    }
    if (self.vendor.length > 0) {
        [dict setValue:self.vendor forKey:@"vendor"];
    }
    if (self.timezone.length > 0) {
        [dict setValue:self.timezone forKey:@"timezone"];
    }
    if (self.macAddress.length > 0) {
        [dict setValue:self.macAddress forKey:@"mac_address"];
    }
    if (self.locationLat > 0) {
        [dict setValue:[NSString stringWithFormat:@"%f", self.locationLat] forKey:@"location_lat"];
    }
    if (self.locationLng > 0) {
        [dict setValue:[NSString stringWithFormat:@"%f", self.locationLng] forKey:@"location_lng"];
    }
    return dict;
}

@end
