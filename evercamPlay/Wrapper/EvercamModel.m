//
//  EvercamModel.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamModel.h"

@implementation EvercamModel

- (id) initWithDictionary: (NSDictionary *)modelDict {
    self= [super init];
    if (self)
    {
        self.mId = [modelDict valueForKey:@"id"];
        self.vId = [modelDict valueForKey:@"vendor_id"];
        self.name = [modelDict valueForKey:@"name"];
        self.defaults = [[EvercamDefaults alloc] initWithDictionary:[modelDict valueForKey:@"defaults"]];
    }
    
    return self;
}

@end
