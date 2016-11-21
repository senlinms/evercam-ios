//
//  AppDelegate.m
//  EvercamPlay
//
//  Created by jw on 3/7/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "AppUser.h"
#import "GAI.h"
#import "EvercamShell.h"
#import "GlobalSettings.h"
#import "Mixpanel.h"
#import "SharedManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "PreferenceUtil.h"
#import "Intercom/intercom.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@import Firebase;
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [FIRApp configure]; //setting up Firebase
    [self integrateIntercom]; // setting up Intercom
    [Crashlytics startWithAPIKey:@"70e87b744f3bc2c7db518b88faf93411823b45b2"];
    [Fabric with:@[[Crashlytics class]]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [GlobalSettings sharedInstance].isPhone = YES;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [GlobalSettings sharedInstance].isPhone = NO;
    }
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    WelcomeViewController *vc = [[WelcomeViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"WelcomeViewController" : @"WelcomeViewController_iPad" bundle:nil];
    self.viewController = [[CustomNavigationController alloc] initWithRootViewController:vc];
    [self.viewController setNavigationBarHidden:YES animated:NO];
    self.viewController.isPortraitMode = true;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"plist"];
    if (plistPath) {
        NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        NSString *GAITrackingID = [contents valueForKey:@"GAITrackingId"];
        NSString *MixpanelToken = [contents valueForKey:@"MixpanelToken"];
        
        [Mixpanel sharedInstanceWithToken:MixpanelToken];
        
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].dispatchInterval = 20;
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
        [[GAI sharedInstance] trackerWithTrackingId:GAITrackingID];
    }
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [PreferenceUtil setIsShowOfflineCameras:YES];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]){ // iOS 8 (User notifications)
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeBadge |
           UIUserNotificationTypeSound |
           UIUserNotificationTypeAlert)
                                           categories:nil]];
        [application registerForRemoteNotifications];
    } else { // iOS 7 (Remote notifications)
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationType)
         (UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound |
          UIRemoteNotificationTypeAlert)];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskAll;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Device Token: %@",deviceToken);
    [Intercom setDeviceToken:deviceToken];
}



-(void)integrateIntercom{
    NSString* localPlistPath    = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"plist"];
    if (localPlistPath) {
        NSDictionary *contents  = [NSDictionary dictionaryWithContentsOfFile:localPlistPath];
        NSString *iOSApiKey     = contents[@"IntercomiOSAPIkey"];
        NSString *intercomAppId = contents[@"IntercomAppId"];
        [Intercom setApiKey:iOSApiKey forAppId:intercomAppId];
    }
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)setDefaultUser:(AppUser *)defaultUser {
    _defaultUser = defaultUser;
    
    
    [[NSUserDefaults standardUserDefaults] setValue:defaultUser.username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppUser" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"db_data.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma  mark - custom functions for data models
- (AppUser *)getDefaultUser {
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    if (username && username.length > 0) {
        AppUser *user = [APP_DELEGATE userWithName:username];
        if (user) {
            [[EvercamShell shell] setUserKeyPairWithApiId:user.apiId andApiKey:user.apiKey];
            return user;
        }
    }
    
    return nil;
}

- (AppUser *)userWithName:(NSString *)username {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppUser"
                                              inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([array count]>0) {
        return [array objectAtIndex:0];
        
    }
    //    return nil;
    return [self newUserWithName:username];
}

-(void)deleteUser:(AppUser *)user {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:user];
}

- (AppUser *)newUserWithName:(NSString *)username
{
    NSManagedObjectContext *context = [self managedObjectContext];
    AppUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"AppUser"
                                                     inManagedObjectContext:context];
    [newUser setUsername:username];
    [self saveContext];
    return newUser;
}

-(NSArray *)allUserList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppUser"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return array;
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self deleteUser:self.defaultUser];
    [self.viewController popToRootViewControllerAnimated:YES];
}

@end
