
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
	
    self.rearTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        [separator setBackgroundColor:[UIColor colorWithRed:26.f/255.f green:30.f/255.f blue:50.f/255.f alpha:1]];
        [cell addSubview:separator];
    }
	
    NSString *text = nil;
    if (row == 0)
    {
        text = @"Cameras";
        cell.imageView.image = [UIImage imageNamed:@"ic_cameras.png"];
    }
    else if (row == 1)
    {
        text = @"Account";
        cell.imageView.image = [UIImage imageNamed:@"ic_accounts.png"];
    }
    else if (row == 2)
    {
        text = @"Settings";
        cell.imageView.image = [UIImage imageNamed:@"ic_settings.png"];
    }
    else if (row == 3)
    {
        text = @"Feedback";
        cell.imageView.image = [UIImage imageNamed:@"ic_feedback.png"];
    }
    else if (row == 4)
    {
        text = @"Sign Out";
        cell.imageView.image = [UIImage imageNamed:@"ic_signout.png"];
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

    // otherwise we'll create a new frontViewController and push it with animation

    UIViewController *newFrontController = nil;

    if (row == 0)
    {
        newFrontController = [[CamerasViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CamerasViewController" : @"CamerasViewController_iPad" bundle:nil];
    }
    else if (row == 1)
    {
        newFrontController = [[AccountsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AccountsViewController" : @"AccountsViewController_iPad" bundle:nil];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                              action:action_manage_account
                                                               label:label_account
                                                               value:nil] build]];

    }
    else if (row == 2)
    {
        newFrontController = [[SettingsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SettingsViewController" : @"SettingsViewController_iPad" bundle:nil];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_menu
                                                              action:action_settings
                                                               label:label_settings
                                                               value:nil] build]];
    }
    else if (row == 3)
    {
        newFrontController = [[FeedbackViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"FeedbackViewController" : @"FeedbackViewController_iPad" bundle:nil];
    }
    else if (row == 4)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign out", nil) message:NSLocalizedString(@"Are you sure you want to sign out?", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
            simpleAlert.tag = 102;
            [simpleAlert show];            
        });
        
        return;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
    navigationController.navigationBarHidden = YES;
    [revealController pushFrontViewController:navigationController animated:YES];
    
    _presentedRow = row;  // <- store the presented row
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