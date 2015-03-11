
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
	
    self.title = NSLocalizedString(@"Menu", nil);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _rearTableView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.rearTableView.layer insertSublayer:gradient atIndex:0];
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
    }
	
    NSString *text = nil;
    if (row == 0)
    {
        text = @"Cameras";
    }
    else if (row == 1)
    {
        text = @"Account";
    }
    else if (row == 2)
    {
        text = @"Settings";
    }
    else if (row == 3)
    {
        text = @"Feedback";
    }
    else if (row == 4)
    {
        text = @"Sign Out";
    }

    cell.textLabel.text = NSLocalizedString( text,nil );
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    NSInteger row = indexPath.row;

    // otherwise we'll create a new frontViewController and push it with animation

    UIViewController *newFrontController = nil;

    if (row == 0)
    {
        newFrontController = [[CamerasViewController alloc] init];
    }
    else if (row == 1)
    {
        newFrontController = [[AccountsViewController alloc] init];
    }
    else if (row == 2)
    {
        newFrontController = [[SettingsViewController alloc] init];
    }
    else if (row == 3)
    {
        newFrontController = [[FeedbackViewController alloc] init];
    }
    else if (row == 4)
    {
        dispatch_async(dispatch_get_main_queue(), ^{

            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:@"Are you sure you want to sign out?"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* no = [UIAlertAction
                                 actionWithTitle:@"No"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction* yes = [UIAlertAction
                                     actionWithTitle:@"Yes"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [revealController.navigationController popViewControllerAnimated:YES];
                                         _presentedRow = 0;
                                     }];
            
            [alert addAction:no];
            [alert addAction:yes];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
    navigationController.navigationBarHidden = YES;
    [revealController pushFrontViewController:navigationController animated:YES];
    
    _presentedRow = row;  // <- store the presented row
}

@end