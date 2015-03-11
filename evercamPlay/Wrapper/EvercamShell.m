//
//  EvercamShell.m
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamShell.h"
#import "EvercamApiKeyPair.h"

#define VERSION "v1"
#define SERVER_ENDPOINT @"https://api.evercam.io/"

static EvercamShell *instance = nil;

@implementation EvercamShell

+ (EvercamShell *) sharedInstance
{
    if (instance == nil)
    {
        instance = [[EvercamShell alloc] init];
    }
    return instance;
}

- (EvercamApiKeyPair *) requestUserKeyPairFromEvercamUser:(NSString*) username withPassword: (NSString*) password
{
    return nil;
}

@end
