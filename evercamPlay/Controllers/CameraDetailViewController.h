//
//  CameraDetailViewController.h
//  evercamPlay
//
//  Created by Zulqarnain Mustafa on 2/7/17.
//  Copyright © 2017 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamCamera.h"
#import <MapKit/MapKit.h>

@protocol CameraViewControllerDelegate <NSObject>
- (void)cameraDeletedSettings:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface CameraDetailViewController : UIViewController <UIActionSheetDelegate,MKMapViewDelegate>{
    
}
@property (nonatomic, strong) EvercamCamera *camera;

@property (nonatomic, strong) id<CameraViewControllerDelegate> delegate;

- (IBAction)goBack:(id)sender;
- (IBAction)optionsButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *camera_Name_Label;
@property (weak, nonatomic) IBOutlet UIScrollView *detail_ScrollView;
@property (weak, nonatomic) IBOutlet UIButton *vendorButton;
@property (weak, nonatomic) IBOutlet UIButton *modelButton;
@property (weak, nonatomic) IBOutlet UIImageView *camera_Model_ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *camera_Vendor_ImageView;
@property (weak, nonatomic) IBOutlet MKMapView *camera_Map;
- (IBAction)goUpdateLocation:(id)sender;

@end
