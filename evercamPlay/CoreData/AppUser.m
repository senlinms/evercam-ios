//
//  AppUser.m
//  EvercamPlay
//
//  Created by jw on 4/10/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "AppUser.h"
#import "EvercamUser.h"

@implementation AppUser

@dynamic userId;
@dynamic email;
@dynamic username;
@dynamic country;
@dynamic firstName;
@dynamic lastName;
@dynamic isDefault;
@dynamic apiKey;
@dynamic apiId;
@dynamic intercom_hmac_ios;

- (id) initWithEvercamUser: (EvercamUser *)evercamUser {
    self= [super init];
    if (self)
    {
        self.username = evercamUser.username;
        self.email= evercamUser.email;
        self.firstName = evercamUser.firstname;
        self.lastName = evercamUser.lastname;
        self.country = evercamUser.country;
        self.intercom_hmac_ios = evercamUser.intercom_hmac_ios;
    }
    return self;
}

- (void)setDataWithEvercamUser:(EvercamUser *)evercamUser {
    self.username = evercamUser.username;
    self.email= evercamUser.email;
    self.firstName = evercamUser.firstname;
    self.lastName = evercamUser.lastname;
    self.country = ([evercamUser.country isKindOfClass:[NSNull class]])?@"":evercamUser.country;
    self.intercom_hmac_ios = evercamUser.intercom_hmac_ios;
}

- (void) setApiKeyPairWithApiKey:(NSString *)apiKey andApiId:(NSString *)apiId {
    self.apiKey = apiKey;
    self.apiId = apiId;
}

@end
