
/*

 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 Original code:
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 
*/

#import "MenuViewController.h"

#import "SWRevealViewController.h"
#import "CamerasViewController.h"
#import "AccountsViewController.h"
#import "SettingsViewController.h"
#import "FeedbackViewController.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"
#import "GAIDictionaryBuilder.h"
#import "Config.h"
#import "MenuViewControllerCellTableViewCell.h"

@interface MenuViewController()
{
    NSInteger _presentedRow;
}

@end

@implementation MenuViewController

@synthesize rearTableView = _rearTableView;


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.name.text =  [APP_DELEGATE defaultUser].username;
    self.email.text = [APP_DELEGATE defaultUser].email;
    self.rearTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    MenuViewControllerCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;
    
    if (nil == cell)
    {
        cell = [[MenuViewControllerCellTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor greenColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor grayColor];
    }
	
    NSString *text = nil;
    if (row == 0)
    {
        text = @"Account";
        cell.imageView.image = [UIImage imageNamed:@"ic_accounts.png"];
    }
    else if (row == 1)
    {
        text = @"Settings";
        cell.imageView.image = [UIImage imageNamed:@"ic_settings.png"];
    }
    else if (row == 2)
    {
        text = @"Feedback";
        cell.imageView.image = [UIImage imageNamed:@"ic_feedback.png"];
    }
    else if (row == 3)
    {
        text = @"Sign Out";
        cell.imageView.image = [UIImage imageNamed:@"ic_signout.png"];
    }
    else if (row == 4)
    {
        text = @"About Evercam";
        cell.imageView.image = [UIImage imageNamed:@"icon_light_info.png"];
    }

    cell.textLabel.text = NSLocalizedString( text,nil );
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    NSInteger row = indexPath.row;
    _presentedRow = row;  // <- store the presented row
    // otherwise we'll create a new frontViewController and push it with animation

    UIViewController *newFrontController = nil;

    if (row == 0 || row == 1 || row == 2 || row == 4)
    {
        row += 1;
        newFrontController = [[CamerasViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CamerasViewController" : @"CamerasViewController_iPad" bundle:nil];
        
        ((CamerasViewController*)newFrontController).selectedRow = row;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
        navigationController.navigationBarHidden = YES;
        [revealController pushFrontViewController:newFrontController animated:YES];
        return;
    }
//    else if (row == 1)
//    {
//        newFrontController = [[AccountsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AccountsViewController" : @"AccountsViewController_iPad" bundle:nil];
//        
//        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
//                                                              action:action_manage_account
//                                                               label:label_account
//                                                               value:nil] build]];
//
//    }
//    else if (row == 2)
//    {
//        newFrontController = [[SettingsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SettingsViewController" : @"SettingsViewController_iPad" bundle:nil];
//        
//        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
//                                                              action:action_settings
//                                                               label:label_settings
//                                                               value:nil] build]];
//    }
//    else if (row == 3)
//    {
//        newFrontController = [[FeedbackViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"FeedbackViewController" : @"FeedbackViewController_iPad" bundle:nil];
//    }
    
    else if (row == 3)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign out", nil) message:NSLocalizedString(@"Are you sure you want to sign out?", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
            simpleAlert.tag = 102;
            [simpleAlert show];
        });
        
        return;
    }
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
//    navigationController.navigationBarHidden = YES;
//    [revealController pushFrontViewController:newFrontController animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 102 && buttonIndex == 1) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                              action:action_logout
                                                               label:label_user_logout
                                                               value:nil] build]];
        
        [APP_DELEGATE logout];
        _presentedRow = 0;
    }
}


@end