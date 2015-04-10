//
//  AppUser.h
//  evercamPlay
//
//  Created by jw on 4/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EvercamUser;


@interface AppUser : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * apiKey;
@property (nonatomic, retain) NSString * apiId;

- (id) initWithEvercamUser: (EvercamUser *)evercamUser;
- (void)setDataWithEvercamUser:(EvercamUser *)evercamUser;
- (void) setApiKeyPairWithApiKey:(NSString *)apiKey andApiId:(NSString *)apiId;


@end
