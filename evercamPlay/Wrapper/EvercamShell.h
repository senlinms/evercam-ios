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

@interface EvercamShell : NSObject
{
    EvercamApiKeyPair *keyPair;
}

@end
