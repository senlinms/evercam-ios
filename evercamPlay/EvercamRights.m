//
//  EvercamRights.m
//  evercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "EvercamRights.h"

#define SNAPSHOT @"snapshot"
#define VIEW @"view"
#define EDIT @"edit"
#define DELETE @"delete"
#define LIST @"list"
#define GRANT_SNAPSHOT @"grant~snapshot"
#define GRANT_VIEW @"grant~view"
#define GRANT_EDIT @"grant~edit"
#define GRANT_DELETE @"grant~delete"
#define GRANT_LIST @"grant~list"

@implementation EvercamRights

- (id) initWithString: (NSString *)rightsString {
    self= [super init];
    if (self)
    {
        self.rightsString = rightsString;
    }
    return self;
}

- (BOOL)containsString:(NSString *)aString {
    NSArray *arrStrings = [self.rightsString componentsSeparatedByString:@","];
    for (NSString *string in arrStrings) {
        if ([string isEqualToString:aString]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)canGetSnapshot {
    return [self containsString:SNAPSHOT];
}

- (BOOL)canEdit {
    return [self containsString:EDIT];
}

- (BOOL)canView {
    return [self containsString:VIEW];
}

- (BOOL)canDelete {
    return [self containsString:DELETE];
}

- (BOOL)canList {
    return [self containsString:LIST];
}

- (BOOL)canGrantSnapshot {
    return [self containsString:GRANT_SNAPSHOT];
}

- (BOOL)canGrantEdit {
    return [self containsString:GRANT_EDIT];
}

- (BOOL)canGrantView {
    return [self containsString:GRANT_VIEW];
}

- (BOOL)canGrantDelete {
    return [self containsString:GRANT_DELETE];
}

- (BOOL)canGrantList {
    return [self containsString:GRANT_LIST];
}

@end
