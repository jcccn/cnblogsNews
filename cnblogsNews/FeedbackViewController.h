//
//  FeedbackViewController.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/19/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyLabel;

@interface FeedbackViewController : UIViewController <UITextViewDelegate, UIPickerViewDelegate> {
    UIScrollView *scrollView;
    UILabel *headlineLabel;
    UIButton *genderAgeButton;
    UITextView *feedbackTextView;
    UIPickerView *pickerView;
    
    BOOL isIPHONE;
    
    NSArray *genderArray;
    NSArray *ageArray;
    NSString *genderString;
    NSString *ageString;
    
    UIBarButtonItem *sendButtonItem;
}
@property (nonatomic, retain) UIBarButtonItem *sendButtonItem;

- (BOOL)isGenderAgeFilloutOk;
- (BOOL)isContentFilloutOK;

@end
