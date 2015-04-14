//
//  CommonUtil.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

+ (NSData *)getDrawable:(NSString *)url {
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    return data;
}

@end
