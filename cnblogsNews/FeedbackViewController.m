//
//  FeedbackViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/19/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "FeedbackViewController.h"

#define KEYBOARD_POP_DURATION 0.3f

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"FeedbackTitle", @"Feed back");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableBackground.png"]];
    
    #if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isIPHONE = NO;
        
    } else {
        isIPHONE = YES;
    }
    #endif
    
    calendarArray = [[NSArray arrayWithObjects:@"性别", @"男", @"女", nil] retain];
    ageArray = [[NSArray arrayWithObjects:@"年龄", @"10", @"20", @"30", nil] retain];
    
    CGRect viewRect = self.view.bounds;
    
    scrollView = [[UIScrollView alloc] initWithFrame:viewRect];
    scrollView.contentSize = CGSizeMake(viewRect.size.width, viewRect.size.height+1);
    [self.view addSubview:scrollView];
    
    headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, viewRect.size.width-10, 100)];
    headlineLabel.numberOfLines = 0;
    headlineLabel.backgroundColor = [UIColor clearColor];
    headlineLabel.text = NSLocalizedString(@"FeedbackHeadline", @"    Welcomes your comments and suggestions. every word you left will be used to improve our products and services.");
    [scrollView addSubview:headlineLabel];
    [headlineLabel release];
    
    calendarAgeTitleLabel = [[MyLabel alloc] initWithFrame:CGRectMake(10, 110, 100, 40)];
    calendarAgeTitleLabel.text = @"性别/年龄";
    [calendarAgeTitleLabel addTarget:self action:@selector(calendarAgeLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
    calendarAgeTitleLabel.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:calendarAgeTitleLabel];
    [calendarAgeTitleLabel release];
    
    calendarAgeValueLabel = [[MyLabel alloc] initWithFrame:CGRectMake(110, 110, viewRect.size.width - 100-20, 40)];
    [calendarAgeValueLabel addTarget:self action:@selector(calendarAgeLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
    calendarAgeValueLabel.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:calendarAgeValueLabel];
    [calendarAgeValueLabel release];
    
    feedbackTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 160, viewRect.size.width - 10, 250)];
    feedbackTextView.backgroundColor = [UIColor clearColor];
    UITextField *background = [[UITextField alloc] initWithFrame:feedbackTextView.bounds];
    background.userInteractionEnabled = NO;
    background.borderStyle = UITextBorderStyleRoundedRect;
    [feedbackTextView addSubview:background];
    [feedbackTextView sendSubviewToBack:background];
    [background release];
    feedbackTextView.delegate = self;
    [scrollView addSubview:feedbackTextView];
    [feedbackTextView release];
    
    [scrollView release];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, viewRect.size.width, 200)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.hidden = YES;
    pickerView.delegate = self;
    UIButton *calendarAgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calendarAgeButton.frame = CGRectMake(0, 0, 137, 40);
    [self.view addSubview:pickerView];
    [pickerView release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)calendarAgeLabelClicked:(id)sender {
    pickerView.hidden = !pickerView.hidden;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if (editing) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        [feedbackTextView resignFirstResponder];
    }
}

#pragma mark -
#pragma mark UITextView Delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setEditing:YES animated:YES];
    if (isIPHONE) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:KEYBOARD_POP_DURATION];
        int keyboardHeight = 218;
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            keyboardHeight = 160;
        }
        CGRect scrollFrame = scrollView.frame;
        scrollView.frame = CGRectMake(scrollFrame.origin.x, scrollFrame.origin.y, scrollFrame.size.width, scrollFrame.size.height - keyboardHeight);
        [scrollView scrollRectToVisible:CGRectMake(0, feedbackTextView.frame.origin.y, 100, 160) animated:YES];
//        scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y - keyboardHeight);
        [UIView commitAnimations];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (isIPHONE) {
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:KEYBOARD_POP_DURATION];
        int keyboardHeight = 218;
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            keyboardHeight = 160;
        }
        CGRect scrollFrame = scrollView.frame;
        scrollView.frame = CGRectMake(scrollFrame.origin.x, scrollFrame.origin.y, scrollFrame.size.width, scrollFrame.size.height + keyboardHeight);
//        scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y + keyboardHeight);
//        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark UIPickerView Delegate and Data source methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 2;
}
// 返回当前列显示的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger row = 0;
    switch (component) {
        case 0:
            row = [calendarArray count];
            break;
        case 1:
            row = [ageArray count];
            break;
        default:
            break;
    }
    return row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 150;
}

// 设置当前行的内容，若果行没有显示则自动释放
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleForRow = @"";
    switch (component) {
        case 0:
            titleForRow = [calendarArray objectAtIndex:row];
            break;
        case 1:
            titleForRow = [ageArray objectAtIndex:row];
            break;
        default:
            break;
    }
    return titleForRow;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //NSString *result = [pickerView pickerView:pickerView titleForRow:row forComponent:component];
}

@end

@implementation MyLabel

@synthesize target, action;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)addTarget:(id)aTarget action:(SEL)anAction forControlEvents:(UIControlEvents)controlEvents {
    self.target = aTarget;
    self.action = anAction;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((target != nil) && [target respondsToSelector:action]) {
        [target performSelector:action withObject:self];
    }
}

@end
