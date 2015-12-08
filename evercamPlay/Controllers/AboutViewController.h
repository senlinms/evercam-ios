//
//  AboutViewController.h
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface AboutViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

@end
