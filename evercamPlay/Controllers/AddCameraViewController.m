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
#import "ActionSheetPicker.h"
#import "UIImageView+WebCache.h"
#import "EvercamUtility.h"
#import "EvercamCreateCamera.h"


#define VIEWMARGIN 35

@interface AddCameraViewController () <SelectVendorViewControllerDelegate, SelectModelViewControllerDelegate>
{
    UITextField *statusLabel;
    NSString* userName;
    NSMutableArray *viewsArray;
    NSMutableArray *minViewsArray;
    
    EvercamCameraBuilder    *cameraBuilder_AddMethod_Instance;
    __block EvercamCamera   *camera_PatchMethod_Instance;
    __block EvercamCamera   *camera_CreateCameraMethod_Instance;
    
    
    NSTimer *httpPortCheckTimer;
    NSTimer *rtspPortCheckTimer;
    
    NSMutableArray *modelsObjectArray;
    
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
    
    [self getAllVendors];
    [self setTextFieldsPlaceHolder];
    self.tfExternalHttpPort.placeholder = @"80";
    self.tfExternalRtspPort.placeholder = @"554";
    [self initializeScreen];
    
    self.vendorsNameArray = [NSMutableArray array];
    self.modelsNameArray = [NSMutableArray array];
    
    
    [self checkHttpPort];
    [self checkRtstPort];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    
}

-(void)setTextFieldsPlaceHolder{
    /*
    if ([self.tfID respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [AppUtility colorWithHexString:@"C7C7CD"];
        self.tfID.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"roof-cam" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfVendor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Unknown/Other" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfModel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Unknown/Other" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfSnapshot.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"/snapshot.jpg" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalHost.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"149.5.43.10" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalHttpPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"80" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalRtspPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"554" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalRtspUrl.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"/h264/ch1/mail/av_stream" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    */
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
            self.tfExternalRtspPort.text.length > 0) {
            
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
    [self checkHttpPort];
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
    
    NSString *jpg_Url = (!self.currentModel)?self.tfSnapshot.text:self.currentModel.defaults.jpgURL;
    NSString *vendorId = (!self.currentVendor)?@"":self.currentVendor.vId;
    
    if ([self.httpPortStatusLabel.text isEqualToString:@"Port is closed"]) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"The IP address provided is not reachable at the port provided."];
        return;
    }
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://%@:%@",ipAddress,httpPort],@"external_url",jpg_Url,@"jpg_url",self.tfUsername.text,@"cam_username",self.tfPassword.text,@"cam_password",vendorId,@"vendor_id", nil];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EvercamTestSnapShot *api_snap_Obj = [EvercamTestSnapShot new];
    [api_snap_Obj testSnapShot:postDictionary withBlock:^(UIImage *snapeImage, NSString *statusMessage, NSError *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self displayErrorAlert:@"Error!" withMessage:@"The port is open but we can't seem to connect. Check that the camera model and credentials are correct."];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([statusMessage isEqualToString:@"Success"]) {
                self.success_Message_View.hidden    = NO;
                self.blackTransparentView.hidden    = NO;
                self.test_SnapShot_ImageView.image  = snapeImage;
            }else{
                
                [self displayErrorAlert:@"Error!" withMessage:@"The port is open but we can't seem to connect. Check that the camera model and credentials are correct."];
                
            }
            
        }
    }];
}



- (IBAction)add:(id)sender {
    
    BOOL ip = [self CheckIPAddress];
    if (ip) {               // provided ip is local/private ip-address so do nothing
        return;
    }
    
    if (isCompletelyEmpty(self.tfName.text)) {
        [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Please specify a friendly name for your camera."];
        return;
    }
    
    if (isCompletelyEmpty(self.tfExternalHost.text)) {
        [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Please specify IP address or URL."];
        return;
    }
    
    if (isCompletelyEmpty(self.tfExternalHttpPort.text)) {
        [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Please specify HTTP port."];
        return;
    }
    
    
    NSDictionary *param_Dictionary;
    if (![self.currentVendor.vId isEqualToString:@"other"]) {
        param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.tfID.text,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSDictionary dictionaryWithObjectsAndKeys:self.currentVendor.vId,@"vendor",self.currentModel.mId,@"model",self.tfExternalHost.text,@"external_host",self.tfExternalHttpPort.text,@"external_http_port",self.currentModel.defaults.jpgURL,@"jpg_url",(isCompletelyEmpty(self.tfExternalRtspPort.text))?@"":self.tfExternalRtspPort.text,@"external_rtsp_port",self.tfName.text,@"name",(isCompletelyEmpty(self.tfUsername.text))?@"":self.tfUsername.text,@"cam_username",(isCompletelyEmpty(self.tfPassword.text))?@"":self.tfPassword.text,@"cam_password", nil],@"Post_Param", nil];
    }else{
        param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.tfID.text,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSDictionary dictionaryWithObjectsAndKeys:self.tfExternalHost.text,@"external_host",self.tfExternalHttpPort.text,@"external_http_port",self.currentModel.mId,@"model",self.currentVendor.vId,@"vendor",self.tfSnapshot.text,@"jpg_url",(isCompletelyEmpty(self.tfExternalRtspPort.text))?@"":self.tfExternalRtspPort.text,@"external_rtsp_port",(isCompletelyEmpty(self.tfExternalRtspUrl.text))?@"":self.tfExternalRtspUrl.text,@"mjpg_url",self.tfName.text,@"name",(isCompletelyEmpty(self.tfUsername.text))?@"":self.tfUsername.text,@"cam_username",(isCompletelyEmpty(self.tfPassword.text))?@"":self.tfPassword.text,@"cam_password", nil],@"Post_Param", nil];
    }
    
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EvercamCreateCamera *api_Edit_Obj = [EvercamCreateCamera new];
    [api_Edit_Obj EditCamera:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSArray *cameraObjectArray = details[@"cameras"];
            camera_PatchMethod_Instance = [[EvercamCamera alloc] initWithDictionary:cameraObjectArray[0]];
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"Settings updated successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag           = 57;
            [alert show];
            
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}


-(void)getCameraModel:(NSString *)vendorId{
    [modelsObjectArray removeAllObjects];
    [[EvercamShell shell] getAllModelsByVendorId:vendorId withBlock:^(NSArray *models, NSError *error) {
        if (!error) {
            
            modelsObjectArray = [models mutableCopy];
            //Sort evercammodel object array by name
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            modelsObjectArray=[[modelsObjectArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            
            
            self.currentModel = [self getModelWithName:self.editCamera.model];
            self.tfModel.text = self.currentModel.name;
            
            [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:self.currentModel.thumbUrl] placeholderImage:[UIImage imageNamed:@"cam.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (self.currentVendor == nil) {
                    self.thumbImageView.image = [UIImage imageNamed:@"cam.png"];
                }
            }];
            self.view.userInteractionEnabled = YES;
            
        }else{
            self.view.userInteractionEnabled = YES;
        }
    }];
    
}

-(void)getCameraModelForSelectedVendor:(NSString *)vendorId{
    [modelsObjectArray removeAllObjects];
    [[EvercamShell shell] getAllModelsByVendorId:vendorId withBlock:^(NSArray *models, NSError *error) {
        if (!error) {
            if ([vendorId isEqualToString:@"other"]) {
                modelsObjectArray = [models mutableCopy];
                self.currentModel = modelsObjectArray[0];
            }else{
                modelsObjectArray = [models mutableCopy];
                //Sort evercammodel object array by name
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                modelsObjectArray=[[modelsObjectArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                NSArray *filteredArray = [modelsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",@"Default"]];
                
                self.currentModel = filteredArray[0];
                
                self.tfModel.text = self.currentModel.name;
                
                [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:self.currentModel.thumbUrl] placeholderImage:[UIImage imageNamed:@"cam.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (self.currentVendor == nil) {
                        self.thumbImageView.image = [UIImage imageNamed:@"cam.png"];
                    }
                }];
            }

            self.view.userInteractionEnabled = YES;
            
        }else{
            self.view.userInteractionEnabled = YES;
        }
    }];
}

- (IBAction)selectMake:(id)sender {
    if (self.vendorsNameArray == nil || self.vendorsNameArray.count <= 0) {
        return;
    }
    
    [self.focusedTextField resignFirstResponder];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Vendors" rows:self.vendorsNameArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
        
        if ([selectedValue isEqualToString:@"Unknown/Other"] || [selectedValue isEqualToString:@"Other"]) {
            if ([selectedValue isEqualToString:@"Unknown/Other"]) {
                NSArray *filteredArray = [self.vendorsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(vId == %@)",@"other"]];
                self.currentVendor = filteredArray[0];
            }else{
                self.currentVendor = self.vendorsArray[selectedIndex-1];
            }
            
            [self getCameraModelForSelectedVendor:self.currentVendor.vId];

            self.tfVendor.text          = selectedValue;
            self.tfModel.text           = selectedValue;
            self.snapshotView.hidden    = false;
            self.rtstURLView.hidden     = false;
            [self reFrameViews:viewsArray initialFrame:self.cameraView.frame];
            self.thumbImageView.image   = [UIImage imageNamed:@"cam.png"];
            self.logoImageView.image    = nil;
            [self.tfModel setTextColor:[AppUtility colorWithHexString:@"B9B9B9"]];
            self.modelBtn.enabled       = NO;
            
        }else{
            [self reFrameViews:minViewsArray initialFrame:self.cameraView.frame];
            self.currentVendor = self.vendorsArray[selectedIndex-1];
            self.snapshotView.hidden = true;
            self.rtstURLView.hidden = true;
            self.modelBtn.enabled = YES;
            [self getCameraModelForSelectedVendor:self.currentVendor.vId];
            [self.tfModel setTextColor:[UIColor blackColor]];
            [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.currentVendor.logoUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (self.currentVendor == nil) {
                    self.logoImageView.image = nil;
                }
            }];
            self.tfVendor.text = self.currentVendor.name;
        }
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
}

- (IBAction)selectModel:(id)sender {
    
    if (modelsObjectArray == nil || modelsObjectArray.count <= 0) {
        return;
    }
    
    [self.focusedTextField resignFirstResponder];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Models" rows:[modelsObjectArray valueForKey:@"name"] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
        
        self.currentModel = modelsObjectArray[selectedIndex];
        
        [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:self.currentModel.thumbUrl] placeholderImage:[UIImage imageNamed:@"cam.png"]];
        
        self.tfModel.text       = self.currentModel.name;
        self.tfUsername.text    = self.currentModel.defaults.authUsername;
        self.tfPassword.text    = self.currentModel.defaults.authPassword;
        
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
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
        
        [self.addButton setTitle:@"SAVE CHANGES" forState:UIControlStateNormal];
        
        self.tfID.text          = self.editCamera.camId;
        self.tfName.text        = self.editCamera.name;
        self.tfUsername.text    = self.editCamera.username;
        if (![self.editCamera.password isKindOfClass:[NSNull class]])
        {
            self.tfPassword.text = self.editCamera.password;
        }
        self.tfSnapshot.text        = [self.editCamera getJpgPath];
        self.tfExternalHost.text    = self.editCamera.externalHost;
        
        if (self.editCamera.externalHttpPort != 0) {
            self.tfExternalHttpPort.text = [NSString stringWithFormat:@"%d", self.editCamera.externalHttpPort];
        }
        if (self.editCamera.externalRtspPort != 0) {
            self.tfExternalRtspPort.text = [NSString stringWithFormat:@"%d", self.editCamera.externalRtspPort];
        }
        
        if (self.editCamera.externalH264Url != 0) {
            self.tfExternalRtspUrl.text = [NSString stringWithFormat:@"%@", [self.editCamera getRTSPUrl]];
        }
        
        if ([self.editCamera.vendor isEqualToString:@"Other"]) {
            [self reFrameViews:viewsArray initialFrame:frame];
        }else{
            self.rtstURLView.hidden = YES;
            self.snapshotView.hidden = YES;
            [self reFrameViews:minViewsArray initialFrame:frame];
        }
    }
    else{
        
        [self reFrameViews:viewsArray initialFrame:self.cameraView.frame];
        [self getCameraName];
        [self populateIPTextField];
    }
}

- (void)getAllVendors {
    
    self.view.userInteractionEnabled = NO;
    [self.vendorsNameArray removeAllObjects];
    [self.vendorsArray removeAllObjects];
    
    [[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
        if (!error) {
            self.vendorsArray  = [vendors mutableCopy];
            //            Sort evercamvendor object array by name
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            self.vendorsArray   = [[self.vendorsArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            
            self.vendorsNameArray    = [[vendors valueForKey:@"name"] mutableCopy];
            //Sort vendor name Array
            self.vendorsNameArray = [[self.vendorsNameArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
            [self.vendorsNameArray insertObject:@"Unknown/Other" atIndex:0];
            self.view.userInteractionEnabled = YES;
            
            self.currentVendor = [self getVendorWithName:self.editCamera.vendor];
            if (![self.currentVendor.name isEqualToString:@"Other"]) {
                self.tfVendor.text = self.currentVendor.name;
                [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.currentVendor.logoUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (self.currentVendor == nil) {
                        self.logoImageView.image = nil;
                    }
                }];
                [self getCameraModel:self.currentVendor.vId];
                self.modelBtn.enabled = YES;
            }else{
                NSLog(@"CAMERA VENDOR AND MODEL UNKNOWN.");
                self.tfVendor.text = self.editCamera.vendor;
                self.tfModel.text  = self.editCamera.model;
                [self.tfModel setTextColor:[AppUtility colorWithHexString:@"B9B9B9"]];
                self.modelBtn.enabled = NO;
                
            }
            
        }else{
            NSLog(@"VENDOR SERVICE ERROR: %@",error.description);
            
            self.view.userInteractionEnabled = YES;
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
    NSArray *array = [modelsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",modelName]];
    if (array.count > 0) {
        EvercamModel *model = array[0];
        return model;
    }
    return nil;
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
    NSInteger viewMargin = ([GlobalSettings sharedInstance].isPhone)?35:60;
    NSLog(@"view Margin: %ld",(long)viewMargin);
    if (self.editCamera)
    {
        frame.origin.y += viewMargin;
    }
    for (int index=0; index<Views.count; index++) {
        UIView* view =  Views[index];
        view.frame = frame;
        frame.origin.y += viewMargin;
    }
    CGRect newFrame = self.addButton.frame;
    newFrame.origin.y = frame.origin.y + viewMargin - 10;
    self.addButton.frame = newFrame;
    
    newFrame = self.testButton.frame;
    newFrame.origin.y = frame.origin.y + viewMargin - 10;
    self.testButton.frame = newFrame;
}

- (IBAction)remove_Message_View:(id)sender {
    self.success_Message_View.hidden = YES;
    self.blackTransparentView.hidden = YES;
}

- (IBAction)questionMarkAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case 101:{
            [AppUtility displayAlertWithTitle:@"External IP / URL" AndMessage:@"Put the public URL or IP address of your camera. \n You will need to have setup port forwarding for your camera."];
        }
            break;
        case 102:{
            [AppUtility displayAlertWithTitle:@"External HTTP Port" AndMessage:@"The HTTP port should be a 2 - 5 digit number. \n The default external port is 80."];
        }
            break;
        case 103:{
            [AppUtility displayAlertWithTitle:@"Snapshot URL" AndMessage:@"If you know your camera Vendor and Model we can work this out for you. \n You can also enter it manually for your camera."];
        }
            break;
        case 104:{
            [AppUtility displayAlertWithTitle:@"External RTSP Port" AndMessage:@"The RTSP port should be a 2 - 5 digit number. \n The default external port is 554."];
        }
            break;
        case 105:{
            [AppUtility displayAlertWithTitle:@"Stream URL" AndMessage:@"If you know your Camera Vendor and Model we can work this out for you. \n You can also enter it manually for your camera."];
        }
            break;

        default:
            break;
    }
}

- (IBAction)open_LiveSupport:(id)sender {
    [Intercom presentConversationList];
}
@end
