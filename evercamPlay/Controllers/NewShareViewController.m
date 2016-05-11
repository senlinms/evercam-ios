//
//  NewShareViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/11/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "NewShareViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EvercamUtility.h"
@interface NewShareViewController ()

@end

@implementation NewShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.share_ScrollView contentSizeToFit];
    self.message_TextView.textColor = [AppUtility colorWithHexString:@"cdcdd2"];
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendRequest:(id)sender {
}

- (IBAction)segment_Action:(id)sender {
}


#pragma UITEXTVIEW DELEGATE
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Message to send in Email (Optional)"]) {
        textView.text = @"";
    }else{
        textView.text = textView.text;
    }
    textView.textColor = [AppUtility colorWithHexString:@"000000"];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([[self.message_TextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        textView.text = @"Message to send in Email (Optional)";
        textView.textColor = [AppUtility colorWithHexString:@"eeeeef"];
    }
}

@end
