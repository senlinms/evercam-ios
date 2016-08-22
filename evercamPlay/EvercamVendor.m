//
//  EvercamVendor.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamVendor.h"

@implementation EvercamVendor

- (id) initWithDictionary: (NSDictionary *)vendorDict {
    self= [super init];
    if (self)
    {
        self.vId = [vendorDict valueForKey:@"id"];
        self.name = [vendorDict valueForKey:@"name"];
        self.logoUrl = [vendorDict valueForKey:@"logo"];
        
    }
    
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"vid: %@, name: %@, logoUrl: %@", self.vId, self.name, self.logoUrl];
}

@end
