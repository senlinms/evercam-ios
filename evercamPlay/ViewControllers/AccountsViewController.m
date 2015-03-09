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
#import "UILabel+ActionSheet.h"
#import <QuartzCore/QuartzCore.h>
#import "UIAlertController+NoBorderText.h"

@interface AccountsViewController ()

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddAccountCell" bundle:nil] forCellReuseIdentifier:@"AddAccountCell"];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.tableView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.tableView.layer insertSublayer:gradient atIndex:0];

    SWRevealViewController *revealController = [self revealViewController];
    
    [self.btnMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];

    [[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor whiteColor]];
    UILabel * appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
    [appearanceLabel setAppearanceFont:[UIFont systemFontOfSize:15.0]];
    
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setBackgroundColor:[UIColor darkGrayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)useAccount: (id)object
{
    NSNumber *number = (NSNumber *)object;
    NSLog(@"%d", number.integerValue);
}

- (void)removeAccount: (id)object
{
    NSNumber *number = (NSNumber *)object;
    NSLog(@"%d", number.integerValue);

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
                                 //[alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:cancel];
    [alert addAction:remove];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *accountCellIdentifier = @"AccountCell";
    static NSString *addAccountCellIdentifier = @"AddAccountCell";
    
    if (indexPath.row == 0)
    {
        AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCellIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = [[AccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountCellIdentifier];
        }

        return cell;
    }
    else
    {
        AddAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:addAccountCellIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = [[AddAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addAccountCellIdentifier];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
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
                                         [self performSelectorOnMainThread:@selector(removeAccount:) withObject:[NSNumber numberWithInteger:indexPath.row] waitUntilDone:NO];
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
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Add Account"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
            UIAlertAction* add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {

                                                           }];
            
            [alert addAction:cancel];
            [alert addAction:add];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.borderStyle = UITextBorderStyleNone;
                textField.textColor = [UIColor whiteColor];
                [textField setFont:[UIFont systemFontOfSize:17]];
                if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                    UIColor *color = [UIColor lightTextColor];
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email/Username" attributes:@{NSForegroundColorAttributeName: color}];
                } else {
                    NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
                }
            }];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.borderStyle = UITextBorderStyleNone;
                textField.textColor = [UIColor whiteColor];
                [textField setFont:[UIFont systemFontOfSize:17]];
                
                if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                    UIColor *color = [UIColor lightTextColor];
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
                } else {
                    NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
                }
                textField.secureTextEntry = YES;
            }];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}
@end
