//
//  ReportCameraViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/6/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "ReportCameraViewController.h"
#import "AppDelegate.h"
#import <UNIRest.h>
#import "EvercamUtility.h"

@interface ReportCameraViewController (){
    NSString *userid;
    NSString *webApiKey;
    NSString *intercomAppId;
}

@end

@implementation ReportCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AppUser *defaultUser = [APP_DELEGATE getDefaultUser];
    webApiKey = nil;
    intercomAppId = nil;
    NSString* localPlistPath    = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"plist"];
    if (localPlistPath) {
        NSDictionary *contents  = [NSDictionary dictionaryWithContentsOfFile:localPlistPath];
        webApiKey     = contents[@"IntercomWebApiKey"];
        intercomAppId = contents[@"IntercomAppId"];
    }
    NSDictionary* headers = @{@"Accept": @"application/json"};
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://api.intercom.io/users?user_id=%@",defaultUser.username];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    UNIHTTPJsonResponse *response = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:jsonUrlString];
        [request setHeaders:headers];
        [request setUsername:intercomAppId];
        [request setPassword:webApiKey];
    }] asJson];
        if (response.code == 200) {
            userid = response.body.object[@"id"];
            NSLog(@"userid: %@",userid);
        }else{
            NSLog(@"Error getting user id.");
        }
        NSLog(@"Response: %@",response.body.JSONObject);
    });
    
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
- (IBAction)reportModel:(id)sender {
    if (isCompletelyEmpty(self.modelTextField.text)) {
        [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Please enter model information."];
        return;
    }
    [self.modelTextField resignFirstResponder];
    NSDictionary *fromDictionary = @{@"type": @"user",@"id":userid};
    NSDictionary *bodyDictionary = @{@"from":fromDictionary,@"body":self.modelTextField.text};
    NSDictionary *headers = @{@"Accept": @"application/json",@"Content-Type": @"application/json"};
    NSString *jsonUrlString = @"https://api.intercom.io/messages";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
            [request setUrl:jsonUrlString];
            [request setHeaders:headers];
            [request setUsername:intercomAppId];
            [request setPassword:webApiKey];
            [request setBody:[NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:nil]];
        }] asJson];
        if (response.code == 200) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Thanks for your feedback." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 5603;
            [alert show];
            
        }else{
            NSLog(@"Error Posting model.");
        }
        NSLog(@"Response: %@",response.body.JSONObject);
    });
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
