# evercam-objc

Objective-C wrapper around Evercam API

## Install the library

To install the library using CocoaPods:

1. Install CocoaPods using ```gem install cocoapods```
2. Create ```Podfile``` in your Xcode project and add the following line:  
```pod "Evercam"```
3. Run ```pod install``` in your project's directory
4. Open xcworkspace file in Xcode.

## Basic Usage

```objective-c
#import "EvercamShell.h"

//Request user's key and id from Evercam
[[EvercamShell shell] requestEvercamAPIKeyFromEvercamUser:username Password:password WithBlock:^(EvercamApiKeyPair *userKeyPair, NSError *error) {
    if (error == nil) {
        ...
    }
    else
    {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);

    }
}];
```
### Cameras
```objective-c
//Create new camera
EvercamCameraBuilder *cameraBuilder = nil;
cameraBuilder = [[EvercamCameraBuilder alloc] initWithCameraId:@"cameraid" andCameraName:@"cameraName" andIsPublic:NO];

cameraBuilder.vendor = @"vendorid";
cameraBuilder.model = @"modelid";
cameraBuilder.cameraUsername = @"username";
cameraBuilder.cameraPassword = @"password";
cameraBuilder.internalHost = "192.168.1.168";
cameraBuilder.internalHttpPort = @"80";
cameraBuilder.internalRtspPort = @"554";
cameraBuilder.externalHost = @"198.245.40.154";
cameraBuilder.externalHttpPort = @"8080";
cameraBuilder.externalRtspPort = @"8081";

[[EvercamShell shell] createCamera:cameraBuilder withBlock:^(EvercamCamera *camera, NSError *error) {
    if (error == nil) {
        ...
    }
    else
    {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
    }
}];

//Delete camera by Evercam ID
[[EvercamShell shell] deleteCamera:@"cameraid" withBlock:^(BOOL success, NSError *error) {
    if (success) {
        ...
    } else {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
    }
}];

//Updates full or partial data for an existing camera
[[EvercamShell shell] patchCamera:cameraBuilder withBlock:^(EvercamCamera *camera, NSError *error) {
    if (error == nil) {
        ...
    }
    else
    {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
    }
}];

//Returns the list of cameras owned by a particular user, including shared cameras and thumnail data
[EvercamShell shell] getAllCameras:@"joeyb" includeShared:YES includeThumbnail:YES withBlock:^(NSArray *cameras, NSError *error) {
    if (error == nil) {
        ...
    }
    else
    {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
    }
}];
```
### Snapshots
```objective-c
//Fetch snapshot image url from Evercam
NSString *snapshotUrlString = [[EvercamShell shell] getSnapshotLink:@"cameraid"];
```
### Users
```objective-c
//Create a new Evercam user account
EvercamUser *user = [EvercamUser new];
user.firstname = @"Joe";
user.lastname = @"Bloggs";
user.username = @"joeyb";
user.country = @"us";
user.email = @"joe.bloggs@example.org";
user.password = @"password";

[[EvercamShell shell] createUser:user WithBlock:^(EvercamUser *newuser, NSError *error) {
    if (error == nil) {
        ...
    }
    else
    {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
    }
}];

//Fetch Evercam user details by username or Email address.
[[EvercamShell shell] getUserFromId:@"username/Email" withBlock:^(EvercamUser *user, NSError *error) {
    if (error == nil) {
        ...
    }
    else
    {
        NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
    }
}];
```
### Vendors && Models
```objective-c
//Get a list of all supported vendors
[[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
    for (EvercamVendor *vendor in vendors)
    {
        ...
    }
}];
//Get a list of camera model that associated with specified vendor id
[[EvercamShell shell] getAllModelsByVendorId:@"vendorid" withBlock:^(NSArray *models, NSError *error) {
    for (EvercamModel *model in models)
    {
        ...
    }    
}];
```
