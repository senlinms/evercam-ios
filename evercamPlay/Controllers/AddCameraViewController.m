//
//  AddCameraViewController.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
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

@interface AddCameraViewController () <SelectVendorViewControllerDelegate, SelectModelViewControllerDelegate>
{
    NIDropDown *vendorDropDown;
    NIDropDown *modelDropDown;
}
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) UITextField *focusedTextField;
@property (nonatomic, strong) EvercamVendor *currentVendor;
@property (nonatomic, strong) EvercamModel *currentModel;
@property (nonatomic, strong) NSArray *vendorsArray;
@property (nonatomic, strong) NSMutableArray *vendorsNameArray;
@property (nonatomic, strong) NSArray *modelsArray;
@property (nonatomic, strong) NSMutableArray *modelsNameArray;

@end

@implementation AddCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Add/Edit Camera";
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.scrollView setContentSize:CGSizeMake(0, 655)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.formView addGestureRecognizer:singleFingerTap];
    
    [self initialScreen];
    
    self.vendorsNameArray = [NSMutableArray array];
    self.modelsNameArray = [NSMutableArray array];
    
    [self getAllVendors];
    
    if ([self.tfID respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightTextColor];
        self.tfID.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"roof-cam" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Rooftop Camera" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfVendor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Select Make" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfModel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Select Model" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfSnapshot.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"/snapshot.jpg" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalHost.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"149.5.43.10" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalHttpPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"External HTTP port" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfExternalRtspPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"External RTSP port" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfInternalHost.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"192.168.1.122" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfInternalHttpPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Internal HTTP port" attributes:@{NSForegroundColorAttributeName: color}];
        self.tfInternalRtspPort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Internal RTSP port" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)imageViewClose:(id)sender {
    self.imageContainer.hidden = YES;
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
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle: nil
                                          message:@"You'll lose everything you typed in. Are you sure you want to quit?"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* no = [UIAlertAction
                                 actionWithTitle:@"No"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:no];
            
            UIAlertAction* yes = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }];
            [alert addAction:yes];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)test:(id)sender {
    [self.focusedTextField resignFirstResponder];
    if (self.tfExternalHost.text.length == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"Please specify an external IP address."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (self.tfExternalHttpPort.text.length == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"Please specify either an external HTTP port."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        BOOL reachable = isPortReachable(self.tfExternalHost.text, [self.tfExternalHttpPort.text integerValue]);
        [self performSelectorOnMainThread:@selector(isPortReachableDone:) withObject:[NSNumber numberWithBool:reachable] waitUntilDone:YES];
    });
}

- (void)isPortReachableDone:(BOOL)reachable {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (!reachable) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"The IP address provided is not reachable at the port provided."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *jpgUrl = [self buildJpgUrlWithSlash:self.tfSnapshot.text];
    NSString *externalFullUrl = [self buildFullHttpUrl:self.tfExternalHost.text andPort:[self.tfExternalHttpPort.text integerValue]  andJpgUrl:jpgUrl withUsername:self.tfUsername.text andPassword:self.tfPassword.text];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *imgData = [CommonUtil getDrawable:externalFullUrl];
        [self performSelectorOnMainThread:@selector(showImageView:) withObject:imgData waitUntilDone:YES];
    });
 
}

- (IBAction)add:(id)sender {
    EvercamCameraBuilder *cameraBuilder = [self buildCameraWithLocalCheck];
    if (cameraBuilder != nil) {
        if (!self.editCamera) { // create camera
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                BOOL isReachableExternally = [self isSnapshotReachableExternally:cameraBuilder];
                BOOL isReachableInternally = NO;
                if (!isReachableExternally) {
                    isReachableInternally = [self isSnapshotReachableInternally:cameraBuilder];
                    
                    if (!isReachableInternally) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
                                                      [self createCamera:cameraBuilder withStatus:NO];
                                                  }];
                            
                            [alert addAction:no];
                            [alert addAction:yes];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                        
                        return;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self createCamera:cameraBuilder withStatus:YES];
                });
            });
        } else { // patch camera
            [self patchCamera:cameraBuilder];
        }
        
    }
}

- (IBAction)selectMake:(id)sender {
    if (self.vendorsArray == nil || self.vendorsArray.count <= 0)
        return;
    
    [self.focusedTextField resignFirstResponder];
    
    NSArray * arrImage = [[NSArray alloc] init];
    
    if(vendorDropDown == nil) {
        CGFloat f = 200;
        vendorDropDown = [[NIDropDown alloc] showDropDown:sender height:&f textArray:self.vendorsNameArray imageArray:arrImage direction:@"down"] ;
        vendorDropDown.delegate = self;
    }
    else {
        [vendorDropDown hideDropDown:sender];
        vendorDropDown = nil;
    }
    
//    SelectVendorViewController *selectVendorVC = [[SelectVendorViewController alloc] initWithNibName:@"SelectVendorViewController" bundle:nil];
//    [selectVendorVC setDelegate:self];
//    [selectVendorVC setSelectedVendor:self.currentVendor];
//    [selectVendorVC setVendorsArray:self.vendorsArray];
//    [self.navigationController pushViewController:selectVendorVC animated:YES];
}

- (IBAction)selectModel:(id)sender {
    if (self.modelsArray == nil || self.modelsArray.count <= 0)
        return;
    
    [self.focusedTextField resignFirstResponder];
    
    NSArray * arrImage = [[NSArray alloc] init];
    
    if(modelDropDown == nil) {
        CGFloat f = 200;
        modelDropDown = [[NIDropDown alloc] showDropDown:sender height:&f textArray:self.modelsNameArray imageArray:arrImage direction:@"down"] ;
        modelDropDown.delegate = self;
    }
    else {
        [modelDropDown hideDropDown:sender];
        modelDropDown = nil;
    }
    
//    SelectModelViewController *selectModelVC = [[SelectModelViewController alloc] initWithNibName:@"SelectModelViewController" bundle:nil];
//    [selectModelVC setDelegate:self];
//    [selectModelVC setSelectedVendor:self.currentVendor];
//    [selectModelVC setSelectedModel:self.currentModel];
//    [self.navigationController pushViewController:selectModelVC animated:YES];
}

#pragma mark - UIKeyboard events
// Called when UIKeyboardWillShowNotification is sent
- (void)onKeyboardShow:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    
    // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrameInWindow fromView:nil];
    
    CGRect scrollViewKeyboardIntersection = CGRectIntersection(_scrollView.frame, keyboardFrameInView);
    UIEdgeInsets newContentInsets = UIEdgeInsetsMake(0, 0, scrollViewKeyboardIntersection.size.height, 0);
    
    // this is an old animation method, but the only one that retains compaitiblity between parameters (duration, curve) and the values contained in the userInfo-Dictionary.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    _scrollView.contentInset = newContentInsets;
    _scrollView.scrollIndicatorInsets = newContentInsets;
    
    /*
     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
     * that should be visible, e.g. a purchase button below an amount text field
     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
     */
    if (self.focusedTextField) {
        CGRect controlFrameInScrollView = [_scrollView convertRect:self.focusedTextField.bounds fromView:self.focusedTextField]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
        controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10); // replace 10 with any nice visual offset between control and keyboard or control and top of the scroll view.
        
        CGFloat controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - _scrollView.contentOffset.y;
        CGFloat controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height;
        
        // this is the visible part of the scroll view that is not hidden by the keyboard
        CGFloat scrollViewVisibleHeight = _scrollView.frame.size.height - scrollViewKeyboardIntersection.size.height;
        
        if (controlVisualBottom > scrollViewVisibleHeight) { // check if the keyboard will hide the control in question
            // scroll up until the control is in place
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight);
            
            // make sure we don't set an impossible offset caused by the "nice visual offset"
            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
            newContentOffset.y = MIN(newContentOffset.y, _scrollView.contentSize.height - scrollViewVisibleHeight);
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        } else if (controlFrameInScrollView.origin.y < _scrollView.contentOffset.y) {
            // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y = controlFrameInScrollView.origin.y;
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        }
    }
    
    [UIView commitAnimations];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)onKeyboardHide:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    // undo all that keyboardWillShow-magic
    // the scroll view will adjust its contentOffset apropriately
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
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
    
    [self getAllModels];
}

#pragma mark - Custom Functions
- (void)initialScreen {
    if (self.editCamera) {
        self.titleLabel.text = @"Edit Camera";
        self.tfID.enabled = NO;
        [self.addButton setTitle:@"Save Changes" forState:UIControlStateNormal];
        
        self.tfID.text = self.editCamera.camId;
        self.tfName.text = self.editCamera.name;
        self.tfUsername.text = self.editCamera.username;
        self.tfPassword.text = self.editCamera.password;
        self.tfSnapshot.text = [self.editCamera getJpgPath];
        self.tfExternalHost.text = self.editCamera.externalHost;
        self.tfInternalHost.text = self.editCamera.internalHost;
//        self.tfVendor.text = self.editCamera.vendor;
//        self.tfModel.text = self.editCamera.model;
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
    }
}

- (EvercamCameraBuilder *)buildCameraWithLocalCheck {
    EvercamCameraBuilder *cameraBuilder = nil;
    NSString *cameraID = self.tfID.text;
    NSString *cameraName = self.tfName.text;
    if (cameraID.length == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"Please specify a unique ID of your camera"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return nil;
    }
    
    if (cameraName.length == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"Please specify a friendly name of your camera"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return nil;
    }
    
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
    
    NSString *externalHost = self.tfExternalHost.text;
    NSString *internalHost = self.tfInternalHost.text;
    if (externalHost.length == 0 && internalHost.length == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"Please specify either an internal or external IP address."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
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
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Please specify either an internal HTTP port."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return nil;
            }
        }
        
        NSString *internalRtsp = self.tfInternalRtspPort.text;
        if (internalRtsp.length > 0) {
            NSInteger internalRtspPort = [internalRtsp integerValue];
            if (internalRtspPort != 0) {
                cameraBuilder.internalRtspPort = internalRtspPort;
            } else {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Please specify either an internal RTSP port."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
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
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Please specify either an external HTTP port."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return nil;
            }
        }
        
        NSString *externalRtsp = self.tfExternalRtspPort.text;
        if (externalRtsp.length > 0) {
            NSInteger externalRtspPort = [externalRtsp integerValue];
            if (externalRtspPort != 0) {
                cameraBuilder.externalRtspPort = externalRtspPort;
            } else {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Please specify either an external RTSP port."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
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

- (BOOL) isSnapshotReachableExternally:(EvercamCameraBuilder *)cameraBuilder {
    NSString *externalHost = cameraBuilder.externalHost;
    NSString *username = cameraBuilder.cameraUsername;
    NSString *password = cameraBuilder.cameraPassword;
    NSString *jpgUrlString = [self buildJpgUrlWithSlash:cameraBuilder.jpgUrl];
    
    if (externalHost && externalHost.length > 0) {
        NSString *externalFullUrl = [self buildFullHttpUrl:externalHost andPort:cameraBuilder.externalHttpPort andJpgUrl:jpgUrlString withUsername:username andPassword:password];
        
        if ([CommonUtil getDrawable:externalFullUrl] != nil) {
            return YES;
        }
    }
    
    return false;
}

- (BOOL) isSnapshotReachableInternally:(EvercamCameraBuilder *)cameraBuilder {
    NSString *internalHost = cameraBuilder.internalHost;
    NSString *username = cameraBuilder.cameraUsername;
    NSString *password = cameraBuilder.cameraPassword;
    NSString *jpgUrlString = [self buildJpgUrlWithSlash:cameraBuilder.jpgUrl];
    
    if (internalHost && internalHost.length > 0) {
        NSString *internalFullUrl = [self buildFullHttpUrl:internalHost andPort:cameraBuilder.externalHttpPort andJpgUrl:jpgUrlString withUsername:username andPassword:password];
        
        if ([CommonUtil getDrawable:internalFullUrl] != nil) {
            return YES;
        }
    }
    
    return false;
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
            return [NSString stringWithFormat:@"http://%@:%d%@", host, port, jpgUrl];
        }
        return [NSString stringWithFormat:@"http://%@:%@@%@:%d%@", username, password, host, port, jpgUrl];
    }
}

- (void)createCamera:(EvercamCameraBuilder *)cameraBuilder withStatus:(BOOL)status {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EvercamShell shell] createCamera:cameraBuilder withBlock:^(EvercamCamera *camera, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            camera.isOnline = status;
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle: nil
                                          message:@"Camera created successfully!"
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
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle: nil
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }];
}

- (void)patchCamera:(EvercamCameraBuilder *)cameraBuilder {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EvercamShell shell] patchCamera:cameraBuilder withBlock:^(EvercamCamera *camera, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
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
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle: nil
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }];
}

- (void)showImageView:(NSData *)imageData {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (imageData) {
        self.imageContainer.hidden = NO;
        self.imageView.image = [UIImage imageWithData:imageData];
    } else {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"The port and URL are open but we can't seem to connect. Check that the username and password are correct and the snapshot ending"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)getAllVendors {
    [[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
        self.vendorsArray = [vendors sortedArrayUsingComparator:^NSComparisonResult(EvercamVendor *v1, EvercamVendor *v2) {
            return [v1.name caseInsensitiveCompare:v2.name];
        }];

        [self.vendorsNameArray removeAllObjects];
        for (EvercamVendor *vendor in self.vendorsArray)
        {
            [self.vendorsNameArray addObject:[vendor.name copy]];
        }
        
        
        if (self.editCamera) {
            self.currentVendor = [self getVendorWithName:self.editCamera.vendor];
            if (self.currentVendor) {
                self.tfVendor.text = self.currentVendor.name;
                [self getAllModels];
            }
        }
    }];
}

- (void)getAllModels {
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
                    return;
                }
            }
            
            self.currentModel = [self getModelWithName:@"Default"];
            if (self.currentModel) {
                self.tfModel.text = self.tfModel.text;
                if (self.editCamera == nil) {
                    self.tfUsername.text = self.currentModel.defaults.authUsername;
                    self.tfPassword.text = self.currentModel.defaults.authPassword;
                    self.tfSnapshot.text = self.currentModel.defaults.jpgURL;
                }
            }
        }];
    }
}

- (EvercamVendor *)getVendorWithName:(NSString *)vendorName {
    for (EvercamVendor *vendor in self.vendorsArray) {
        if ([vendor.name isEqualToString:vendorName]) {
            return vendor;
        }
    }
    
    return nil;
}

- (EvercamModel *)getModelWithName:(NSString *)modelName {
    for (EvercamModel *model in self.modelsArray) {
        if ([model.name isEqualToString:modelName]) {
            return model;
        }
    }
    
    return nil;
}

#pragma mark NIDropdown delegate
- (void) niDropDown:(NIDropDown*)dropdown didSelectAtIndex:(NSInteger)index
{
    if (dropdown == vendorDropDown)
    {
        vendorDropDown = nil;
        self.currentVendor = self.vendorsArray[index];
        self.tfVendor.text = self.currentVendor.name;
        
        [self getAllModels];
    }
    else if (dropdown == modelDropDown)
    {
        modelDropDown = nil;
        self.currentModel = self.modelsArray[index];
        self.tfModel.text = self.currentModel.name;
        if (self.editCamera == nil) {
            self.tfUsername.text = self.currentModel.defaults.authUsername;
            self.tfPassword.text = self.currentModel.defaults.authPassword;
            self.tfSnapshot.text = self.currentModel.defaults.jpgURL;
        }
    }
}

@end
