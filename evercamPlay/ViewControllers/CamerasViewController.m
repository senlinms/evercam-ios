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

#import "CamerasViewController.h"
#import "SWRevealViewController.h"
#import "UILabel+ActionSheet.h"

@interface CamerasViewController()

// Private Methods:
- (IBAction)pushExample:(id)sender;

@end

@implementation CamerasViewController

#pragma mark - View lifecycle


- (void)viewDidLoad
{
	[super viewDidLoad];
	
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.btnMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    [[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor whiteColor]];
    UILabel * appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
    [appearanceLabel setAppearanceFont:[UIFont systemFontOfSize:15.0]];
//    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setBackgroundColor:[UIColor darkGrayColor]];

}

#pragma mark - Action

- (IBAction)onAdd: (id)sender
{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* add = [UIAlertAction
                         actionWithTitle:@"Add camera manually"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self performSelectorOnMainThread:@selector(addCamera) withObject:nil waitUntilDone:NO];
                             [view dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* scan = [UIAlertAction
                             actionWithTitle:@"Scan for cameras(beta)"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self performSelectorOnMainThread:@selector(scanCamera) withObject:nil waitUntilDone:NO];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    UIAlertAction* cancel = [UIAlertAction
                           actionWithTitle:@"Cancel"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [view dismissViewControllerAnimated:YES completion:nil];
                               
                           }];

    [view addAction:add];
    [view addAction:scan];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)onRefresh: (id)sender
{
    
}


- (void)addCamera
{
    
}

- (void)scanCamera
{
    
}

#pragma mark - Example Code

- (IBAction)pushExample:(id)sender
{
	UIViewController *stubController = [[UIViewController alloc] init];
	stubController.view.backgroundColor = [UIColor whiteColor];
	[self.navigationController pushViewController:stubController animated:YES];
}
@end