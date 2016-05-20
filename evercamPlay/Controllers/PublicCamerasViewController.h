//
//  PublicCamerasViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/20/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicCamerasViewController : UIViewController<UIWebViewDelegate>{
    
}
- (IBAction)back_Action:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *cameras_WebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading_ActivityIndicator;

@end
