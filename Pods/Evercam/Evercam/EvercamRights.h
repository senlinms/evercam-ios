//
//  EvercamRights.h
//  evercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EvercamRights : NSObject

@property (nonatomic, strong) NSString *rightsString;

- (BOOL)canGetSnapshot;
- (BOOL)canEdit;
- (BOOL)canView;
- (BOOL)canDelete;
- (BOOL)canList;
- (BOOL)canGrantSnapshot;
- (BOOL)canGrantEdit;
- (BOOL)canGrantView;
- (BOOL)canGrantDelete;
- (BOOL)canGrantList;

- (id) initWithString: (NSString *)rightsString;

@end
