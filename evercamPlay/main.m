//
//  main.m
//  evercamPlay
//
//  Created by jw on 3/7/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#include "gst_ios_init.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        gst_ios_init();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
