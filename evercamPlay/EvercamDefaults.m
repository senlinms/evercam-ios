//
//  EvercamDefaults.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamDefaults.h"

@implementation EvercamDefaults

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSDictionary *authDict = [dict valueForKey:@"auth"];
        if (authDict) {
            NSDictionary *basicDict = [authDict valueForKey:@"basic"];
            if (basicDict) {
                self.authUsername = [basicDict valueForKey:@"username"];
                self.authPassword = [basicDict valueForKey:@"password"];
            }
        }
        
        NSDictionary *snapshotsDict = [dict valueForKey:@"snapshots"];
        if (snapshotsDict) {
            self.h264URL = [snapshotsDict valueForKey:@"h264"];
            self.jpgURL = [snapshotsDict valueForKey:@"jpg"];
            self.lowResURL = [snapshotsDict valueForKey:@"lowres"];
            self.mjpgURL = [snapshotsDict valueForKey:@"mjpg"];
            self.mpeg4URL = [snapshotsDict valueForKey:@"mpeg4"];
            self.mobileURL = [snapshotsDict valueForKey:@"mobile"];
        }
    }
    
    return self;
}


@end
