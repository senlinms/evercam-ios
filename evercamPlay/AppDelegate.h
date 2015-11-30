//
//  AppDelegate.h
//  evercamPlay
//
//  Created by jw on 3/7/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppUser.h"
#import "CustomNavigationController.h"

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CustomNavigationController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) AppUser *defaultUser;

-(void) saveContext;
-(AppUser *)userWithName:(NSString *)username;
-(void)deleteUser:(AppUser *)user;
-(NSMutableArray *)allUserList;
- (NSURL *)applicationDocumentsDirectory;

- (AppUser *)getDefaultUser;
- (void)logout;

@end

