//
//  AppUser.m
//  evercamPlay
//
//  Created by jw on 4/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
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

- (id) initWithEvercamUser: (EvercamUser *)evercamUser {
    self= [super init];
    if (self)
    {
        self.username = evercamUser.username;
        self.email= evercamUser.email;
        self.firstName = evercamUser.firstname;
        self.lastName = evercamUser.lastname;
        self.country = evercamUser.country;
    }
    return self;
}

- (void)setDataWithEvercamUser:(EvercamUser *)evercamUser {
    self.username = evercamUser.username;
    self.email= evercamUser.email;
    self.firstName = evercamUser.firstname;
    self.lastName = evercamUser.lastname;
    self.country = evercamUser.country;
}

- (void) setApiKeyPairWithApiKey:(NSString *)apiKey andApiId:(NSString *)apiId {
    self.apiKey = apiKey;
    self.apiId = apiId;
}

@end
