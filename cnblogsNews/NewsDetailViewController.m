//
//  NewsDetailViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/14/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "TFHpple.h"
#import "MobClick.h"
#import "Constants.h"

#define TagWebView  1001

@interface NewsDetailViewController()

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
-(void)layoutForCurrentOrientation:(BOOL)animated;

// A simple method that creates an ADBannerView
// Useful if you need to create the banner view in code
// such as when designing a universal binary for iPad
-(void)createADBannerView;

@end

@implementation NewsDetailViewController

@synthesize urlString, newsTitle;

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


 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    self.view = view;
    [view release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (webView == nil) {
        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        webView.frame = CGRectMake(0, 0, 320, 416);
        webView.backgroundColor = [UIColor whiteColor];
        webView.scalesPageToFit = NO;
        webView.tag = TagWebView;
        // remove shadow view when drag web view
        for (UIView *subView in [webView subviews]) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                for (UIView *shadowView in [subView subviews]) {
                    if ([shadowView isKindOfClass:[UIImageView class]]) {
                        shadowView.hidden = YES;
                    }
                }
            }
        }
        [self.view addSubview:webView];
    }
    
    // If the banner wasn't included in the nib, create one.
    if(adBannerView == nil)
        {
        [self createADBannerView];
        }
    [self layoutForCurrentOrientation:NO];
    
    [self performSelector:@selector(startLoadPage) withObject:nil afterDelay:0.1f];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForCurrentOrientation:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForCurrentOrientation:YES];
}

- (void)dealloc {
    [adBannerView release];
    [webView release];
    [super dealloc];
}

-(void)createADBannerView
{
    // --- WARNING ---
    // If you are planning on creating banner views at runtime in order to support iOS targets that don't support the iAd framework
    // then you will need to modify this method to do runtime checks for the symbols provided by the iAd framework
    // and you will need to weaklink iAd.framework in your project's target settings.
    // See the iPad Programming Guide, Creating a Universal Application for more information.
    // http://developer.apple.com/iphone/library/documentation/general/conceptual/iPadProgrammingGuide/Introduction/Introduction.html
    // --- WARNING ---
    
    // Depending on our orientation when this method is called, we set our initial content size.
    // If you only support portrait or landscape orientations, then you can remove this check and
    // select either ADBannerContentSizeIdentifierPortrait (if portrait only) or ADBannerContentSizeIdentifierLandscape (if landscape only).
	NSString *contentSize;
	if (&ADBannerContentSizeIdentifierPortrait != nil) {
		contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
    }
	else {
		// user the older sizes 
		contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
    }
	
    // Calculate the intial location for the banner.
    // We want this banner to be at the bottom of the view controller, but placed
    // offscreen to ensure that the user won't see the banner until its ready.
    // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.view.bounds));
    
    // Now to create and configure the banner view
    adBannerView = [[ADBannerView alloc] initWithFrame:frame];
    // Set the delegate to self, so that we are notified of ad responses.
    adBannerView.delegate = self;
    // Set the autoresizing mask so that the banner is pinned to the bottom
    adBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    // Since we support all orientations in this view controller, support portrait and landscape content sizes.
    // If you only supported landscape or portrait, you could remove the other from this set.
    
	adBannerView.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
    [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
    [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
    
    // At this point the ad banner is now be visible and looking for an ad.
    [self.view addSubview:adBannerView];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		adBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
    }
    else {
        adBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
    }
    bannerHeight = adBannerView.bounds.size.height; 
	
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(adBannerView.bannerLoaded) {
        contentFrame.size.height -= bannerHeight;
		bannerOrigin.y -= bannerHeight;
    }
    else {
		bannerOrigin.y += bannerHeight;
    }

    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         webView.frame = contentFrame;
                         [webView layoutIfNeeded];
                         adBannerView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, adBannerView.frame.size.width, adBannerView.frame.size.height);
                     }];
}

#pragma mark -
#pragma mark Data

- (void)startLoadPage {
    NSData *siteData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.urlString]];
    //	TFHpple *xpathParser = [TFHpple hppleWithHTMLData:siteData];
    //    TFHppleElement *element = [xpathParser peekAtSearchWithXPathQuery:@"//div[id='news_body']"];
    //    NSString *htmlBody = [element content];
    NSScanner *aScanner;
    NSString *htmlBody = @"";
    aScanner = [NSScanner scannerWithString:[[[NSString alloc] initWithData:siteData encoding:NSUTF8StringEncoding] autorelease]];
    [aScanner scanUpToString:@"<div id=\"news_body\">" intoString:NULL];
    [aScanner scanUpToString:@"</div>" intoString:&htmlBody];
    if ([htmlBody length] > 0) {
        htmlBody = [htmlBody stringByAppendingString:@"</div>"];
        
    }
    [webView loadHTMLString:[self convertHTMLWithBody:htmlBody] baseURL:[NSURL URLWithString:self.urlString]];
    
    
}

- (NSString *)convertHTMLWithBody:(NSString *)htmlBody {
    NSString *htmlCode = [NSString stringWithFormat:@"<html xml:lang=\"zh-CN\" xmlns=\"http://www.w3.org/1999/xhtml\"><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><title>cnblogs</title><style type=\"text/css\">body {background-color:%@; font-family: \"%@\"; font-size: %d; color: %@; }.topic_img{float:right;padding-left:10px;padding-right:15px;}</style></head><body><center>%@</center><hr>%@</body></html>", @"#FFFFFF", @"Arial", 16, @"#010101", self.newsTitle, htmlBody];
    return htmlCode;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [[[request URL] absoluteString] isEqualToString:self.urlString];
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutForCurrentOrientation:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self layoutForCurrentOrientation:YES];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    [MobClick event:MobClickEventIdClickiAdBanner label:@"News Detail"];
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
}

@end
