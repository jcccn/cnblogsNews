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
    MyLabel *genderAgeLabel;
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

@interface MyLabel : UILabel {
    id target;
    SEL action;
}
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

- (void)addTarget:(id)aTarget action:(SEL)anAction forControlEvents:(UIControlEvents)controlEvents;

@end
