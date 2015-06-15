//
//  EvercamVendor.h
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvercamVendor : NSObject

@property (nonatomic, strong) NSString *vId;
@property (nonatomic, strong) NSString *name;

- (id) initWithDictionary: (NSDictionary *)vendorDict;

@end
