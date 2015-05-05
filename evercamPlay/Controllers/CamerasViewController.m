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

@interface CamerasViewController() <AddCameraViewControllerDelegate, CameraPlayViewControllerDelegate>
{
    NSMutableArray *cameraArray;
}

// Private Methods:
- (IBAction)pushExample:(id)sender;

@end

@implementation CamerasViewController

#pragma mark - View lifecycle


- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.screenName = @"Camera Grid View";
	
    cameraArray = [[NSMutableArray alloc] initWithCapacity:0];

    SWRevealViewController *revealController = [self revealViewController];
    
    [self.btnMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    [self.camerasView registerNib:[UINib nibWithNibName:@"CameraViewCell" bundle:nil] forCellWithReuseIdentifier: @"CameraViewCell"];
    
    [self hideLoadingView];
    [self onRefresh:nil];
    
    ((UICollectionViewFlowLayout *) self.camerasView.collectionViewLayout).itemSize = CGSizeMake(320 / [PreferenceUtil getCameraPerRow], 320 / [PreferenceUtil getCameraPerRow] * .75);
    
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

    if (![APP_DELEGATE defaultUser]) {
        return;
    }
    
    [[EvercamShell shell] setUserKeyPairWithApiId:[APP_DELEGATE defaultUser].apiId andApiKey:[APP_DELEGATE defaultUser].apiKey];

    [self showLoadingView];
    [[EvercamShell shell] getAllCameras:[APP_DELEGATE defaultUser].username includeShared:YES includeThumbnail:YES withBlock:^(NSArray *cameras, NSError *error) {
        [self hideLoadingView];
        if (error == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AsyncImageView releaseCacheMemory];
                cameraArray = [NSMutableArray arrayWithArray:cameras];
                
                [self.camerasView reloadData];
            });
        }
        else
        {
            NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
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
            });
        }
    }];
}


- (void)addCamera
{
    AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:@"AddCameraViewController" bundle:nil];
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
    CameraViewCell *cell = (CameraViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CameraViewCell" forIndexPath:indexPath];
    
    EvercamCamera *cameraInfo = [cameraArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = cameraInfo.name;
    
    CGSize textSize = { 140.0, 20.0 };
    CGSize size = [cell.titleLabel.text sizeWithFont:cell.titleLabel.font
                                        constrainedToSize:textSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frmOfflineImg = cell.imvOffline.frame;
    frmOfflineImg.origin.x = size.width + 10;
    cell.imvOffline.frame = frmOfflineImg;
    
    cell.thumbnailImageView.offlineImage = [UIImage imageNamed:@"cam_unavailable.png"];
    cell.secondaryView.hidden = NO;
    cell.thumbnailImageView.secondaryView = cell.secondaryView;
    if (cameraInfo.isOnline) {
        cell.greyImv.hidden = YES;
        cell.imvOffline.hidden = YES;
        [cell.thumbnailImageView setImage:nil];
        [cell.thumbnailImageView loadImageFromURL:[NSURL URLWithString:[[EvercamShell shell] getSnapshotLink:cameraInfo.camId]] withSpinny:NO];
    } else {
        cell.greyImv.hidden = NO;
        cell.imvOffline.hidden = NO;
        [cell.thumbnailImageView setImage:nil];
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
            [cameraArray removeObject:cam];
            [cameraArray addObject:camera];
            [self.camerasView reloadData];
            break;
        }
    }
}

#pragma mark - Custom Functions
- (void)showCamera:(EvercamCamera *)camera {
    CameraPlayViewController *cameraPlayVC = [[CameraPlayViewController alloc] initWithNibName:@"CameraPlayViewController" bundle:nil];
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
