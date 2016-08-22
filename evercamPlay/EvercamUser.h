//
//  EvercamUser.h
//  evercamPlay
//
//  Created by jw on 3/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamUser : NSObject

@property (nonatomic, strong) NSString *uId;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *confirmedAt;
@property (nonatomic, strong) NSString *billingId;

@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

- (id) initWithDictionary: (NSDictionary *)userDict;
@end
