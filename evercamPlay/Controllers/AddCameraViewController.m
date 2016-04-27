//
//  AddCameraViewController.m
//  EvercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "AddCameraViewController.h"
#import "SelectVendorViewController.h"
#import "SelectModelViewController.h"
#import "EvercamVendor.h"
#import "EvercamModel.h"
#import "EvercamCameraBuilder.h"
#import "EvercamCamera.h"
#import "EvercamShell.h"
#import "MBProgressHUD.h"
#import "CommonUtil.h"
#import "Reachability.h"
#import "NetworkUtil.h"
#import "GCDAsyncSocket.h"
#import "SDWebImageManager.h"
#import "GAIDictionaryBuilder.h"
#import "Config.h"
#import "BlockAlertView.h"
#import "Mixpanel.h"
#import "GlobalSettings.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "SharedManager.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EvercamTestSnapShot.h"

#define VIEWMARGIN 35

@interface AddCameraViewController () <SelectVendorViewControllerDelegate, SelectModelViewControllerDelegate>
{
    NIDropDown *vendorDropDown;
    NIDropDown *modelDropDown;
    GCDAsyncSocket *asyncSocket;
    UITextField *statusLabel;
    NSString* userName;
    NSMutableArray *viewsArray;
    NSMutableArray *minViewsArray;
    
    EvercamCameraBuilder    *cameraBuilder_AddMethod_Instance;
    __block EvercamCamera   *camera_PatchMethod_Instance;
    __block EvercamCamera   *camera_CreateCameraMethod_Instance;
    
    CAGradientLayer *gradient;
    
    NSTimer *httpPortCheckTimer;
    NSTimer *rtspPortCheckTimer;
    
}
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UIView *logoImagesContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (strong, nonatomic) UITextField *focusedTextField;
@property (nonatomic, strong) EvercamVendor *currentVendor;
@property (nonatomic, strong) EvercamModel *currentModel;
@property (nonatomic, strong) NSMutableArray *vendorsArray;
@property (nonatomic, strong) NSMutableArray *vendorsNameArray;
@property (nonatomic, strong) NSArray *modelsArray;
@property (nonatomic, strong) NSMutableArray *modelsNameArray;
@property (weak, nonatomic) IBOutlet UILabel *httpPortStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *rtspPortStatusLabel;

//--------------------------------views to hide---------------------------------
@property (weak, nonatomic) IBOutlet UIView *snapshotView;
@property (weak, nonatomic) IBOutlet UIView *rtstURLView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;

@end

@implementation AddCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.main_Scroll contentSizeToFit];
    self.tfExternalHost.text    = @"5.149.169.19";
    self.screenName             = @"Add/Edit Camera";
    self.tfVendor.text          = @"Unknown/Other";
    self.cameraView.hidden      = true;
    
    viewsArray      =  [[NSMutableArray alloc] initWithObjects: self.nameView, self.ipAddressView, self.httpPortView, self.snapshotView, self.rtspPortView, self.rtstURLView, self.credentialsView, nil];
    minViewsArray   =  [[NSMutableArray alloc] initWithObjects: self.nameView, self.ipAddressView, self.httpPortView, self.rtspPortView, self.credentialsView, nil];
    
    
    gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self initializeScreen];
    
    self.vendorsNameArray = [NSMutableArray array];
    self.modelsNameArray = [NSMutableArray array];
    
    [self getAllVendors];
    [self setTextFieldsPlaceHolder];
    self.tfExternalHttpPort.text = @"80";
    self.tfExternalRtspPort.text = @"554";
    [self checkHttpPort];
    [self checkRtstPort];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    gradient.frame = self.view.bounds;
}

-(void)setTextFieldsPlaceHolder{
    if ([self.tfID respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightTextColor];
        self.tfID.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"roof-cam" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Rooftop Camera" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfVendor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Unknown/Other" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfModel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Unknown/Other" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfSnapshot.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"/snapshot.jpg" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalHost.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"149.5.43.10" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalHttpPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"80" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalRtspPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"554" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfInternalHost.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"192.168.1.122" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfInternalHttpPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Internal HTTP port" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfInternalRtspPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Internal RTSP port" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalRtspUrl.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"/h264/ch1/mail/av_stream" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

- (IBAction)imageViewClose:(id)sender {
    self.imageContainer.hidden = YES;
    self.imageView.image = nil;
}

- (IBAction)back:(id)sender {
    if (self.editCamera) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.tfID.text.length > 0 ||
            self.tfName.text.length > 0 ||
            self.tfVendor.text.length > 0 ||
            self.tfModel.text.length > 0 ||
            self.tfUsername.text.length > 0 ||
            self.tfPassword.text.length > 0 ||
            self.tfSnapshot.text.length > 0 ||
            self.tfExternalHost.text.length > 0 ||
            self.tfExternalHttpPort.text.length > 0 ||
            self.tfExternalRtspPort.text.length > 0 ||
            self.tfInternalHost.text.length > 0 ||
            self.tfInternalHttpPort.text.length > 0 ||
            self.tfInternalRtspPort.text.length > 0) {
            
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"You'll lose everything you typed in. Are you sure you want to quit?", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
            simpleAlert.tag = 101;
            [simpleAlert show];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)displayErrorAlert:(NSString *)alertTitle withMessage:(NSString *)alertMessage{
    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:alertTitle message:NSLocalizedString(alertMessage,nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [simpleAlert show];
}


- (IBAction)test:(id)sender {
    if ([self.httpPortStatusLabel.text isEqualToString:@""]) {
        [self checkHttpPort];
    }
    NSString* ipAddress = [self.tfExternalHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* httpPort = self.tfExternalHttpPort.text;
    if(isCompletelyEmpty(ipAddress))
    {
        [self displayErrorAlert:@"Error!" withMessage:@"Please specify an external IP address."];
        return;
    }else if (isCompletelyEmpty(httpPort)){
        [self displayErrorAlert:@"Error!" withMessage:@"Please specify an external HTTP port."];
        return;
    }
    
    BOOL ip = [self CheckIPAddress];    // to check either ip address is valid or not.
    if (ip) {
        return;
    }
    
    [self.focusedTextField resignFirstResponder];
    
    NSString *jpg_Url = (self.currentModel.defaults.jpgURL == NULL)?@"":self.currentModel.defaults.jpgURL;
    NSString *vendorId = (self.currentVendor.vId == NULL)?@"":self.currentVendor.vId;
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://%@:%@",ipAddress,httpPort],@"external_url",jpg_Url,@"jpg_url",self.tfUsername.text,@"cam_username",self.tfPassword.text,@"cam_password",vendorId,@"vendor_id", nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EvercamTestSnapShot testSnapShot:postDictionary withBlock:^(UIImage *snapeImage, NSString *statusMessage, NSError *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self displayErrorAlert:@"Error!" withMessage:@"The port is open but we can't seem to connect. Check that the camera model and credentials are correct."];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([statusMessage isEqualToString:@"Success"]) {
                self.success_Message_View.hidden    = NO;
                self.test_SnapShot_ImageView.image  = snapeImage;
            }else{
                
                [self displayErrorAlert:@"Error!" withMessage:@"The port is open but we can't seem to connect. Check that the camera model and credentials are correct."];
                
            }
            
        }
    }];
}

-(void)ShowMessageBoxWithMessage:(NSString*)message
{
    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [simpleAlert show];
}

- (void)isPortReachableDone:(BOOL)reachable {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (!reachable) {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"The IP address provided is not reachable at the port provided.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
    }
    
    NSString *jpgUrl = [self buildJpgUrlWithSlash:self.tfSnapshot.text];
    NSString *externalFullUrl = [self buildFullHttpUrl:self.tfExternalHost.text andPort:[self.tfExternalHttpPort.text integerValue]  andJpgUrl:jpgUrl withUsername:self.tfUsername.text andPassword:self.tfPassword.text];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.imageView setImageWithURLRequest:[self imageRequestWithURL:[NSURL URLWithString:externalFullUrl]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [self showImageView:image];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       NSLog(@"---- ERROR ---- %@", [error userInfo]);
                                       [self showImageView:nil];
                                   }];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSMutableURLRequest *)imageRequestWithURL:(NSURL *)url {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData; //NSURLRequestUseProtocolCachePolicy
    request.HTTPShouldHandleCookies = NO;
    request.HTTPShouldUsePipelining = YES;
    request.timeoutInterval = 10;
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    return request;
}


- (IBAction)add:(id)sender {                                                                    // finish and add
    
    BOOL ip = [self CheckIPAddress];
    if (ip) {               // provided ip is local/private ip-address so do nothing
        return;
    }
    
    cameraBuilder_AddMethod_Instance = [self buildCameraWithLocalCheck];
    if (cameraBuilder_AddMethod_Instance != nil) {
        if (!self.editCamera) {     // create camera
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // External URL Check
            NSString *externalHost  = cameraBuilder_AddMethod_Instance.externalHost;
            NSString *username      = cameraBuilder_AddMethod_Instance.cameraUsername;
            NSString *password      = cameraBuilder_AddMethod_Instance.cameraPassword;
            NSString *jpgUrlString  = [self buildJpgUrlWithSlash:cameraBuilder_AddMethod_Instance.jpgUrl];
            
            if (externalHost && externalHost.length > 0) {
                // External URL Check
                NSString *externalFullUrl = [self buildFullHttpUrl:externalHost andPort:cameraBuilder_AddMethod_Instance.externalHttpPort andJpgUrl:jpgUrlString withUsername:username andPassword:password];
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadImageWithURL:[NSURL URLWithString:externalFullUrl]
                                      options:0
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                         // progression tracking code
                                     }
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        if (image) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                [self createCamera:cameraBuilder_AddMethod_Instance withStatus:YES];
                                            });
                                        }
                                        else
                                        {
                                            // Internal URL Check
                                            NSString *internalHost  = cameraBuilder_AddMethod_Instance.internalHost;
                                            NSString *username      = cameraBuilder_AddMethod_Instance.cameraUsername;
                                            NSString *password      = cameraBuilder_AddMethod_Instance.cameraPassword;
                                            NSString *jpgUrlString  = [self buildJpgUrlWithSlash:cameraBuilder_AddMethod_Instance.jpgUrl];
                                            
                                            if (internalHost && internalHost.length > 0) {
                                                NSString *internalFullUrl = [self buildFullHttpUrl:internalHost andPort:cameraBuilder_AddMethod_Instance.externalHttpPort andJpgUrl:jpgUrlString withUsername:username andPassword:password];
                                                
                                                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                                                [manager downloadImageWithURL:[NSURL URLWithString:internalFullUrl]
                                                                      options:0
                                                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                         // progression tracking code
                                                                     }
                                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                        if (image) {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                                [self createCamera:cameraBuilder_AddMethod_Instance withStatus:YES];
                                                                            });
                                                                        }
                                                                        else
                                                                        {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                                                [self showWarningAlert:cameraBuilder_AddMethod_Instance with:sender];
                                                                            });
                                                                        }
                                                                    }];
                                            }
                                            else
                                            {
                                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                [self showWarningAlert:cameraBuilder_AddMethod_Instance with:sender];
                                            }
                                        }
                                    }];
            }
            else
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self showWarningAlert:cameraBuilder_AddMethod_Instance with:sender];
            }
        } else { // patch camera
            [self patchCamera:cameraBuilder_AddMethod_Instance];
        }
    }
}

-(void)showWarningAlert:(EvercamCameraBuilder *)cameraBuilder_Local with:(id)sender{
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"We can't connect to your camera, are you sure want to add it?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 56;
        [alert show];
    }else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Warning"
                                      message:@"We can't connect to your camera, are you sure want to add it?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* no = [UIAlertAction
                             actionWithTitle:@"No"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction* yes = [UIAlertAction
                              actionWithTitle:@"Yes"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  [self createCamera:cameraBuilder_Local withStatus:NO];
                              }];
        
        [alert addAction:no];
        [alert addAction:yes];
        if ([GlobalSettings sharedInstance].isPhone)
        {
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            UIPopoverPresentationController *popPresenter = [alert
                                                             popoverPresentationController];
            popPresenter.sourceView = (UIView *)sender;
            popPresenter.sourceRect = ((UIView *)sender).bounds;
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}


- (IBAction)selectMake:(id)sender {
    if (self.vendorsNameArray == nil || self.vendorsNameArray.count <= 0) {
        return;
    }
    //    if (self.vendorsArray == nil || self.vendorsArray.count <= 0)
    //        return;
    
    [self.focusedTextField resignFirstResponder];
    
    NSArray * arrImage = [[NSArray alloc] init];
    
    if (modelDropDown)
    {
        [modelDropDown hideDropDown:(UIButton*)self.tfModel];
        modelDropDown = nil;
    }
    
    if(vendorDropDown == nil) {
        CGFloat f = self.scrollView.frame.size.height - ((UIButton*)sender).frame.origin.y - ((UIButton*)sender).frame.size.height;
        CGFloat h = (self.vendorsNameArray.count * DropDownCellHeight);
        
        vendorDropDown = [[NIDropDown alloc] showDropDown:sender height:(h<=f?&h: &f) textArray:self.vendorsNameArray imageArray:arrImage direction:@"down"] ;
        vendorDropDown.delegate = self;
    }
    else {
        [vendorDropDown hideDropDown:sender];
        vendorDropDown = nil;
    }
    
}

- (IBAction)selectModel:(id)sender {
    if (self.modelsArray == nil || self.modelsArray.count <= 0)
        return;
    
    [self.focusedTextField resignFirstResponder];
    
    NSArray * arrImage = [[NSArray alloc] init];
    
    if (vendorDropDown)
    {
        [vendorDropDown hideDropDown:(UIButton*)self.tfVendor];
        vendorDropDown = nil;
    }
    
    if(modelDropDown == nil) {
        CGFloat f = self.scrollView.frame.size.height - ((UIButton*)sender).frame.origin.y - ((UIButton*)sender).frame.size.height;
        CGFloat h = (self.modelsNameArray.count * DropDownCellHeight);
        
        modelDropDown = [[NIDropDown alloc] showDropDown:sender height:(h<=f?&h: &f) textArray:self.modelsNameArray imageArray:arrImage direction:@"down"] ;
        modelDropDown.delegate = self;
    }
    else {
        [modelDropDown hideDropDown:sender];
        modelDropDown = nil;
    }
}


#pragma mark - UITextField Delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.focusedTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITapGesture Recognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.focusedTextField resignFirstResponder];
    if (modelDropDown)
    {
        [modelDropDown hideDropDown:(UIButton*)self.tfModel];
        modelDropDown = nil;
    }
    if (vendorDropDown)
    {
        [vendorDropDown hideDropDown:(UIButton*)self.tfVendor];
        vendorDropDown = nil;
    }
    
}

#pragma mark - SelectModelViewController Delegate Method
- (void)modelChanged:(EvercamModel *)model {
    self.currentModel = model;
    self.tfModel.text = self.currentModel.name;
    if (self.editCamera == nil) {
        self.tfUsername.text = self.currentModel.defaults.authUsername;
        self.tfPassword.text = self.currentModel.defaults.authPassword;
        self.tfSnapshot.text = self.currentModel.defaults.jpgURL;
    }
}

#pragma mark - SelectVendorViewController Delegate Method
- (void)vendorChanged:(EvercamVendor *)vendor {
    self.currentVendor = vendor;
    self.tfVendor.text = self.currentVendor.name;
    
    [self getAllModelsWithCompletion:^(NSError *error) {
        
    }];
}

#pragma mark - Custom Functions
- (void)initializeScreen {
    if (self.editCamera) {
        self.titleLabel.text    = @"Edit Camera";
        self.tfID.enabled       = NO;
        self.cameraView.hidden  = false;
        CGRect frame            = self.cameraView.frame;
        [self reFrameViews:viewsArray initialFrame:frame];
        [self.addButton setTitle:@"Save Changes" forState:UIControlStateNormal];
        
        self.tfID.text          = self.editCamera.camId;
        self.tfName.text        = self.editCamera.name;
        self.tfUsername.text    = self.editCamera.username;
        if (![self.editCamera.password isKindOfClass:[NSNull class]])
        {
            self.tfPassword.text = self.editCamera.password;
        }
        self.tfSnapshot.text        = [self.editCamera getJpgPath];
        self.tfExternalHost.text    = self.editCamera.externalHost;
        self.tfInternalHost.text    = self.editCamera.internalHost;

        if (self.editCamera.externalHttpPort != 0) {
            self.tfExternalHttpPort.text = [NSString stringWithFormat:@"%d", self.editCamera.externalHttpPort];
        }
        if (self.editCamera.externalRtspPort != 0) {
            self.tfExternalRtspPort.text = [NSString stringWithFormat:@"%d", self.editCamera.externalRtspPort];
        }
        if (self.editCamera.internalHttpPort != 0) {
            self.tfInternalHttpPort.text = [NSString stringWithFormat:@"%d", self.editCamera.internalHttpPort];
        }
        if (self.editCamera.internalRtspPort != 0) {
            self.tfInternalRtspPort.text = [NSString stringWithFormat:@"%d", self.editCamera.internalRtspPort];
        }
        if (self.editCamera.externalH264Url != 0) {
            self.tfExternalRtspUrl.text = [NSString stringWithFormat:@"%@", [self.editCamera getRTSPUrl]];
        }
    }
    else{
        
        [self reFrameViews:viewsArray initialFrame:self.cameraView.frame];
        [self getCameraName];
        [self populateIPTextField];
    }
}

- (EvercamCameraBuilder *)buildCameraWithLocalCheck {
    EvercamCameraBuilder *cameraBuilder = nil;
    NSString *cameraID = self.tfID.text;
    NSString *cameraName = self.tfName.text;
    
    cameraBuilder = [[EvercamCameraBuilder alloc] initWithCameraId:cameraID andCameraName:cameraName andIsPublic:NO];
    
    if (self.currentVendor) {
        cameraBuilder.vendor = self.currentVendor.vId;
    }
    if (self.currentModel) {
        cameraBuilder.model = self.currentModel.mId;
    }
    if (self.tfUsername.text.length > 0) {
        cameraBuilder.cameraUsername = self.tfUsername.text;
    }
    if (self.tfPassword.text.length > 0) {
        cameraBuilder.cameraPassword = self.tfPassword.text;
    }
    if (self.tfExternalRtspUrl.text.length > 0) {
        cameraBuilder.h264Url = self.tfExternalRtspUrl.text;
    }
    
    NSString *externalHost = self.tfExternalHost.text;
    NSString *internalHost = self.tfInternalHost.text;
    if (externalHost.length == 0 && internalHost.length == 0) {
        
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"Please specify either an internal or external IP address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        
        return nil;
    }
    if (internalHost.length > 0) {
        cameraBuilder.internalHost = internalHost;
        
        NSString *internalHttp = self.tfInternalHttpPort.text;
        if (internalHttp.length > 0) {
            NSInteger internalHttpPort = [internalHttp integerValue];
            if (internalHttpPort != 0) {
                cameraBuilder.internalHttpPort = internalHttpPort;
            } else {
                UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"Please specify either an internal HTTP port." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [simpleAlert show];
                
                return nil;
            }
        }
        
        NSString *internalRtsp = self.tfInternalRtspPort.text;
        if (internalRtsp.length > 0) {
            NSInteger internalRtspPort = [internalRtsp integerValue];
            if (internalRtspPort != 0) {
                cameraBuilder.internalRtspPort = internalRtspPort;
            } else {
                UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"Please specify either an internal RTSP port." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [simpleAlert show];
                
                return nil;
            }
        }
    }
    if (externalHost.length > 0) {
        cameraBuilder.externalHost = externalHost;
        
        NSString *externalHttp = self.tfExternalHttpPort.text;
        if (externalHttp.length > 0) {
            NSInteger externalHttpPort = [externalHttp integerValue];
            if (externalHttpPort != 0) {
                cameraBuilder.externalHttpPort = externalHttpPort;
            } else {
                UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"Please specify either an external HTTP port." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [simpleAlert show];
                
                return nil;
            }
        }
        
        NSString *externalRtsp = self.tfExternalRtspPort.text;
        if (externalRtsp.length > 0) {
            NSInteger externalRtspPort = [externalRtsp integerValue];
            if (externalRtspPort != 0) {
                cameraBuilder.externalRtspPort = externalRtspPort;
            } else {
                UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"Please specify either an external RTSP port." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [simpleAlert show];
                
                return nil;
            }
        }
    }
    
    NSString *jpgUrl = [self buildJpgUrlWithSlash:self.tfSnapshot.text];
    if (jpgUrl.length > 0) {
        cameraBuilder.jpgUrl = jpgUrl;
    }
    
    return cameraBuilder;
}

- (NSString *)buildJpgUrlWithSlash:(NSString *)originalJpgUrl {
    NSString *jpgUrl = @"";
    if (originalJpgUrl != nil && originalJpgUrl.length > 0) {
        if (![originalJpgUrl hasPrefix:@"/"]) {
            jpgUrl = [NSString stringWithFormat:@"/%@", originalJpgUrl];
        } else {
            jpgUrl = originalJpgUrl;
        }
    }
    
    return jpgUrl;
}

- (NSString *)buildFullHttpUrl:(NSString *)host andPort:(NSInteger)port andJpgUrl:(NSString *)jpgUrl withUsername:(NSString *)username andPassword:(NSString *)password
{
    if (port == 0) {
        if (username.length == 0) {
            return [NSString stringWithFormat:@"http://%@:80%@", host, jpgUrl];
        }
        return [NSString stringWithFormat:@"http://%@:%@@%@:80%@", username, password, host, jpgUrl];
    } else {
        if (username.length == 0) {
            return [NSString stringWithFormat:@"http://%@:%ld%@", host, (long)port, jpgUrl];
        }
        return [NSString stringWithFormat:@"http://%@:%@@%@:%ld%@", username, password, host, (long)port, jpgUrl];
    }
}

- (void)createCamera:(EvercamCameraBuilder *)cameraBuilder withStatus:(BOOL)status {
    //Set is_online=true for all new cameras as temorary fix of https://github.com/evercam/evercam-play-android/issues/133
    cameraBuilder.isOnline = true;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EvercamShell shell] createCamera:cameraBuilder withBlock:^(EvercamCamera *camera, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            
            camera.isOnline = status;
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_add_camera
                                                                  action:action_addcamera_success_manual
                                                                   label:label_addcamera_successful_manual
                                                                   value:nil] build]];
            
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel identify:[APP_DELEGATE getDefaultUser].username];
            [mixpanel track:mixpanel_event_create_camera properties:@{
                                                                      @"Client-Type": @"Play-iOS",
                                                                      @"Camera ID" : camera.camId
                                                                      }];
            camera_CreateCameraMethod_Instance = camera;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"Camera created" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag           = 58;
                [alert show];
            }
            else
            {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Camera created"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self.navigationController popViewControllerAnimated:YES];
                                         
                                         if ([self.delegate respondsToSelector:@selector(cameraAdded:)]) {
                                             [self.delegate cameraAdded:camera];
                                         }
                                     }];
                [alert addAction:ok];
                
                if ([GlobalSettings sharedInstance].isPhone)
                {
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    UIPopoverPresentationController *popPresenter = [alert
                                                                     popoverPresentationController];
                    popPresenter.sourceView = self.view;
                    popPresenter.sourceRect = self.view.bounds;
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        } else {
            
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [simpleAlert show];
            
            return;
        }
    }];
}

- (void)patchCamera:(EvercamCameraBuilder *)cameraBuilder {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EvercamShell shell] patchCamera:cameraBuilder withBlock:^(EvercamCamera *camera, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            camera_PatchMethod_Instance = camera;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"Settings updated successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag           = 57;
                [alert show];
            }
            else
            {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Settings updated successfully!"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self.navigationController popViewControllerAnimated:YES];
                                         
                                         if ([self.delegate respondsToSelector:@selector(cameraEdited:)]) {
                                             [self.delegate cameraEdited:camera];
                                         }
                                     }];
                [alert addAction:ok];
                
                if ([GlobalSettings sharedInstance].isPhone)
                {
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    UIPopoverPresentationController *popPresenter = [alert
                                                                     popoverPresentationController];
                    popPresenter.sourceView = self.view;
                    popPresenter.sourceRect = self.view.bounds;
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        } else {
            
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [simpleAlert show];
            
            return;
        }
    }];
}

- (void)showImageView:(UIImage *)image {
    if (image) {
        self.imageContainer.hidden = NO;
        CGFloat width = self.testInsideView.frame.size.width;
        CGFloat imgHeight = image.size.height*width/image.size.width;
        
        self.testInsideView.frame = CGRectMake(self.testInsideView.frame.origin.x,
                                               self.testInsideView.frame.origin.y,
                                               self.testInsideView.frame.size.width,
                                               imgHeight + 41.0);
        
        self.imageView.image = image;
        
    } else {
        //Remove alert "The port and URL are open but" issue #40 on git
    }
}

- (void)getAllVendors {
    [self.vendorsNameArray removeAllObjects];
    [self.vendorsNameArray insertObject:@"Unknown/Other" atIndex:0];
    
    [[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
        NSArray *arr = [vendors sortedArrayUsingComparator:^NSComparisonResult(EvercamVendor *v1, EvercamVendor *v2) {
            return [v1.name caseInsensitiveCompare:v2.name];
        }];
        
        self.vendorsArray = [[NSMutableArray alloc] initWithArray:arr];
        NSLog(@"%@",self.vendorsArray);
        
        for (EvercamVendor *vendor in self.vendorsArray)
        {
            [self.vendorsNameArray addObject:[vendor.name copy]];
        }
        if (self.editCamera) {
            self.currentVendor = [self getVendorWithName:self.editCamera.vendor];
            if (self.currentVendor) {
                self.tfVendor.text = self.currentVendor.name;
                [self getAllModelsWithCompletion:^(NSError *error) {
                    [self setCameraImage];
                }];
            }
        }
    }];
}

- (void)getAllModelsWithCompletion:(void (^)(NSError *error))block {
    
    self.modelsArray = nil;
    if (self.currentVendor) {
        [[EvercamShell shell] getAllModelsByVendorId:self.currentVendor.vId withBlock:^(NSArray *models, NSError *error) {
            self.modelsArray = [models sortedArrayUsingComparator:^NSComparisonResult(EvercamModel *m1, EvercamModel *m2) {
                return [m1.name caseInsensitiveCompare:m2.name];
            }];
            
            [self.modelsNameArray removeAllObjects];
            for (EvercamModel *model in self.modelsArray)
                [self.modelsNameArray addObject:[model.name copy]];
            
            if (self.editCamera) {
                if (self.tfModel.text.length == 0) {
                    self.currentModel = [self getModelWithName:self.editCamera.model];
                    self.tfModel.text = self.currentModel.name;
                    if (block) {
                        block(nil);
                    }
                    return;
                }
            }
            
            self.currentModel = [self getModelWithName:@"Default"];
            if (self.currentModel) {
                self.tfModel.text = self.currentModel.name;
                [self setCameraImage];
                if (self.editCamera == nil) {
                    self.tfUsername.text = ([self.currentModel.defaults.authUsername isKindOfClass:[NSNull class]])?@"":self.currentModel.defaults.authUsername;
                    self.tfPassword.text = ([self.currentModel.defaults.authPassword isKindOfClass:[NSNull class]])?@"":self.currentModel.defaults.authPassword;
                    self.tfSnapshot.text = ([self.currentModel.defaults.jpgURL isKindOfClass:[NSNull class]])?@"":self.currentModel.defaults.jpgURL;
                }
            }
            NSLog(@"%@",self.modelsArray);
            if (block) {
                block(nil);
            }
        }];
    }
}

- (EvercamVendor *)getVendorWithName:(NSString *)vendorName {
    
    if ([vendorName isEqualToString:@"Unknown/Other"]) {
        return nil;
    }
    
    for (EvercamVendor *vendor in self.vendorsArray) {
        if ([vendor.name isEqualToString:vendorName]) {
            return vendor;
        }
    }
    
    return nil;
}

- (EvercamModel *)getModelWithName:(NSString *)modelName {
    if ([modelName isEqualToString:@"Unknown/Other"]) {
        return nil;
    }
    
    for (EvercamModel *model in self.modelsArray) {
        if ([model.name isEqualToString:modelName]) {
            return model;
        }
    }
    
    return nil;
}
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [self isPortReachableDone:TRUE];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"socketDidSecure:%p", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socketDidSecure:%p", sock);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    if (err != nil)
    {
        [self isPortReachableDone:FALSE];
    }
}



#pragma mark NIDropdown delegate
- (void) niDropDown:(NIDropDown*)dropdown didSelectAtIndex:(NSInteger)index
{
    if (dropdown == vendorDropDown)
    {
        vendorDropDown = nil;
        if (index == 0) {
            self.currentVendor = nil;
            self.currentModel = nil;
            self.tfVendor.text = @"Unknown/Other";
            self.tfModel.text = @"Unknown/Other";
            self.snapshotView.hidden = false;
            self.rtstURLView.hidden = false;
            [self reFrameViews:viewsArray initialFrame:self.cameraView.frame];
            [self ClearFields];
            [self getCameraName];
            self.thumbImageView.image = [UIImage imageNamed:@"cam.png"];
            return;
        }
        [self reFrameViews:minViewsArray initialFrame:self.cameraView.frame];
        self.currentVendor = self.vendorsArray[index-1];
        NSLog(@"Current Vendor: %@", self.currentVendor);
        self.snapshotView.hidden = true;
        self.rtstURLView.hidden = true;
        
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self getAllModelsWithCompletion:^(NSError *error) {
            
        }];
        
        self.tfVendor.text = self.currentVendor.name;
        
    }
    else if (dropdown == modelDropDown)
    {
        modelDropDown = nil;
        self.currentModel = self.modelsArray[index];
        NSLog(@"Current Model: %@", self.currentModel);
        
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSURLRequest* request = [self imageRequestWithURL:[NSURL URLWithString:self.currentModel.thumbUrl]];
        
        [self.thumbImageView setImageWithURLRequest:request placeholderImage:nil
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                self.thumbImageView.image = image;
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                NSLog(@"---- THUMBNAIL ERROR ---- %@", [error userInfo]);
                                            }];
        
        
        self.tfModel.text = self.currentModel.name;
        if (self.editCamera == nil) {
            self.tfUsername.text = self.currentModel.defaults.authUsername;
            self.tfPassword.text = self.currentModel.defaults.authPassword;
            self.tfSnapshot.text = self.currentModel.defaults.jpgURL;
        }
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

-(void)setCameraImage
{
    //----------set vendor logo-------------
    NSString* vendorImagePath = self.currentVendor.logoUrl;
    NSURL *vendorImageUrl = [NSURL URLWithString:vendorImagePath];
    
    [self downloadImageWithURL:vendorImageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            self.logoImageView.image = image;
            CGFloat desiredHeight = .12 * self.logoImagesContainer.frame.size.height;
            CGFloat desiredWidth = .8 * self.logoImagesContainer.frame.size.width;
            
            CGFloat heightScaleFactor = image.size.height/desiredHeight;
            CGFloat widthScaleFactor = image.size.width/desiredWidth;
            
            CGFloat imageViewWidth;
            CGFloat imageViewHeight;
            
            if (widthScaleFactor > heightScaleFactor) {
                imageViewWidth = image.size.width / widthScaleFactor;
                imageViewHeight = image.size.height / widthScaleFactor;
            }
            else {
                imageViewWidth = image.size.width / heightScaleFactor;
                imageViewHeight = image.size.height / heightScaleFactor;
            }
            self.logoImageView.frame = CGRectMake(2, 2, imageViewWidth, imageViewHeight);
        }
    }];
    
    //----------set default model image-------------
    if (!self.editCamera) {
        self.currentModel = self.modelsArray[0];
    }
    
    NSLog(@"Current Model: %@", self.currentModel);
    
    NSString* modelImagePath = self.currentModel.thumbUrl;
    NSURL *modelImageUrl = [NSURL URLWithString:modelImagePath];
    
    [self downloadImageWithURL:modelImageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            self.thumbImageView.image = image;
        }
    }];
    
}

#pragma mark UIAlertViewDelegate - Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101 && buttonIndex == 1) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if (alertView.tag == 56 && buttonIndex == 1){
        
        [self createCamera:cameraBuilder_AddMethod_Instance withStatus:NO];
        
    }else if (alertView.tag == 57 && buttonIndex == 0){
        
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(cameraEdited:)]) {
            [self.delegate cameraEdited:camera_PatchMethod_Instance];
        }
    }else if (alertView.tag == 58 && buttonIndex == 0){
        [self.navigationController popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(cameraAdded:)]) {
            [self.delegate cameraAdded:camera_CreateCameraMethod_Instance];
        }
    }
}

#pragma mark - Methods by Musaab

-(BOOL)isStringEmpty:(NSString*)text {
    if([text isEqualToString:@""]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (IBAction)textFieldsDidChanged:(UITextField*)sender {
    if (sender.tag == 1) {
        self.httpPortStatusLabel.text = @"";
        [self httpPortCheckTimerStarter];
    }
    
    if (sender.tag == 2) {
        self.rtspPortStatusLabel.text = @"";
        [self rtspPortCheckTimerStarter];
    }
    
    if (sender.tag == 3) {
        self.httpPortStatusLabel.text = @"";
        self.rtspPortStatusLabel.text = @"";
        [self httpPortCheckTimerStarter];
        [self rtspPortCheckTimerStarter];
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

- (IBAction)httpTextFieldDidEndEdition:(id)sender {
    [self httpPortCheckTimerStarter];
}


- (IBAction)rtspTextFieldDidEndEdition:(id)sender {
    [self rtspPortCheckTimerStarter];
}

-(void)checkRtstPort{
    NSString* ipAddress = [self.tfExternalHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* rtspPort = self.tfExternalRtspPort.text;
    
    if(isCompletelyEmpty(rtspPort) || isCompletelyEmpty(ipAddress))
    {
        self.rtspPortStatusLabel.text = @"";
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"%@address=%@&port=%@",[SharedManager getCheckPortUrl],ipAddress,rtspPort];
    
    
//    NSDictionary *params = @{@"ip": ipAddress, @"port": rtspPort};
    
    [self checkPortWithUrl:url withParameters:nil withTextField:self.tfExternalRtspPort withLabel:self.rtspPortStatusLabel];
}

-(void)checkHttpPort{
    NSString* ipAddress = [self.tfExternalHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* httpPort = self.tfExternalHttpPort.text;
    
    if(isCompletelyEmpty(httpPort) || isCompletelyEmpty(ipAddress))
    {
        self.httpPortStatusLabel.text = @"";
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"%@address=%@&port=%@",[SharedManager getCheckPortUrl],ipAddress,httpPort];
    
//    NSDictionary *params = @{@"ip": ipAddress, @"port": httpPort};
    
    [self checkPortWithUrl:url withParameters:nil withTextField:self.tfExternalHttpPort withLabel:self.httpPortStatusLabel];
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


- (IBAction)ipTextFieldDidEndEdition:(id)sender {
    [self CheckIPAddress];
    if (self.tfExternalRtspPort.text != nil) {
        [self rtspTextFieldDidEndEdition:nil];
    }
    else{
        self.rtspPortStatusLabel.text = @"";
    }
    
    if (self.tfExternalHttpPort.text != nil) {
        [self httpTextFieldDidEndEdition:nil];
    }
    else{
        self.httpPortStatusLabel.text = @"";
    }
}

- (IBAction)tfUserNameDidBeginEditing:(id)sender {
    userName = self.tfUsername.text;
    self.tfPassword.text = @"";
}

- (IBAction)tfUserNameDidEndEditing:(id)sender {
    if (userName != self.tfUsername.text) {
        
    }
}

-(BOOL)CheckIPAddress
{
    NSString *string = self.tfExternalHost.text;
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


-(void)getCameraName
{
    [[EvercamShell shell] getAllCameras:[APP_DELEGATE defaultUser].username includeShared:YES includeThumbnail:YES withBlock:^(NSArray *cameras, NSError *error) {
        if (error == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                int count = 1;
                
                for (int counter = 0; counter<cameras.count; counter++) {
                    NSString* cameraName = [NSString stringWithFormat:@"Camera %d",count];
                    
                    for (EvercamCamera *camera in cameras) {
                        if ([camera.name  isEqual: cameraName]) {
                            count += 1;
                            break;
                        }
                    }
                }
                self.tfName.text = [NSString stringWithFormat:@"Camera %d",count];
            });
        }
        else
        {
            NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ops!" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
            });
        }
    }];
    
}



- (void)populateIPTextField {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
    }
    else if (status == ReachableViaWiFi)
    {
        [self GetIP];
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
    }
}

-(void)ClearFields
{
    self.tfSnapshot.text = @"";
    self.tfUsername.text = @"";
    self.tfPassword.text = @"";
    self.tfExternalRtspUrl.text = @"";
    self.thumbImageView.image = nil;
    self.logoImageView.image = nil;
    self.tfExternalHttpPort.text = @"";
    self.httpPortStatusLabel.text = @"";
    self.tfExternalRtspPort.text = @"";
    self.rtspPortStatusLabel.text = @"";
}

- (void)GetIP
{
    
    NSString* url = [SharedManager getIPUrl];
    
    [SharedManager get:url params:nil callback:^(NSString *status, NSMutableDictionary *responseDict) {
        if([status isEqualToString:@"error"])
        {
            NSLog(@"No any response from server");
            return;
        }
        self.tfExternalHost.text = responseDict[@"JSON"];
    }];
}


-(void)reFrameViews:(NSMutableArray*)Views initialFrame:(CGRect)frame
{
    if (self.editCamera)
    {
        frame.origin.y += VIEWMARGIN;
    }
    for (int index=0; index<Views.count; index++) {
        UIView* view =  Views[index];
        view.frame = frame;
        frame.origin.y += VIEWMARGIN;
    }
    CGRect newFrame = self.addButton.frame;
    newFrame.origin.y = frame.origin.y + VIEWMARGIN - 10;
    self.addButton.frame = newFrame;
    
    newFrame = self.testButton.frame;
    newFrame.origin.y = frame.origin.y + VIEWMARGIN - 10;
    self.testButton.frame = newFrame;
}

- (IBAction)remove_Message_View:(id)sender {
    self.success_Message_View.hidden = YES;
}
@end
