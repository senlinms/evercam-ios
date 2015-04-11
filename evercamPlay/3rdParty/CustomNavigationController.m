//
//  asfasf.m
//  selfVies
//
//  Created by jw on 3/25/14.
//
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController
@synthesize isPortraitMode;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.isPortraitMode) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.isPortraitMode) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.isPortraitMode) {
        return UIInterfaceOrientationPortrait;
    } else {
        return UIInterfaceOrientationLandscapeLeft;
    }
}

@end