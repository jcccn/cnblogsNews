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
    MyLabel *calendarAgeTitleLabel;
    MyLabel *calendarAgeValueLabel;
    UITextView *feedbackTextView;
    UIPickerView *pickerView;
    
    BOOL isIPHONE;
    
    NSArray *calendarArray;
    NSArray *ageArray;
}

@end

@interface MyLabel : UILabel {
    id target;
    SEL action;
}
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

- (void)addTarget:(id)aTarget action:(SEL)anAction forControlEvents:(UIControlEvents)controlEvents;

@end
