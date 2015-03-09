//
//  WelcomeViewController.h
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *tutorialView;
@property (nonatomic, strong) IBOutlet UIScrollView *tutorialScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

- (IBAction)onSignIn:(id)sender;
- (IBAction)onSignUp:(id)sender;

@end
