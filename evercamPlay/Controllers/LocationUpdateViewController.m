//
//  LocationUpdateViewController.m
//  evercamPlay
//
//  Created by Zulqarnain Mustafa on 2/8/17.
//  Copyright © 2017 evercom. All rights reserved.
//

#import "LocationUpdateViewController.h"
#import "INTULocationManager.h"
#import "EvercamUtility.h"
#import "MBProgressHUD.h"
#import "EvercamCreateCamera.h"

@interface LocationUpdateViewController (){
    CLLocationCoordinate2D tapPoint;
    CLLocation *locMgrLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    NSString *timeZoneString;
}

@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;

@end

@implementation LocationUpdateViewController
@synthesize cameraToUpdate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    geocoder = [[CLGeocoder alloc] init];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    tapRecognizer.numberOfTouchesRequired = 1;
    
    [self.location_Map addGestureRecognizer:tapRecognizer];
    
    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    
    point1.coordinate = CLLocationCoordinate2DMake(self.cameraToUpdate.latitude, self.cameraToUpdate.longitude);
    
    [self.location_Map addAnnotation:point1];
    
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.cameraToUpdate.latitude longitude:self.cameraToUpdate.longitude];
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        location.coordinate, 1000, 1000);
    [self.location_Map setRegion:region animated:YES];
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

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)update_Location:(id)sender {
    
    [self getLocationInfoFromGoogle];
}

- (IBAction)getCurrentLocation:(id)sender {
    
    [self getCurrentLocation];
}


-(IBAction)foundTap:(UITapGestureRecognizer *)recognizer
{
    [self.location_Map removeAnnotations:self.location_Map.annotations];
    CGPoint point = [recognizer locationInView:self.location_Map];
    
    tapPoint = [self.location_Map convertPoint:point toCoordinateFromView:self.location_Map];
    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    
    point1.coordinate = tapPoint;
    
    [self.location_Map addAnnotation:point1];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorRed;
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        
    }
}

-(void)getCurrentLocation{
    
    self.desiredAccuracy = INTULocationAccuracyCity;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:self.desiredAccuracy timeout:60.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            // achievedAccuracy is at least the desired accuracy (potentially better)
            
            if (self.location_Map.annotations.count > 0) {
                [self.location_Map removeAnnotations:self.location_Map.annotations];
            }
            MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
            
            point1.coordinate = currentLocation.coordinate;
            
            [self.location_Map addAnnotation:point1];
            
            tapPoint = currentLocation.coordinate;
            [self zoomIn:currentLocation];
            
        }
        else if (status == INTULocationStatusTimedOut) {
            // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
            [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Location request timed out."];
        }
        else {
            [self showErrorMessagesForCurrnetLocation:status];
        }
        
    }];
    
}


-(void)getLocationFromLocationManager{
    self.desiredAccuracy = INTULocationAccuracyCity;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:self.desiredAccuracy timeout:60.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            // achievedAccuracy is at least the desired accuracy (potentially better)
            locMgrLocation = currentLocation;
            [self resolveAddress:locMgrLocation];
            [self zoomIn:currentLocation];
        }
        else if (status == INTULocationStatusTimedOut) {
            // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
            [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Location request timed out."];
        }
        else {
            [self showErrorMessagesForCurrnetLocation:status];
        }
        
    }];
}

-(void)showErrorMessagesForCurrnetLocation:(INTULocationStatus)status{
    // An error occurred
    if (status == INTULocationStatusServicesNotDetermined) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"User has not responded to the permissions alert."];
    } else if (status == INTULocationStatusServicesDenied) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"User has denied this app permissions to access device location."];
    } else if (status == INTULocationStatusServicesRestricted) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"User is restricted from using location services by a usage policy."];
    } else if (status == INTULocationStatusServicesDisabled) {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Location services are turned off for all apps on this device."];
    } else {
        [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)"];
    }
}

- (IBAction)zoomIn:(id)sender {
    CLLocation *location = (CLLocation *)sender;
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        location.coordinate, 4000, 4000);
    [self.location_Map setRegion:region animated:YES];
}


-(void)resolveAddress:(CLLocation *)location{
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSLog(@"Country %@",placemark.country);
            //            NSLog(@"subThoroughfare %@",placemark.subThoroughfare);
            //            NSLog(@"placemark.thoroughfare %@",placemark.thoroughfare);
            //            NSLog(@"placemark.postalCode %@",placemark.postalCode);
            NSLog(@"placemark.locality %@",placemark.locality);
            //            NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
//            [activityOverLay dismiss:YES];
        } else {
            NSLog(@"%@", error.debugDescription);
//            [activityOverLay dismiss:YES];
        }
    } ];
}


-(void)getLocationInfoFromGoogle{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/timezone/json?location=%@,%@&timestamp=1331161200&sensor=true",[NSString stringWithFormat:@"%f",tapPoint.latitude],[NSString stringWithFormat:@"%f",tapPoint.longitude]];
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSHTTPURLResponse *response = nil;
    NSError *error              = nil;
    NSData *responseData        = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&response error:&error];
    if (!error) {
        if (responseData != Nil) {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            
            if (result.count > 0) {
                if ([result[@"status"] isEqualToString:@"OK"]) {
                    
                    timeZoneString = result[@"timeZoneId"];
                    [self updateCameraLocation:timeZoneString];
                    
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSLog(@"Google location Error.");
                }
                
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"Google location Error.");
            }
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Google location Error.");
        }
    }else{
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Google location Error.");
    }
}

-(void)updateCameraLocation:(NSString *)timezone{
    NSDictionary *param_Dictionary;
    param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cameraToUpdate.camId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSDictionary dictionaryWithObjectsAndKeys:timezone,@"timezone",[NSString stringWithFormat:@"%f",tapPoint.longitude],@"location_lng",[NSString stringWithFormat:@"%f",tapPoint.latitude],@"location_lat", nil],@"Post_Param", nil];
    
    EvercamCreateCamera *api_Edit_Obj = [EvercamCreateCamera new];
    [api_Edit_Obj EditCamera:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSArray *cameraObjectArray = details[@"cameras"];
            [self.navigationController popViewControllerAnimated:YES];
            if ([self.delegate respondsToSelector:@selector(cameraEdited:)]) {
                [self.delegate cameraEdited:[[EvercamCamera alloc] initWithDictionary:cameraObjectArray[0]]];
            }
//            camera_PatchMethod_Instance = [[EvercamCamera alloc] initWithDictionary:cameraObjectArray[0]];
//            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"Settings updated successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            alert.tag           = 57;
//            [alert show];
            
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}




@end
