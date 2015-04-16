//
//  CommonUtil.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "CommonUtil.h"
#import "AppDelegate.h"

@implementation CommonUtil

+ (NSData *)getDrawable:(NSString *)url {
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    return data;
}

+ (NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

+ (NSArray *)snapshotFiles:(NSString *)cameraId {
    NSURL *documentsDirectory = [APP_DELEGATE applicationDocumentsDirectory];
    NSURL *snapshotDir = [documentsDirectory URLByAppendingPathComponent:cameraId];
    NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtPath:snapshotDir.path];
    NSString *f;
    NSURL *fqn;
    NSMutableArray *filenameArray = [NSMutableArray new];
    while ((f = [de nextObject])) {
        fqn = [snapshotDir URLByAppendingPathComponent:f];
        [filenameArray addObject:fqn];
    }
    return filenameArray;
}

@end
