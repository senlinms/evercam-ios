//
//  ;
//  evercamPlay
//
//  Created by jw on 3/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamUser.h"

@implementation EvercamUser

- (id) initWithDictionary: (NSDictionary *)userDict
{
    self= [super init];
    if (self)
    {
        self.uId = [userDict valueForKeyPath:@"id"];
        self.createdAt = [userDict valueForKeyPath:@"created_at"];
        self.updatedAt = [userDict valueForKeyPath:@"updated_at"];
        self.confirmedAt = [userDict valueForKeyPath:@"confirmed_at"];
        self.firstname = [userDict valueForKeyPath:@"firstname"];
        self.lastname = [userDict valueForKeyPath:@"lastname"];
        self.username = [userDict valueForKeyPath:@"username"];
        self.email = [userDict valueForKeyPath:@"email"];
        self.country = [userDict valueForKeyPath:@"country"];
        self.billingId = [userDict valueForKeyPath:@"billing_id"];
    }

    return  self;
}
@end
