//
//  PresetListViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "PresetListViewController.h"
#import "AppDelegate.h"
#import "EvercamPtzControls.h"

@interface PresetListViewController (){
    
    NSArray *presetArray;
}

@end

@implementation PresetListViewController
@synthesize cameraID;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getPresetsList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getPresetsList{
    
    self.view.userInteractionEnabled = NO;
    
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:cameraID,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    
    [self.activityIndicator startAnimating];
    
    [EvercamPtzControls getPresetList:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.activityIndicator stopAnimating];
            presetArray = details[@"Presets"];
            if (presetArray.count > 0) {
                self.caution_Label.hidden       = YES;
                self.preset_TableView.hidden    = NO;
                [self.preset_TableView reloadData];
            }else{
                self.caution_Label.hidden       = NO;
                self.preset_TableView.hidden    = YES;
            }
            self.view.userInteractionEnabled = YES;
        }else{
            [self.activityIndicator stopAnimating];
            self.caution_Label.hidden       = YES;
            self.preset_TableView.hidden    = YES;
            self.view.userInteractionEnabled = YES;
            [self showErrorMessage];
        }
    }];

}

-(void)showErrorMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something went wrong. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)back_Action:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return presetArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Arial-Medium" size:14];
    }
    NSDictionary *presetDictionary = presetArray[indexPath.row];
    cell.textLabel.text = presetDictionary[@"Name"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.view.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];
    
    NSDictionary *presetDictionary  = presetArray[indexPath.row];
    
    NSDictionary * param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:cameraID,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",presetDictionary[@"token"],@"token", nil];
    
    [EvercamPtzControls setPreset:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSLog(@"Successfully set the Preset");
            [self.activityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.activityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
            NSLog(@"Error setting the Preset");
        }
    }];
}

- (IBAction)addPreset:(id)sender {
}
@end
