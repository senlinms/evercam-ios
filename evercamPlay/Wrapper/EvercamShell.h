//
//  EvercamShell.h
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_ID @""
#define API_Key @""

@class EvercamApiKeyPair;
@class EvercamUser;

@interface EvercamShell : NSObject
{
    EvercamApiKeyPair *keyPair;
}

+ (EvercamShell *) shell;
- (void) requestEvercamAPIKeyFromEvercamUser:(NSString*) username
                                    Password:(NSString*) password
                                   WithBlock:(void (^)(EvercamApiKeyPair *userKeyPair, NSError *error))block;
- (void) createUser:(EvercamUser*) user WithBlock:(void (^)(EvercamUser *newuser, NSError *error))block;
@end
