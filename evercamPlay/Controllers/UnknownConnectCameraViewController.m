//
//  UnknownConnectCameraViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/16/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "UnknownConnectCameraViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CameraNameViewController.h"
#import "Intercom/intercom.h"
#import "EvercamUtility.h"
#import "GlobalSettings.h"
#import "SharedManager.h"
#import "AppDelegate.h"
#import "EvercamTestSnapShot.h"
#import "MBProgressHUD.h"
#import "getgateway.h"
#import <arpa/inet.h>
@interface UnknownConnectCameraViewController (){
    NSTimer *httpPortCheckTimer;
    NSTimer *rtspPortCheckTimer;
}

@end

@implementation UnknownConnectCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.textField_scrollView contentSizeToFit];
    self.vendorLabel.text = @"Unknown";
    [self getLocalIpAddress];
    [self checkHttpPort];
    [self checkRtstPort];
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

-(void)getLocalIpAddress{
    __block NSString *ipAddress = @"";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *jsonUrlString = @"http://bot.whatismyipaddress.com/";
        NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSHTTPURLResponse *response = nil;
        NSError *error              = nil;
        NSData *responseData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            ipAddress = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];;
            self.ipAddress_textField.text = [self isValidIPAddress:ipAddress]?ipAddress:@"";
        }else{
            self.ipAddress_textField.text = ipAddress;
        }
    });
}

- (BOOL)isValidIPAddress:(NSString *)ipString
{
    const char *utf8 = [ipString UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return success == 1;
}


-(void)checkRtstPort{
    NSString* ipAddress = [self.ipAddress_textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* rtspPort = self.rtsp_TextField.text;
    
    if(isCompletelyEmpty(rtspPort) || isCompletelyEmpty(ipAddress))
    {
        self.rtspPortLabel.text = @"";
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"%@address=%@&port=%@",[SharedManager getCheckPortUrl],ipAddress,rtspPort];
    
    [self checkPortWithUrl:url withParameters:nil withTextField:self.rtsp_TextField withLabel:self.rtspPortLabel];
}

-(void)checkHttpPort{
    NSString* ipAddress = [self.ipAddress_textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* httpPort = self.http_TextField.text;
    
    if(isCompletelyEmpty(httpPort) || isCompletelyEmpty(ipAddress))
    {
        self.httpPortLabel.text = @"";
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"%@address=%@&port=%@",[SharedManager getCheckPortUrl],ipAddress,httpPort];
    
    [self checkPortWithUrl:url withParameters:nil withTextField:self.http_TextField withLabel:self.httpPortLabel];
}

-(void)checkPortWithUrl:(NSString *)url withParameters:(NSDictionary *)params withTextField:(UITextField *)textField withLabel:(UILabel *)label{
    [SharedManager get:url params:nil callback:^(NSString *status, NSMutableDictionary *responseDict) {
        if([status isEqualToString:@"error"])
        {
            NSLog(@"Port-Checking server down");
            
        }else{
            NSArray *array = responseDict[@"JSON"];
            if (array.count > 0) {
                NSDictionary *response_Obj = array[0];
                if([response_Obj[@"open"] boolValue])
                {
                    if (![textField.text  isEqual: @""]) {
                        label.text = @"Port is open";
                        label.textColor = UIColorFromRGB(0x80CBC4);
                    }
                }
                else
                {
                    if (![textField.text  isEqual: @""]) {
                        label.text = @"Port is closed";
                        label.textColor = [UIColor redColor];
                    }
                }
            }else{
                if (![textField.text  isEqual: @""]) {
                    label.text = @"Port is closed";
                    label.textColor = [UIColor redColor];
                }
            }
        }
    }];
}


- (NSString *)getGatewayIP {
    NSString *ipString = nil;
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    if(r >= 0) {
        ipString = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
        NSLog(@"default gateway : %@", ipString );
    } else {
        NSLog(@"getdefaultgateway() failed");
    }
    
    return ipString;
    
}

- (IBAction)nextStepBtn:(id)sender {
    
//    NSMutableDictionary *param_Dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.ipAddress_textField.text,@"external_host",self.http_TextField.text,@"external_http_port",self.snapshotPathTextField.text,@"jpg_url",[NSNumber numberWithBool:NO],@"is_public",[NSNumber numberWithBool:YES],@"is_online",(isCompletelyEmpty(self.rtsp_TextField.text))?nil:self.rtsp_TextField.text,@"external_rtsp_port",(isCompletelyEmpty(self.username_TextField.text))?nil:self.username_TextField.text,@"cam_username",(isCompletelyEmpty(self.password_TextField.text))?nil:self.password_TextField.text,@"cam_password", nil];
    NSMutableDictionary *param_Dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.ipAddress_textField.text,@"external_host",self.http_TextField.text,@"external_http_port",self.snapshotPathTextField.text,@"jpg_url",[NSNumber numberWithBool:YES],@"is_online",(isCompletelyEmpty(self.rtsp_TextField.text))?@"":self.rtsp_TextField.text,@"external_rtsp_port",(isCompletelyEmpty(self.username_TextField.text))?nil:self.username_TextField.text,@"cam_username",(isCompletelyEmpty(self.password_TextField.text))?nil:self.password_TextField.text,@"cam_password", nil];
    
    
    CameraNameViewController *aVC = [[CameraNameViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"CameraNameViewController":@"CameraNameViewController_iPad" bundle:[NSBundle mainBundle]];
    aVC.postDictionary              = param_Dictionary;
    [self.navigationController pushViewController:aVC animated:YES];
}

- (IBAction)checkSnapShot:(id)sender {
    if ([self.httpPortLabel.text isEqualToString:@""]) {
        [self checkHttpPort];
    }
    NSString* ipAddress = [self.ipAddress_textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* httpPort = self.http_TextField.text;
    if(isCompletelyEmpty(ipAddress))
    {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Please specify an external IP address."];
        return;
    }else if (isCompletelyEmpty(httpPort)){
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Please specify an external HTTP port."];
        return;
    }
    
    if(isCompletelyEmpty(self.snapshotPathTextField.text))
    {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Please specify a snapshot path."];
        return;
    }
    
    BOOL ip = [self CheckIPAddress];    // to check either ip address is valid or not.
    if (ip) {
        return;
    }
    
    [self.ipAddress_textField resignFirstResponder];
    [self.http_TextField resignFirstResponder];
    [self.rtsp_TextField resignFirstResponder];
    [self.username_TextField resignFirstResponder];
    [self.password_TextField resignFirstResponder];
    [self.snapshotPathTextField resignFirstResponder];
    [self.rtspPathTextField resignFirstResponder];
    
    if ([self.httpPortLabel.text isEqualToString:@"Port is closed"]) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"The IP address provided is not reachable at the port provided."];
        return;
    }
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://%@:%@",ipAddress,httpPort],@"external_url",self.snapshotPathTextField.text,@"jpg_url",self.username_TextField.text,@"cam_username",self.password_TextField.text,@"cam_password",@"",@"camera_exid", nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EvercamTestSnapShot *api_snap_Obj = [EvercamTestSnapShot new];
    [api_snap_Obj testSnapShot:postDictionary withBlock:^(UIImage *snapeImage, NSString *statusMessage, NSError *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"The port is open but we can't seem to connect. Check that the camera model and credentials are correct."];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:error.localizedDescription];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([statusMessage isEqualToString:@"Success"]) {
                self.blackTransparentView.hidden    = NO;
                self.snapShotView.hidden            = NO;
                self.snapShotImageView.image        = snapeImage;
            }else{
//                [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"The port is open but we can't seem to connect. Check that the camera model and credentials are correct."];
                [AppUtility displayAlertWithTitle:@"Error!" AndMessage:error.localizedDescription];
            }
            
        }
    }];
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
    [self.username_TextField becomeFirstResponder];
    
}

- (IBAction)blackTransparentViewTapped:(id)sender {
    self.blackTransparentView.hidden = YES;
    self.snapShotView.hidden         = YES;
}


- (IBAction)textFieldsTextChanged:(id)sender {
    
    UITextField *selectedTextField = (UITextField *)sender;
    if (selectedTextField.tag == 1) {
        
        self.httpPortLabel.text = @"";
        self.rtspPortLabel.text = @"";
        [self httpPortCheckTimerStarter];
        [self rtspPortCheckTimerStarter];
        
    }else if (selectedTextField.tag == 2) {
        
        self.httpPortLabel.text = @"";
        [self httpPortCheckTimerStarter];
        
    }else if (selectedTextField.tag == 3) {
        
        self.rtspPortLabel.text = @"";
        [self rtspPortCheckTimerStarter];
        
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 1) { //ip Address textfield
        self.textFieldGuideLabel.text = @"Put the public URL or IP address of your camera. You will need to have setup port forwarding for your camera.";
        
    }else if (textField.tag == 2){ // http textfield
        self.textFieldGuideLabel.text = @"The port should be a 2 - 5 digit number. \n The default HTTP port is 554.";
        
    }else if (textField.tag == 3){ // rtsp textfield
        self.textFieldGuideLabel.text = @"The port should be a 2 - 5 digit number. \n The default RTSP port is 554.";
        
    }else if (textField.tag == 4 || textField.tag == 5){ // rtsp textfield
        self.textFieldGuideLabel.text = @"Put your camera's username and password. \n It's NOT the credentials for your Evercam account.";
        
    }else if (textField.tag == 6){
        
        self.textFieldGuideLabel.text = @"If you know your camera model we can work this out for you. Otherwise you have to enter it manually. \n eg. snapshot.jpg";
        
    }else if (textField.tag == 7){
        
        self.textFieldGuideLabel.text = @"If you know your camera model we can work this out for you. Otherwise you have to enter it manually. \n eg. h264/ch1/main/stream";
        
    }
}

-(void)httpPortCheckTimerStarter{
    if (httpPortCheckTimer) {
        [httpPortCheckTimer invalidate];
        httpPortCheckTimer = nil;
    }
    httpPortCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkHttpPort) userInfo:nil repeats:NO];
}

-(void)rtspPortCheckTimerStarter{
    if (rtspPortCheckTimer) {
        [rtspPortCheckTimer invalidate];
        rtspPortCheckTimer = nil;
    }
    rtspPortCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkRtstPort) userInfo:nil repeats:NO];
}

-(BOOL)CheckIPAddress
{
    NSString *string = self.ipAddress_textField.text;
    if (!string) {
        return false;
    }
    // this code is to check either user entered local/private ip-address, in case of local/private it will sendback true
    NSError *error = NULL;
    NSString *pattern = @"((^127\\.)|(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.))";
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:string options:NSMatchingProgress range:range];
    if (matches.count>0) {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"The IP address you provided is a local IP address. Please provide valid external/public IP address.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        return true;
    }
    return false;
}


@end
