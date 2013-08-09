//
//  FeedbackViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/19/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "FeedbackViewController.h"
#import "MobClick.h"
#import "UMFeedback.h"

#define KEYBOARD_POP_DURATION 0.3f

#define NAString (@"N/A")

@implementation FeedbackViewController

@synthesize sendButtonItem;

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
    
    self.sendButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PublishButtonTitle", @"Publish") style:UIBarButtonItemStyleDone target:self action:@selector(feedback:)];
    
    #if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isIPHONE = NO;
        
    } else {
        isIPHONE = YES;
    }
    #endif
    
    genderArray = [NSArray arrayWithObjects:NSLocalizedString(@"GenderText0", @"Gender"),
                    NSLocalizedString(@"GenderText1", @"Male"),
                    NSLocalizedString(@"GenderText2", @"Female"), nil];
    ageArray = [NSArray arrayWithObjects:NSLocalizedString(@"AgeText0", @"Your age"),
                 NSLocalizedString(@"AgeText1", @"Below 18(18 not included)"),
                 NSLocalizedString(@"AgeText2", @"18 - 24"),
                 NSLocalizedString(@"AgeText3", @"25 - 30"),
                 NSLocalizedString(@"AgeText4", @"31 - 35"),
                 NSLocalizedString(@"AgeText5", @"36 - 40"),
                 NSLocalizedString(@"AgeText6", @"41 - 50"),
                 NSLocalizedString(@"AgeText7", @"51 - 59"),
                 NSLocalizedString(@"AgeText8", @"60 and above"), nil];
    genderString = NAString;
    ageString = NAString;
    
    CGRect viewRect = self.view.bounds;
    
    scrollView = [[UIScrollView alloc] initWithFrame:viewRect];
    scrollView.contentSize = CGSizeMake(viewRect.size.width, viewRect.size.height+1);
    [self.view addSubview:scrollView];
    
    headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, viewRect.size.width-10, 100)];
    headlineLabel.numberOfLines = 0;
    headlineLabel.backgroundColor = [UIColor clearColor];
    headlineLabel.text = NSLocalizedString(@"FeedbackHeadline", @"    Welcomes your comments and suggestions. every word you left will be used to improve our products and services.");
    [scrollView addSubview:headlineLabel];
    
    genderAgeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 110, viewRect.size.width-20, 40)];
    [genderAgeButton setTitle:NSLocalizedString(@"GenderAgePlaceholder", @"Tap to select gender and age") forState:UIControlStateNormal];
    [genderAgeButton addTarget:self action:@selector(calendarAgeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [genderAgeButton setBackgroundColor:[UIColor grayColor]];
    [scrollView addSubview:genderAgeButton];
    
    feedbackTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 160, viewRect.size.width - 10, 250)];
    feedbackTextView.text = @"";
    feedbackTextView.font = [UIFont systemFontOfSize:14];
    feedbackTextView.backgroundColor = [UIColor clearColor];
    UITextField *background = [[UITextField alloc] initWithFrame:feedbackTextView.bounds];
    background.userInteractionEnabled = NO;
    background.borderStyle = UITextBorderStyleRoundedRect;
    [feedbackTextView addSubview:background];
    [feedbackTextView sendSubviewToBack:background];
    feedbackTextView.delegate = self;
    [scrollView addSubview:feedbackTextView];    
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, viewRect.size.height - 44 - 200, viewRect.size.width, 200)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.hidden = YES;
    pickerView.delegate = self;
    UIButton *calendarAgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calendarAgeButton.frame = CGRectMake(0, 0, 137, 40);
    [self.view addSubview:pickerView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)calendarAgeButtonClicked:(id)sender {
    [self setEditing:NO animated:YES];
    if ( ! pickerView.hidden) {
        if ([self isGenderAgeFilloutOk]) {
            [genderAgeButton setTitle:[NSString stringWithFormat:@"%@ , %@", genderString, ageString] forState:UIControlStateNormal];
            pickerView.hidden = YES;
        }
    }
    else {
        pickerView.hidden = NO;
        [genderAgeButton setTitle:NSLocalizedString(@"GenderAgeConfirmPlaceholder", @"Tap to confirm gender and age") forState:UIControlStateNormal];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if (editing) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.sendButtonItem;
        [feedbackTextView resignFirstResponder];
    }
}

- (BOOL)isGenderAgeFilloutOk {
    BOOL isOk = YES;
    if (([genderString isEqualToString:NAString] || [ageString isEqualToString:NAString])) {
        isOk = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GenderAgeErrorTitle", "Not filled out")
                                                             message:NSLocalizedString(@"GenderAgeErrorMessage", "Please fill out the gender and age")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"GenderAgeErrorOK", "OK")
                                                   otherButtonTitles:nil, nil];
        [alertView show];
    }
    return isOk;
}

- (BOOL)isContentFilloutOK {
    BOOL isOK = YES;
    if ([feedbackTextView.text length] == 0) {
        isOK = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ContentErrorTitle", "Not filled out")
                                                             message:NSLocalizedString(@"ContentErrorMessage", "Please fill out the feed back content")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"ContentErrorOK", "OK")
                                                   otherButtonTitles:nil, nil];
        [alertView show];
    }
    return isOK;
}

- (void)feedback:(id)sender {
    if ([self isGenderAgeFilloutOk] && [self isContentFilloutOK]) {
        NSMutableDictionary *feedbackDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [feedbackDict setValue:[NSString stringWithFormat:@"%d", [genderArray indexOfObject:genderString]] forKey:@"gender"];
        [feedbackDict setValue:[NSString stringWithFormat:@"%d", [ageArray indexOfObject:ageString]] forKey:@"age_group"];
        [feedbackDict setValue:feedbackTextView.text forKey:@"content"];
        [[UMFeedback sharedInstance] post:feedbackDict];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark UITextView Delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setEditing:YES animated:YES];
    [genderAgeButton setTitle:(([genderString isEqualToString:NAString] || [ageString isEqualToString:NAString]) ? NSLocalizedString(@"GenderAgePlaceholder", @"Tap to select gender and age") : [NSString stringWithFormat:@"%@ , %@", genderString, ageString]) forState:UIControlStateNormal];
    pickerView.hidden = YES;
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
        [UIView commitAnimations];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (isIPHONE) {
        int keyboardHeight = 218;
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            keyboardHeight = 160;
        }
        CGRect scrollFrame = scrollView.frame;
        scrollView.frame = CGRectMake(scrollFrame.origin.x, scrollFrame.origin.y, scrollFrame.size.width, scrollFrame.size.height + keyboardHeight);
    }
}

#pragma mark -
#pragma mark UIPickerView Delegate and Data source methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger row = 0;
    switch (component) {
        case 0:
            row = [genderArray count];
            break;
        case 1:
            row = [ageArray count];
            break;
        default:
            break;
    }
    return row;
}

- (CGFloat)pickerView:(UIPickerView *)apickerView widthForComponent:(NSInteger)component {
    CGFloat width = (pickerView.bounds.size.width - 20) / 3;
    if (component == 1) {
        width *= 2;
    }
    return width;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *titleForRow = @"";
    switch (component) {
        case 0:
            titleForRow = [genderArray objectAtIndex:row];
            break;
        case 1:
            titleForRow = [ageArray objectAtIndex:row];
            break;
        default:
            break;
    }
    return titleForRow;
}
- (void)pickerView:(UIPickerView *)apickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSString *result = [pickerView pickerView:pickerView titleForRow:row forComponent:component];
    if (component == 0) {
        if (row == 0) {
            genderString = NAString;
        }
        else {
            genderString = [self pickerView:pickerView titleForRow:row forComponent:component];
        }
    }
    else {
        if (row == 0) {
            ageString = NAString;
        }
        else {
            ageString = [self pickerView:pickerView titleForRow:row forComponent:component];
        }
    }
}

@end