//
//  EvercamModel.h
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvercamDefaults.h"

@interface EvercamModel : NSObject

@property (nonatomic, strong) NSString *mId;
@property (nonatomic, strong) NSString *vId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) EvercamDefaults *defaults;

- (id) initWithDictionary: (NSDictionary *)modelDict;

@end
