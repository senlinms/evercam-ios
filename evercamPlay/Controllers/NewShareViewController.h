//
//  NewShareViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/11/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPKeyboardAvoidingScrollView;
@interface NewShareViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>{
    
}
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *share_ScrollView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextView *message_TextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rights_Segment;
- (IBAction)backAction:(id)sender;
- (IBAction)sendRequest:(id)sender;
- (IBAction)segment_Action:(id)sender;

@end
