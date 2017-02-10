//
//  LocationUpdateViewController.h
//  evercamPlay
//
//  Created by Zulqarnain Mustafa on 2/8/17.
//  Copyright © 2017 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EvercamCamera.h"


@protocol LocationUpdateViewControllerDelegate <NSObject>

- (void)cameraAdded:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface LocationUpdateViewController : UIViewController{
    
}

@property (nonatomic, strong) id<LocationUpdateViewControllerDelegate> delegate;

@property (nonatomic, strong) EvercamCamera *cameraToUpdate;

- (IBAction)goBack:(id)sender;
- (IBAction)update_Location:(id)sender;
- (IBAction)getCurrentLocation:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *location_Map;
@end
