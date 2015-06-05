//
//  AccountsViewController.m
//  evercamPlay
//
//  Created by jw on 3/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"
#import "AddAccountCell.h"
#import "SWRevealViewController.h"
#import "MenuViewController.h"
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

@interface AccountsViewController ()

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

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.tableView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.tableView.layer insertSublayer:gradient atIndex:0];

    SWRevealViewController *revealController = [self revealViewController];
    
    [self.btnMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];

//    [[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor whiteColor]];
//    UILabel * appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
//    [appearanceLabel setAppearanceFont:[UIFont systemFontOfSize:15.0]];
//    
//    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setBackgroundColor:[UIColor darkGrayColor]];
    
    [self getAllUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.tableView reloadData];
    
    // go to cameras view controller
    SWRevealViewController *revealController = self.revealViewController;
    CamerasViewController *newFrontController = [[CamerasViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CamerasViewController" : @"CamerasViewController_iPad" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
    navigationController.navigationBarHidden = YES;
    [revealController pushFrontViewController:navigationController animated:YES];
}

- (void)showAddAccountAlertWithUsername:(NSString *)username andPassword:(NSString *)password {
    if (_addAccountView) {
        [_addAccountView removeFromSuperview];
        _addAccountView = nil;
    }
    
    _addAccountView = [[AddAccountView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    _addAccountView.delegate = self;
    _addAccountView.usernameField.text = username;
    _addAccountView.passwdField.text = password;
    _addAccountView.alpha = 0.f;
    [self.view addSubview:_addAccountView];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         _addAccountView.alpha = 1.0;
                     }
                     completion: ^(BOOL finished) {

                     }
     ];
}

- (void)addAccount:(NSString *)username password:(NSString *)password {
    if ([username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Username required" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
//        UIAlertController * alert=   [UIAlertController
//                                      alertControllerWithTitle:@"Username required"
//                                      message:nil
//                                      preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* ok = [UIAlertAction
//                             actionWithTitle:@"OK"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                 [_txt_username becomeFirstResponder];
//                                 [self showAddAccountAlertWithUsername:username andPassword:password];
//                             }];
//        [alert addAction:ok];
//        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if ([username containsString:@" "])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Invalid username" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
//        UIAlertController * alert=   [UIAlertController
//                                      alertControllerWithTitle:@"Invalid username"
//                                      message:nil
//                                      preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* ok = [UIAlertAction
//                             actionWithTitle:@"OK"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                 [_txt_username becomeFirstResponder];
//                                 [self showAddAccountAlertWithUsername:username andPassword:password];
//                             }];
//        [alert addAction:ok];
//        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if (password.length <= 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Password required" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
//        UIAlertController * alert=   [UIAlertController
//                                      alertControllerWithTitle:@"Password required"
//                                      message:nil
//                                      preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* ok = [UIAlertAction
//                             actionWithTitle:@"OK"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                 [_txt_password becomeFirstResponder];
//                                 [self showAddAccountAlertWithUsername:username andPassword:password];
//                             }];
//        [alert addAction:ok];
//        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EvercamShell shell] requestEvercamAPIKeyFromEvercamUser:username Password:password WithBlock:^(EvercamApiKeyPair *userKeyPair, NSError *error) {
        if (error == nil)
        {
            [[EvercamShell shell] getUserFromId:username withBlock:^(EvercamUser *newuser, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (error == nil) {
                                        
                    if (_addAccountView) {
                        [_addAccountView removeFromSuperview];
                        _addAccountView = nil;
                    }
                    
                    AppUser *user = [APP_DELEGATE userWithName:newuser.username];
                    [user setDataWithEvercamUser:newuser];
                    [user setApiKeyPairWithApiKey:userKeyPair.apiKey andApiId:userKeyPair.apiId];
                    [APP_DELEGATE saveContext];
                    [APP_DELEGATE setDefaultUser:user];
                    
                    [self getAllUsers];
                    
                } else {
                    NSLog(@"Error %li: %@", (long)error.code, error.description);
                    
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Ops!" message:error.localizedDescription];
                    
                    [alert addButtonWithTitle:@"Ok" imageIdentifier:@"yellow" block:^{
                        [self showAddAccountAlertWithUsername:username andPassword:password];
                    }];
                    [alert show];
                }
            }];
            
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSLog(@"Error %li: %@", (long)error.code, error.description);
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Ops!" message:error.localizedDescription];
            
            [alert addButtonWithTitle:@"Ok" imageIdentifier:@"yellow" block:^{
                [self showAddAccountAlertWithUsername:username andPassword:password];
            }];
            [alert show];
        }
    }];
}

- (void)removeAccount: (id)object
{
    NSIndexPath *indexPath = (NSIndexPath *)object;
    NSInteger index = indexPath.row;
    AppUser *user = [self.users objectAtIndex:index];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Are you sure you want to remove this user?" message:@"Removing a user will remove the user from Evercam Play but the Evercam account will still exist."];
        
        [alert addButtonWithTitle:@"Remove" imageIdentifier:@"yellow" block:^{
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
                                         style:UIAlertActionStyleDefault
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
        [self showAddAccountAlertWithUsername:@"" andPassword:@""];
    }
}

#pragma mark AddAccountViewDelegate - Methods
- (void) clickedOnCancel
{
    if (_addAccountView) {
        [_addAccountView removeFromSuperview];
        _addAccountView = nil;
    }
}

- (void) clickedonAddWithName:(NSString *)username withPassword:(NSString *)password
{
    [self addAccount:username password:password];
}

@end
