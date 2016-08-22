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
        
        self.iconUrl = modelDict[@"images"][@"icon"];
        self.originalUrl = modelDict[@"images"][@"original"];
        self.thumbUrl = modelDict[@"images"][@"thumbnail"];
        
        self.defaults = [[EvercamDefaults alloc] initWithDictionary:[modelDict valueForKey:@"defaults"]];
    }
    
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, icon: %@, original: %@, thumb: %@,",self.name, self.iconUrl, self.originalUrl, self.thumbUrl];
}

@end
