//
//  ConnectCameraViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/9/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "ConnectCameraViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "Intercom/intercom.h"
@interface ConnectCameraViewController ()

@end

@implementation ConnectCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.textField_scrollView contentSizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.textField_scrollView contentSizeToFit];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)checkSnapShot:(id)sender {
}

- (IBAction)liveSupport:(id)sender {
    [Intercom presentConversationList];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)requireAuthenticationAction:(id)sender {
    
    self.authenticationSwitch.on = self.authenticationSwitch.isOn;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.authenticationSwitch.isOn) {
            self.authenticationView.hidden = NO;
            self.snapShotBtn.frame = CGRectMake(self.snapShotBtn.frame.origin.x, self.authenticationView.frame.origin.y + self.authenticationView.frame.size.height + 20, self.snapShotBtn.frame.size.width, self.snapShotBtn.frame.size.height);
            self.liveSupportBtn.frame = CGRectMake(self.liveSupportBtn.frame.origin.x, self.snapShotBtn.frame.origin.y + self.snapShotBtn.frame.size.height + 20, self.liveSupportBtn.frame.size.width, self.liveSupportBtn.frame.size.height);
        }else{
            self.authenticationView.hidden = YES;
            self.snapShotBtn.frame = CGRectMake(self.snapShotBtn.frame.origin.x, self.authenticationSwitch.frame.origin.y + self.authenticationSwitch.frame.size.height + 20, self.snapShotBtn.frame.size.width, self.snapShotBtn.frame.size.height);
            self.liveSupportBtn.frame = CGRectMake(self.liveSupportBtn.frame.origin.x, self.snapShotBtn.frame.origin.y + self.snapShotBtn.frame.size.height + 20, self.liveSupportBtn.frame.size.width, self.liveSupportBtn.frame.size.height);
            if ([self.username_TextField isFirstResponder]) {
                [self.username_TextField resignFirstResponder];
            }
            if ([self.password_TextField isFirstResponder]) {
                [self.password_TextField resignFirstResponder];
            }
        }
    }];
    
    [self.textField_scrollView contentSizeToFit];
    
}
@end
