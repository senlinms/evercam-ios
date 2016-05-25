//
//  AddPresetViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "AddPresetViewController.h"
#import "EvercamUtility.h"
#import "EvercamPtzControls.h"
#import "GlobalSettings.h"
@interface AddPresetViewController ()

@end

@implementation AddPresetViewController
@synthesize cameraId;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender {
    if ([GlobalSettings sharedInstance].isPhone) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"K_LOAD_PRESET" object:nil];
    }
}
- (IBAction)addPreset:(id)sender {
    if (isCompletelyEmpty(self.nameField.text)) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Please enter a preset name."];
        return;
    }
    [self.nameField resignFirstResponder];
    self.view.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];
    NSString *trimmedString = [self.nameField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    NSDictionary * param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:cameraId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[trimmedString stringByReplacingOccurrencesOfString:@" " withString:@"-"],@"name", nil];
    
    [EvercamPtzControls createPreset:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            self.view.userInteractionEnabled = YES;
            [self.activityIndicator stopAnimating];
            if ([GlobalSettings sharedInstance].isPhone) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                
                [self dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"K_LOAD_PRESET" object:nil];
                
            }
        }else{
            self.view.userInteractionEnabled = YES;
            [self.activityIndicator stopAnimating];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
