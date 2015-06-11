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
#import "FeedbackViewController.h"
#import "GAIDictionaryBuilder.h"
#import "Config.h"
#import "GlobalSettings.h"

@interface CamerasViewController() <AddCameraViewControllerDelegate, CameraPlayViewControllerDelegate>
{
    NSMutableArray *cameraArray;
    CGSize cellSize;
}

// Private Methods:
- (IBAction)pushExample:(id)sender;

@end

@implementation CamerasViewController

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
    
    if ([GlobalSettings sharedInstance].isPhone == YES) {
        cellSize = CGSizeMake(320.0 / [PreferenceUtil getCameraPerRow], 320.0 / [PreferenceUtil getCameraPerRow] * .75);
        ((UICollectionViewFlowLayout *) self.camerasView.collectionViewLayout).itemSize = cellSize;
    }
    else {
        cellSize = CGSizeMake(self.view.frame.size.width / [PreferenceUtil getCameraPerRow], self.view.frame.size.width / [PreferenceUtil getCameraPerRow] * .75);
        ((UICollectionViewFlowLayout *) self.camerasView.collectionViewLayout).itemSize = cellSize;
    }
//    if ([PreferenceUtil getCameraPerRow] == 3)
//    {
//        [((UICollectionViewFlowLayout *) self.camerasView.collectionViewLayout) setSectionInset:UIEdgeInsetsMake(0, 1, 0, 1)];
//    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;    
}

- (void)showLoadingView {
    [self.loadingIndicator startAnimating];
    self.btnRefresh.hidden = YES;
}

- (void)hideLoadingView {
    [self.loadingIndicator stopAnimating];
    self.btnRefresh.hidden = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {

    }
    else
    {

    }
}

#pragma mark - Action

- (IBAction)onAdd: (id)sender
{
    [self addCamera];
//    UIAlertController * view=   [UIAlertController
//                                 alertControllerWithTitle:nil
//                                 message:nil
//                                 preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    UIAlertAction* add = [UIAlertAction
//                         actionWithTitle:@"Add camera manually"
//                         style:UIAlertActionStyleDefault
//                         handler:^(UIAlertAction * action)
//                         {
//                             [self performSelectorOnMainThread:@selector(addCamera) withObject:nil waitUntilDone:NO];
//                             [view dismissViewControllerAnimated:YES completion:nil];
//                             
//                         }];
//    UIAlertAction* scan = [UIAlertAction
//                             actionWithTitle:@"Scan for cameras(beta)"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [self performSelectorOnMainThread:@selector(scanCamera) withObject:nil waitUntilDone:NO];
//                                 [view dismissViewControllerAnimated:YES completion:nil];
//                                 
//                             }];
//    UIAlertAction* cancel = [UIAlertAction
//                           actionWithTitle:@"Cancel"
//                           style:UIAlertActionStyleCancel
//                           handler:^(UIAlertAction * action)
//                           {
//                               [view dismissViewControllerAnimated:YES completion:nil];
//                               
//                           }];
//
//    [view addAction:add];
//    [view addAction:scan];
//    [view addAction:cancel];
//    
//    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)onRefresh: (id)sender
{
//    [[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor whiteColor]];
//    UILabel * appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
//    [appearanceLabel setAppearanceFont:[UIFont systemFontOfSize:15.0]];
//    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setBackgroundColor:[UIColor darkGrayColor]];

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

                [self.camerasView reloadData];
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


- (void)addCamera
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                          action:category_add_camera
                                                           label:label_add_camera_manually
                                                           value:nil] build]];
    
    AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AddCameraViewController" : @"AddCameraViewController_iPad" bundle:nil];
    [addCameraVC setDelegate:self];
    [self.navigationController pushViewController:addCameraVC animated:YES];
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
//    cell.thumbnailImageView.offlineImage = [UIImage imageNamed:@"cam_unavailable.png"];
    cell.secondaryView.hidden = NO;
    cell.thumbnailImageView.secondaryView = cell.secondaryView;
    if (cameraInfo.isOnline) {
        cell.greyImv.hidden = YES;
        cell.imvOffline.hidden = YES;
        //must setup second url.
        cell.thumbnailImageView.secondURL = [NSURL URLWithString:[[EvercamShell shell] getSnapshotLink:cameraInfo.camId]];
        [cell.thumbnailImageView loadImageFromURL:[NSURL URLWithString:cameraInfo.thumbnailUrl] withSpinny:NO];
    } else {
        cell.greyImv.hidden = NO;
        cell.imvOffline.hidden = NO;
        if (cameraInfo.thumbnailUrl && cameraInfo.thumbnailUrl.length > 0) {
            [cell.thumbnailImageView loadImageFromURL:[NSURL URLWithString:cameraInfo.thumbnailUrl] withSpinny:NO];
        } else {
            cell.secondaryView.hidden = YES;
            [cell.thumbnailImageView displayImage:cell.thumbnailImageView.offlineImage];
        }
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

#pragma mark - CameraPlayViewController Delegate Method
- (void)cameraDeleted:(EvercamCamera *)camera {
    [cameraArray removeObject:camera];
    [self.camerasView reloadData];
}

- (void)cameraEdited:(EvercamCamera *)camera {
    for (EvercamCamera *cam in cameraArray) {
        if ([cam.camId isEqualToString:camera.camId]) {
            [cameraArray removeObject:cam];             [cameraArray addObject:camera];
            [self.camerasView reloadData];
            break;
        }
    }
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

@end
