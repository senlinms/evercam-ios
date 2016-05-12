//
//  NewShareViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/11/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "NewShareViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EvercamUtility.h"
#import "EvercamShare.h"
@interface NewShareViewController (){
    NSString *rights;
}

@end

@implementation NewShareViewController
@synthesize cameraId;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.share_ScrollView contentSizeToFit];
    self.message_TextView.textColor = [AppUtility colorWithHexString:@"cdcdd2"];
    rights = @"Snapshot,List";
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendRequest:(id)sender {
    
    [self.emailTextField resignFirstResponder];
    [self.message_TextView resignFirstResponder];
    
    if (isCompletelyEmpty(self.emailTextField.text)){
        [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Please enter a valid Email or Username."];
        return;
    }
    
    NSString *message;
    NSDictionary *param_Dictionary;
    if ([self.message_TextView.text isEqualToString:@"Message to send in Email (Optional)"]) {
        message = @"";
        param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:cameraId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSNumber numberWithBool:NO],@"isPending",[NSDictionary dictionaryWithObjectsAndKeys:self.emailTextField.text,@"email",rights,@"rights", nil],@"Post_Param", nil];
    }else{
        message = self.message_TextView.text;
        param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:cameraId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSNumber numberWithBool:NO],@"isPending",[NSDictionary dictionaryWithObjectsAndKeys:self.emailTextField.text,@"email",rights,@"rights",message,@"message", nil],@"Post_Param", nil];
    }
    [self.loading_ActivityIndicator startAnimating];

    
    [EvercamShare New_Resend_CameraShare:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.loading_ActivityIndicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Share request sent successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            [self.loading_ActivityIndicator stopAnimating];
            if (error.userInfo[@"Error_Server"]) {
                [AppUtility displayAlertWithTitle:@"Error!" AndMessage:error.userInfo[@"Error_Server"]];
            }else{
                [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
            }
            
        }
    }];
    
}

- (IBAction)segment_Action:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0) {
        rights = @"Snapshot,List";
    }else{
        rights = @"Snapshot,View,Edit,List";
    }
}


#pragma UIALERTVIEW DELEGATE
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma UITEXTVIEW DELEGATE
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Message to send in Email (Optional)"]) {
        textView.text = @"";
    }else{
        textView.text = textView.text;
    }
    textView.textColor = [AppUtility colorWithHexString:@"000000"];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([[self.message_TextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        textView.text = @"Message to send in Email (Optional)";
        textView.textColor = [AppUtility colorWithHexString:@"cdcdd2"];
    }
}


#pragma UITEXTFIELD DELEGATE
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
