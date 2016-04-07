//
//  AccountsViewController.m
//  evercamPlay
//
//  Created by jw on 3/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "GAIDictionaryBuilder.h"
#import "AccountsViewController.h"
#import "AccountCell.h"
#import "AddAccountCell.h"
#import "SWRevealViewController.h"
#import "CamerasViewController.h"
//#import "UILabel+ActionSheet.h"
#import <QuartzCore/QuartzCore.h>
//#import "UIAlertController+NoBorderText.h"
#import "AppDelegate.h"
#import "EvercamShell.h"
#import "EvercamUser.h"
#import "EvercamApiKeyPair.h"
#import "MBProgressHUD.h"
#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "GlobalSettings.h"
#import "Config.h"
#import "Mixpanel.h"

#import "LoginViewController.h"

@interface AccountsViewController ()
{
    NSString *triedUsername;
    NSString *triedPassword;
    CAGradientLayer *gradient;
}

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) UITextField *txt_username;
@property (nonatomic, strong) UITextField *txt_password;

@end

@implementation AccountsViewController

- (void)viewDidLoad {    
    self.screenName = @"Manage Accounts";
    
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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0];
    [self setFramesAccordingToOrientation];
    
    [self getAllUsers];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)setFramesAccordingToOrientation{
    gradient.frame = self.tableView.bounds;
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
    gradient.frame = self.tableView.bounds;
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
    NSNumber *number = (NSNumber *)object;
    NSInteger index = [number integerValue];
    AppUser *user = [self.users objectAtIndex:index];
    
    [APP_DELEGATE setDefaultUser:user];
    
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
    NSIndexPath *indexPath = (NSIndexPath *)object;
    NSInteger index = indexPath.row;
    AppUser *user = [self.users objectAtIndex:index];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Are you sure you want to remove this user?" message:@"Removing a user will remove the user from Evercam Play but the Evercam account will still exist."];
        
        [alert addButtonWithTitle:@"Remove" imageIdentifier:@"gray" block:^{
            if (self.users.count == 1) {
                [APP_DELEGATE logout];
                return;
            }
            
            if ([user.username isEqualToString:[APP_DELEGATE defaultUser].username]) {
                [APP_DELEGATE deleteUser:user];
                [APP_DELEGATE saveContext];
                [APP_DELEGATE setDefaultUser:[[APP_DELEGATE allUserList] objectAtIndex:0]];
            } else {
                [APP_DELEGATE deleteUser:user];
                [APP_DELEGATE saveContext];
            }
            
            [self getAllUsers];
        }];
        
        [alert setCancelButtonWithTitle:@"Cancel" block:nil];
        
        [alert show];
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Are you sure you want to remove this user?"
                                      message:@"Removing a user will remove the user from Evercam Play but the Evercam account will still exist."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        UIAlertAction* remove = [UIAlertAction
                                 actionWithTitle:@"Remove"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     if (self.users.count == 1) {
                                         [APP_DELEGATE logout];
                                         return;
                                     }
                                     
                                     if ([user.username isEqualToString:[APP_DELEGATE defaultUser].username]) {
                                         [APP_DELEGATE deleteUser:user];
                                         [APP_DELEGATE saveContext];
                                         [APP_DELEGATE setDefaultUser:[[APP_DELEGATE allUserList] objectAtIndex:0]];
                                     } else {
                                         [APP_DELEGATE deleteUser:user];
                                         [APP_DELEGATE saveContext];
                                     }
                                     
                                     [self getAllUsers];
                                 }];
        
        [alert addAction:cancel];
        [alert addAction:remove];
        
        if ([GlobalSettings sharedInstance].isPhone)
        {
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            UIPopoverPresentationController *popPresenter = [alert
                                                             popoverPresentationController];
            popPresenter.sourceView = [self.tableView cellForRowAtIndexPath:indexPath];
            popPresenter.sourceRect = [self.tableView cellForRowAtIndexPath:indexPath].bounds;
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
            {
                BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
                
                [sheet addButtonWithTitle:@"Use Account" block:^{
                    [self performSelectorOnMainThread:@selector(useAccount:) withObject:[NSNumber numberWithInteger:indexPath.row] waitUntilDone:NO];
                }];
                [sheet addButtonWithTitle:@"Remove Account" block:^{
                    [self performSelectorOnMainThread:@selector(removeAccount:) withObject:indexPath waitUntilDone:NO];
                }];
                
                [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
                [sheet showInView:self.view];
            }
            else
            {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction* use = [UIAlertAction
                                      actionWithTitle:@"Use Account"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [self performSelectorOnMainThread:@selector(useAccount:) withObject:[NSNumber numberWithInteger:indexPath.row] waitUntilDone:NO];
                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];
                UIAlertAction* remove = [UIAlertAction
                                         actionWithTitle:@"Remove Account"
                                         style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * action)
                                         {
                                             [self performSelectorOnMainThread:@selector(removeAccount:) withObject:indexPath waitUntilDone:NO];
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
                
                if ([GlobalSettings sharedInstance].isPhone)
                {
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    UIPopoverPresentationController *popPresenter = [alert
                                                                     popoverPresentationController];
                    popPresenter.sourceView = [self.tableView cellForRowAtIndexPath:indexPath];
                    popPresenter.sourceRect = [self.tableView cellForRowAtIndexPath:indexPath].bounds;
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        });
    }
    else
    {
        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)BackPressed:(id)sender {
    NSLog(@"Navigation Stack: %@",self.navigationController.viewControllers);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
