/*
 
 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 Original code:
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 */

#import "CamerasViewController.h"
#import "SWRevealViewController.h"
//#import "UILabel+ActionSheet.h"
#import "CameraViewCell.h"
#import "EvercamShell.h"
#import "EvercamCamera.h"
#import "CameraPlayViewController.h"
#import "AppDelegate.h"
#import "PreferenceUtil.h"
#import "CustomNavigationController.h"
#import "AddCameraViewController.h"
#import "GAIDictionaryBuilder.h"
#import "Config.h"
#import "GlobalSettings.h"
#import "AccountsViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "UIImageView+WebCache.h"
#import "Intercom/intercom.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "PublicCamerasViewController.h"
#import "CameraScanViewController.h"
#import "VendorAndModelViewController.h"
#import "LoginViewController.h"
@import Firebase;

@interface CamerasViewController() <AddCameraViewControllerDelegate, CameraPlayViewControllerDelegate>
{
    
    CGSize cellSize;
}

// Private Methods:
- (IBAction)pushExample:(id)sender;

@end

@implementation CamerasViewController
@synthesize cameraArray;
#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.screenName = @"Camera Grid View";
    
    cameraArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.btnMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    if ([GlobalSettings sharedInstance].isPhone == YES) {
        [self.camerasView registerNib:[UINib nibWithNibName:@"CameraViewCell" bundle:nil] forCellWithReuseIdentifier: @"CameraViewCell"];
    }
    else
        [self.camerasView registerNib:[UINib nibWithNibName:@"CameraViewCell_iPad" bundle:nil] forCellWithReuseIdentifier: @"CameraViewCellPad"];
    
    
    [self hideLoadingView];
    [self onRefresh:nil];
    
    [self setCamerasPerRow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PushVC:) name:@"K_LOAD_SIDE_MENU_CONTROLLERS" object:nil];
    
}

-(void)pushAccountsViewController{
    AccountsViewController *aVc = [[AccountsViewController alloc] initWithNibName:@"AccountsViewController" bundle:[NSBundle mainBundle]];
    
    CustomNavigationController *cameraPlayNavVC = [[CustomNavigationController alloc] initWithRootViewController:aVc];
    if ([PreferenceUtil isForceLandscape]) {
        [cameraPlayNavVC setIsPortraitMode:NO];
    } else {
        [cameraPlayNavVC setIsPortraitMode:YES];
        [cameraPlayNavVC setHasLandscapeMode:YES];
    }
    cameraPlayNavVC.navigationBarHidden = YES;
    
    [[APP_DELEGATE viewController] presentViewController:cameraPlayNavVC animated:YES completion:nil];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setCamerasPerRow];
    [self.view setNeedsUpdateConstraints];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        //Your portrait
    }
    else
    {
        //Your Landscape.
    }
}



-(void)setCamerasPerRow
{
    if ([GlobalSettings sharedInstance].isPhone == YES) {
        cellSize = CGSizeMake(self.view.frame.size.width / [PreferenceUtil getCameraPerRow], self.view.frame.size.width  / [PreferenceUtil getCameraPerRow] * .75);
        ((UICollectionViewFlowLayout *) self.camerasView.collectionViewLayout).itemSize = cellSize;
    }
    else {
        cellSize = CGSizeMake(self.view.frame.size.width / [PreferenceUtil getCameraPerRow], self.view.frame.size.width / [PreferenceUtil getCameraPerRow] * .75);
        ((UICollectionViewFlowLayout *) self.camerasView.collectionViewLayout).itemSize = cellSize;
    }
}


-(void)PushVC:(NSNotification *)Notification
{
    UIViewController *newFrontController = nil;
    NSNumber *indexNumber   = (NSNumber *)[Notification object];
    NSInteger row           = [indexNumber integerValue];
    // row number reveived here with 1 increased
    if (row == 1)
    {
        
        newFrontController = [[CameraScanViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CameraScanViewController" : @"CameraScanViewController_iPad" bundle:[NSBundle mainBundle]];
        
        [FIRAnalytics logEventWithName:@"Menu"
                            parameters:@{
                                         @"Add_Camera_Type": @"Click on add camera in menu, and choose scan."
                                         }];
        
    }else if (row == 2)
    {
        
        newFrontController = [[PublicCamerasViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"PublicCamerasViewController" : @"PublicCamerasViewController_iPad" bundle:[NSBundle mainBundle]];
        
    }else if (row == 3)
    {
        
        newFrontController = [[SettingsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SettingsViewController" : @"SettingsViewController_iPad" bundle:nil];
        
        [FIRAnalytics logEventWithName:@"Menu"
                            parameters:@{
                                         @"Settings": @"Click on setting menu"
                                         }];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                              action:action_settings
                                                               label:label_settings
                                                               value:nil] build]];
        
    }
    else if (row == 4)
    {
        
        [Intercom presentConversationList];
        return;
    }
    else if (row == 5)
    {
        
        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"LoginViewController":@"LoginViewController_iPad" bundle:[NSBundle mainBundle]];
        vc.isFromAddAccount     = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (row == 6){
        
        newFrontController = [[AccountsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AccountsViewController" : @"AccountsViewController_iPad" bundle:nil];
        
        [FIRAnalytics logEventWithName:@"Menu"
                            parameters:@{
                                         @"Manage_Account": @"Click on manage account"
                                         }];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                              action:action_manage_account
                                                               label:label_account
                                                               value:nil] build]];
        
    }
    
    [self.navigationController pushViewController:newFrontController animated:YES];
    self.navigationController.navigationBarHidden = YES;
    [self.revealViewController revealToggleAnimated:YES];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self setCamerasPerRow];
}

- (void)showLoadingView {
    [self.loadingIndicator startAnimating];
    self.btnRefresh.hidden = YES;
}

- (void)hideLoadingView {
    [self.loadingIndicator stopAnimating];
    self.btnRefresh.hidden = NO;
}

#pragma mark - Action

- (IBAction)onAdd: (id)sender
{
    [self addCamera];
}

- (IBAction)onRefresh: (id)sender
{
    [FIRAnalytics logEventWithName:@"Menu"
                        parameters:@{
                                     @"Refresh": @"Refresh Camera List"
                                     }];
    [self refreshGridView:YES];
}

-(void)refreshGridView:(BOOL)isReloadImages{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                          action:action_refresh
                                                           label:label_list_refresh
                                                           value:nil] build]];
    
    
    if (![APP_DELEGATE defaultUser]) {
        return;
    }
    
    BOOL willShowOfflineCamera = [PreferenceUtil isShowOfflineCameras];
    
    [[EvercamShell shell] setUserKeyPairWithApiId:[APP_DELEGATE defaultUser].apiId andApiKey:[APP_DELEGATE defaultUser].apiKey];
    
    [self showLoadingView];
    [[EvercamShell shell] getAllCameras:[APP_DELEGATE defaultUser].username includeShared:YES includeThumbnail:YES withBlock:^(NSArray *cameras, NSError *error) {
        [self hideLoadingView];
        if (error == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AsyncImageView releaseCacheMemory];
                if (willShowOfflineCamera == YES) {
                    cameraArray = [[NSMutableArray alloc] initWithArray:cameras];
                }
                else
                {
                    cameraArray = [[NSMutableArray alloc] init];
                    for (EvercamCamera *cam in cameras) {
                        if (cam.isOnline == YES) {
                            [cameraArray addObject:cam];
                        }
                    }
                }
                if (isReloadImages) {
                    [[SDImageCache sharedImageCache] clearMemory];
                    [[SDImageCache sharedImageCache] clearDisk];
                }
                [self.camerasView reloadData];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ops!" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
            });
        }
    }];
}


- (void)addCamera
{
    [FIRAnalytics logEventWithName:@"Menu"
                        parameters:@{
                                     @"Add_Camera_Type": @"Click on add camera in menu, and choose manually."
                                     }];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                          action:category_add_camera
                                                           label:label_add_camera_manually
                                                           value:nil] build]];
    /*
     AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AddCameraViewController" : @"AddCameraViewController_iPad" bundle:nil];
     [addCameraVC setDelegate:self];
     [self.navigationController pushViewController:addCameraVC animated:YES];
     */
    VendorAndModelViewController *addCameraVC = [[VendorAndModelViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"VendorAndModelViewController" : @"VendorAndModelViewController_iPad" bundle:[NSBundle mainBundle]];
    CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:addCameraVC];
    navVC.isPortraitMode        = YES;
    [navVC setHasLandscapeMode:YES];
    navVC.navigationBarHidden   = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)scanCamera
{
    
}

#pragma mark - Example Code

- (IBAction)pushExample:(id)sender
{
    UIViewController *stubController = [[UIViewController alloc] init];
    stubController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:stubController animated:YES];
}
#pragma mark UICollectionView
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return cameraArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CameraViewCell *cell = (CameraViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[GlobalSettings sharedInstance].isPhone ? @"CameraViewCell":@"CameraViewCellPad" forIndexPath:indexPath];
    EvercamCamera *cameraInfo = [cameraArray objectAtIndex:indexPath.row];
    //    NSLog(@"Is Camera Online: %@",cameraInfo.isOnline?@"YES: ONLINE":@"NO: OFFLINE");
    NSString *thumbnail_ImageUrl_String = [NSString stringWithFormat:@"%@/%@/thumbnail?api_id=%@&api_key=%@",THUMB_IMAGE_BASEURL,cameraInfo.camId,[APP_DELEGATE defaultUser].apiId,[APP_DELEGATE defaultUser].apiKey];
    
    cell.titleLabel.text = cameraInfo.name;
    CGSize textSize = { 1400.0, 20.0 };
    
    CGSize size = [cell.titleLabel.text boundingRectWithSize:textSize
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  attributes:@{NSFontAttributeName:cell.titleLabel.font}
                                                     context:nil].size;
    
    CGRect frmOfflineImg = cell.imvOffline.frame;
    CGFloat cellWidth = cell.frame.size.width;
    if (cellWidth-20 < size.width) {
        NSLog(@"OOOOOO %@", cell.titleLabel.text);
        cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x,
                                           cell.titleLabel.frame.origin.y,
                                           cellWidth-20,
                                           cell.titleLabel.frame.size.height);
        frmOfflineImg.origin.x = cellWidth-15;
        cell.imvOffline.frame = frmOfflineImg;
    }
    else
    {
        [cell.titleLabel sizeToFit];
        cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x,
                                           cell.titleLabel.frame.origin.y,
                                           size.width,
                                           size.height);
        frmOfflineImg.origin.x = size.width+10;
        cell.imvOffline.frame = frmOfflineImg;
    }
    
    [cell.thumbnailImageView setImage:nil];
    cell.secondaryView.hidden = NO;
    cell.thumbnailImageView.secondaryView = cell.secondaryView;
    if (cameraInfo.isOnline) {
        
        cell.greyImv.hidden = YES;
        cell.imvOffline.hidden = YES;
        /*
         [cell.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:thumbnail_ImageUrl_String]
         placeholderImage:[UIImage imageNamed:@"ic_GridPlaceholder.png"]
         options:SDWebImageRefreshCached];
         */
        [cell.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:thumbnail_ImageUrl_String] placeholderImage:[UIImage imageNamed:@"ic_GridPlaceholder.png"]];
        //        [cell.thumbnailImageView loadImageFromURL:[NSURL URLWithString:thumbnail_ImageUrl_String] withSpinny:NO];
    } else {
        
        cell.greyImv.hidden = NO;
        cell.imvOffline.hidden = NO;
        /*
         [cell.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:thumbnail_ImageUrl_String]
         placeholderImage:[UIImage imageNamed:@"ic_GridPlaceholder.png"]
         options:SDWebImageRefreshCached];
         */
        [cell.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:thumbnail_ImageUrl_String] placeholderImage:[UIImage imageNamed:@"ic_GridPlaceholder.png"]];
        //        [cell.thumbnailImageView loadImageFromURL:[NSURL URLWithString:thumbnail_ImageUrl_String] withSpinny:NO];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EvercamCamera *cameraInfo = [cameraArray objectAtIndex:indexPath.row];
    [self showCamera:cameraInfo];
}

#pragma mark - AddCameraViewController Delegate Method
- (void)cameraAdded:(EvercamCamera *)camera {
    [cameraArray addObject:camera];
    NSArray *sortedArray = [cameraArray sortedArrayUsingComparator:^NSComparisonResult(EvercamCamera *c1, EvercamCamera *c2){
        return [c1.name caseInsensitiveCompare:c2.name];
    }];
    cameraArray = [NSMutableArray arrayWithArray:sortedArray];
    [self.camerasView reloadData];
    [self showCamera:camera];
}

- (void)cameraEdited:(EvercamCamera *)camera {
    for (EvercamCamera *cam in cameraArray) {
        if ([cam.camId isEqualToString:camera.camId]) {
            [cameraArray removeObject:cam];
            [cameraArray addObject:camera];
            [self.camerasView reloadData];
            break;
        }
    }
}

#pragma mark - CameraPlayViewController Delegate Method
-(void)cameraDel:(EvercamCamera *)camera
{
    [cameraArray removeObject:camera];
    [self.camerasView reloadData];
}

#pragma mark - Custom Functions
- (void)showCamera:(EvercamCamera *)camera {
    
    CameraPlayViewController *cameraPlayVC = [[CameraPlayViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CameraPlayViewController" : @"CameraPlayViewController_iPad" bundle:nil];
    [cameraPlayVC setDelegate:self];
    cameraPlayVC.cameraInfo = camera;
    cameraPlayVC.cameras = cameraArray;
    
    CustomNavigationController *cameraPlayNavVC = [[CustomNavigationController alloc] initWithRootViewController:cameraPlayVC];
    if ([PreferenceUtil isForceLandscape]) {
        [cameraPlayNavVC setIsPortraitMode:NO];
    } else {
        [cameraPlayNavVC setIsPortraitMode:YES];
        [cameraPlayNavVC setHasLandscapeMode:YES];
    }
    cameraPlayNavVC.navigationBarHidden = YES;
    
    [[APP_DELEGATE viewController] presentViewController:cameraPlayNavVC animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation // iOS 6 autorotation fix
{
    return UIInterfaceOrientationPortrait;
}




-(void)viewWillAppear:(BOOL)animated{
    CustomNavigationController* cVC = [APP_DELEGATE viewController];
    [cVC setHasLandscapeMode:YES];
    [UIViewController attemptRotationToDeviceOrientation];
    [self setCamerasPerRow];
    [self refreshGridView:NO];
    //    [self onRefresh:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    UINavigationController* nvc = (UINavigationController*)[APP_DELEGATE viewController].presentedViewController;
    
    UIViewController* cvc = [nvc topViewController];
    
    
    if([cvc isKindOfClass:[CameraPlayViewController class]])
    {
        CustomNavigationController* cVC = [APP_DELEGATE viewController];
        
        
        [cVC setHasLandscapeMode:YES];
        [UIViewController attemptRotationToDeviceOrientation];
    }
    else
    {
        //THIS CODE WAS CREATING PROBLEM IN ROTATION,SO I WANT TO KEEP IT.(NAIN)
        /*
         CustomNavigationController* cVC = [APP_DELEGATE viewController];
         [cVC setIsPortraitMode:YES];
         [cVC setHasLandscapeMode:NO];
         
         NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
         [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
         [UIViewController attemptRotationToDeviceOrientation];
         */
    }
    
    
}



@end
