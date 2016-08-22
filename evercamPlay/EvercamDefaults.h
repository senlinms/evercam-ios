//
//  EvercamDefaults.h
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamDefaults : NSObject

@property (nonatomic, strong) NSString *jpgURL;
@property (nonatomic, strong) NSString *h264URL;
@property (nonatomic, strong) NSString *lowResURL;
@property (nonatomic, strong) NSString *mpeg4URL;
@property (nonatomic, strong) NSString *mobileURL;
@property (nonatomic, strong) NSString *mjpgURL;
@property (nonatomic, strong) NSString *authUsername;
@property (nonatomic, strong) NSString *authPassword;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
