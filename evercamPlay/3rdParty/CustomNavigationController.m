//
//  asfasf.m
//  selfVies
//
//  Created by Meng Hu on 3/25/14.
//
//

#import "CustomNavigationController.h"
#import "CameraPlayViewController.h"
#import "AppDelegate.h"

@implementation CustomNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.isPortraitMode) {
        if (self.hasLandscapeMode) {
            return YES;
        }
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.isPortraitMode) {
        if (self.hasLandscapeMode) {
            return UIInterfaceOrientationMaskAll;
        }
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.isPortraitMode) {
        
        UINavigationController* nvc = (UINavigationController*)[APP_DELEGATE viewController].presentedViewController;
        
        UIViewController* cvc = [nvc topViewController];
        
        if([cvc isKindOfClass:[CameraPlayViewController class]])
        {
            CustomNavigationController* cVC = [APP_DELEGATE viewController];
            
            [UIViewController attemptRotationToDeviceOrientation];
            
            return (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
            
        }
        else
        
        return UIInterfaceOrientationPortrait;
        
    } else {
        return UIInterfaceOrientationLandscapeLeft;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation1
{
    if (self.isPortraitMode) {
        return UIInterfaceOrientationPortrait;
    } else {
        return UIInterfaceOrientationLandscapeLeft;
    }
}

@end