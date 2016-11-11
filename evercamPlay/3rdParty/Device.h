//
//  Device.h
//  LAN Scan
//
//  Created by Mongi Zaidi on 24 February 2014.
//  Copyright (c) 2014 Smart Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property NSString *vendorId;
@property NSString *name;
@property NSString *address;
@property NSString *mac_Address;
@property NSString *image_url;
@property NSString *http_Port;
@property NSString *onvif_Camera_model;

@end
