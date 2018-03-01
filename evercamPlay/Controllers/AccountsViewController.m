//
//  AccountsViewController.m
//  EvercamPlay
//
//  Created by jw on 3/9/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountsViewController.h"
#import "CamerasViewController.h"
#import "AccountCell.h"
#import "AddAccountCell.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EvercamShell.h"
#import "EvercamUser.h"
#import "EvercamApiKeyPair.h"
#import "GlobalSettings.h"
#import "Config.h"
#import "Mixpanel.h"

#import "LoginViewController.h"
#import "Intercom/intercom.h"

@interface AccountsViewController ()
{
    NSString *triedUsername;
    NSString *triedPassword;
    
    NSIndexPath *selectedIndexPath;
    
}

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) UITextField *txt_username;
@property (nonatomic, strong) UITextField *txt_password;

@end

@implementation AccountsViewController

- (void)viewDidLoad {
//    self.screenName = @"Manage Accounts";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([GlobalSettings sharedInstance].isPhone == YES) {
        [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"AddAccountCell" bundle:nil] forCellReuseIdentifier:@"AddAccountCell"];
    }
    else
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell_iPad" bundle:nil] forCellReuseIdentifier:@"AccountCellPad"];
        [self.tableView registerNib:[UINib nibWithNibName:@"AddAccountCell_iPad" bundle:nil] forCellReuseIdentifier:@"AddAccountCellPad"];
    }
    [self getAllUsers];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLayoutSubviews{
    [self setFramesAccordingToOrientation];
}

-(void)setFramesAccordingToOrientation{
    
    [_addAccountView reframeSubView:self.view.center andFrame:self.view.bounds];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view setNeedsUpdateConstraints];
    
    [_addAccountView reframeSubView:self.view.center andFrame:self.view.bounds];
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



- (void)getAllUsers {
    self.users = [APP_DELEGATE allUserList];
    [self.tableView reloadData];
}

- (void)useAccount: (id)object
{
    //clear intercom at logout
//    [Intercom reset];
    [Intercom logout];
    NSNumber *number = (NSNumber *)object;
    NSInteger index = [number integerValue];
    AppUser *user = [self.users objectAtIndex:index];
    
    [APP_DELEGATE setDefaultUser:user];
    
    //Registering user with Intercom
    [Intercom registerUserWithUserId:user.username];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:user.username];
    [mixpanel track:mixpanel_event_sign_in properties:@{
                                                        @"Client-Type": @"Play-iOS"
                                                        }];
    
    [self.tableView reloadData];
    [self BackPressed:self];
}

- (void)removeAccount: (id)object
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove this user?" message:@"Removing a user will remove the user from Evercam but the Evercam account will still exist." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
    [alert show];
    
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.users) {
        return self.users.count + 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *accountCellIdentifier = [GlobalSettings sharedInstance].isPhone ?  @"AccountCell" : @"AccountCellPad";
    NSString *addAccountCellIdentifier = [GlobalSettings sharedInstance].isPhone ? @"AddAccountCell" :@"AddAccountCellPad";
    
    if (indexPath.row < self.users.count)
    {
        AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCellIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = [[AccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountCellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        AppUser *user = [self.users objectAtIndex:indexPath.row];
        if ([APP_DELEGATE defaultUser] && [user.username isEqualToString:[APP_DELEGATE defaultUser].username]) {
            cell.lblName.text = [NSString stringWithFormat:@"%@ - Default", user.username];
        } else {
            cell.lblName.text = user.username;
        }
        cell.lblEmail.text = user.email;
        
        return cell;
    }
    else
    {
        AddAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:addAccountCellIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = [[AddAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addAccountCellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.users.count)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            selectedIndexPath = indexPath;
            
            if ([GlobalSettings sharedInstance].isPhone){
                //iPhone Case
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Account",@"Remove Account", nil];
                [sheet showInView:self.view];
                
            }else{
                //iPad Case
                [self showIpadActionSheet];
            }
            
        });
    }
    else
    {
        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"LoginViewController":@"LoginViewController_iPad" bundle:[NSBundle mainBundle]];
        vc.isFromAddAccount     = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)showIpadActionSheet{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* use = [UIAlertAction
                          actionWithTitle:@"Use Account"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self performSelectorOnMainThread:@selector(useAccount:) withObject:[NSNumber numberWithInteger:selectedIndexPath.row] waitUntilDone:NO];
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              
                          }];
    UIAlertAction* remove = [UIAlertAction
                             actionWithTitle:@"Remove Account"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [self performSelectorOnMainThread:@selector(removeAccount:) withObject:selectedIndexPath waitUntilDone:NO];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:use];
    [alert addAction:remove];
    [alert addAction:cancel];
    
    UIPopoverPresentationController *popPresenter = [alert
                                                     popoverPresentationController];
    popPresenter.sourceView = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    popPresenter.sourceRect = [self.tableView cellForRowAtIndexPath:selectedIndexPath].bounds;
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)BackPressed:(id)sender {
    NSLog(@"Navigation Stack: %@",self.navigationController.viewControllers);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        [self performSelectorOnMainThread:@selector(useAccount:) withObject:[NSNumber numberWithInteger:selectedIndexPath.row] waitUntilDone:NO];
        
    }else if (buttonIndex == 1){
        
        [self performSelectorOnMainThread:@selector(removeAccount:) withObject:selectedIndexPath waitUntilDone:NO];
        
    }else{
        //Cancel Tapped
    }
}

-(void)removeUserImageFromDirectory:(NSString *)email{
    
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *filePath      = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",email]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // if file is not exist, create it.
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        AppUser *user = [self.users objectAtIndex:selectedIndexPath.row];
        [self removeUserImageFromDirectory:user.email];
        if (self.users.count == 1) {
            //clear intercom at logout
//            [Intercom reset];
            [Intercom logout];
            [APP_DELEGATE logout];
            return;
        }
        //clear intercom at logout
//        [Intercom reset];
        [Intercom logout];
        if ([user.username isEqualToString:[APP_DELEGATE defaultUser].username]) {
            [APP_DELEGATE deleteUser:user];
            [APP_DELEGATE saveContext];
            [APP_DELEGATE setDefaultUser:[[APP_DELEGATE allUserList] objectAtIndex:0]];
        } else {
            [APP_DELEGATE deleteUser:user];
            [APP_DELEGATE saveContext];
        }
        
        [self getAllUsers];
        //Registering user with Intercom
        [Intercom registerUserWithUserId:[APP_DELEGATE defaultUser].username];
    }
}

@end
