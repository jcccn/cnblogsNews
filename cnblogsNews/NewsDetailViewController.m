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
#import <ShareSDK/ShareSDK.h>
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "DNEvernoteUtil.h"

#define TagWebView  1001

#define HTMLDoneNotification    @"HTMLDoneNotification"
#define KeyHtml                 @"KeyHtml"

@interface NewsDetailViewController()

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSString *htmlBody;

- (void)refreshTheNews;

- (void)shareTheNews;

-(void)layoutForCurrentOrientation:(BOOL)animated;

-(void)createADBannerView;

- (NSString *)evernoteContentForHtml:(NSString *)html;

@end

@implementation NewsDetailViewController

@synthesize urlString, newsTitle, pageHtml, webView, connection, bufferData;

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
    CGFloat height = [[UIScreen mainScreen] applicationFrame].size.height - self.navigationController.navigationBar.frame.size.height;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, height)];
    self.view = view;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"MainTitle", @"cnblogs.com");
    if (self.webView == nil) {
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
        self.webView.frame = self.view.bounds;
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.scalesPageToFit = NO;
        self.webView.tag = TagWebView;
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
    
    connection = nil;
    self.bufferData = [NSMutableData data];
    
    // If the banner wasn't included in the nib, create one.
    if ( ! activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = webView.center;
        activityIndicator.hidesWhenStopped = YES;
        [activityIndicator startAnimating];
        [self.view addSubview:activityIndicator];
    }
    
    if(adBannerView == nil) {
        [self createADBannerView];
    }
    [self layoutForCurrentOrientation:NO];
    
    __weak NewsDetailViewController *blockSelf = self;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                     handler:^(id sender) {
                                                                                         [blockSelf refreshTheNews];
                                                                                     }];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                   handler:^(id sender) {
                                                                                       [blockSelf shareTheNews];
                                                                                   }];
    self.navigationItem.rightBarButtonItems = @[refreshButton, shareButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(htmlGettingFinshed:)
                                                 name:HTMLDoneNotification
                                               object:nil];
    
    [self performSelector:@selector(refreshTheNews) withObject:nil afterDelay:0.1f];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForCurrentOrientation:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForCurrentOrientation:YES];
}

- (void)refreshTheNews {
    [self.connection cancel];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)createADBannerView
{
    if ( ! iAdShowFlag) {
        return;
    }
    
	NSString *contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
	
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.view.bounds));
    
    adBannerView = [[ADBannerView alloc] initWithFrame:frame];
    adBannerView.delegate = self;
    adBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:adBannerView];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    if ( ! iAdShowFlag) {
        return;
    }
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    adBannerView.currentContentSizeIdentifier = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait);
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

- (void)htmlGettingFinshed:(NSNotification *)notification {
    if (notification) {
        NSString *html = [[notification userInfo] objectForKey:KeyHtml];
        self.pageHtml = html;
        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:self.urlString]];
//        [self hidePagePictures];
    }
    if (activityIndicator) {
        [activityIndicator stopAnimating];
    }
}


- (NSString *)convertHTMLWithBody:(NSString *)htmlBody {
    NSString *htmlCode = [NSString stringWithFormat:@"<html xml:lang=\"zh-CN\" xmlns=\"http://www.w3.org/1999/xhtml\"><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><title>cnblogs</title><style type=\"text/css\">body {background-color:%@; font-family: \"%@\"; font-size: %d; color: %@; }.topic_img{float:right;padding-left:10px;padding-right:15px;}</style></head><body><center>%@</center><hr>%@</body></html>", @"#FFFFFF", @"Arial", 16, @"#010101", self.newsTitle, htmlBody];
    return htmlCode;
}

- (NSString *)convertToHTMLWithoutPicture:(NSString *)htmlBody {
    NSScanner *aScanner;
    NSString *htmlNoPic = htmlBody;
    NSString *picTag = @"+-x/+-x/";
    BOOL seekOver = NO;
    do {
        NSString *picutureSegment = @"";
        aScanner = [NSScanner scannerWithString:htmlNoPic];
        [aScanner scanUpToString:@"<img" intoString:NULL];
        [aScanner scanUpToString:@">" intoString:&picutureSegment];
        if ([picutureSegment length] > 0) {
            htmlNoPic = [htmlNoPic stringByReplacingOccurrencesOfString:[picutureSegment stringByAppendingString:@">"] withString:picTag];
        }
        else {
            seekOver = YES;
        }
    } while (! seekOver);
//    NSString *defaultPicUrl = [NSString stringWithFormat:@"<img src=\"file:/%@\" width=\"210\" height=\"50\" border=\"0\">",[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];
    NSString *defaultPicUrl = [NSString stringWithFormat:@"<img src=\"%@\" width=\"210\" height=\"50\" border=\"0\">", [[[NSBundle mainBundle] URLForResource:@"Icon" withExtension:@"png"] absoluteString]];
    NSLog(@"defaultPicUrl = %@", defaultPicUrl);
    htmlNoPic = [htmlNoPic stringByReplacingOccurrencesOfString:picTag withString:defaultPicUrl];
    
    return htmlNoPic;
}

- (void)showPagePictures {
    [webView loadHTMLString:self.pageHtml baseURL:[NSURL URLWithString:self.urlString]];
}

- (void)hidePagePictures {
    [webView loadHTMLString:[self convertToHTMLWithoutPicture:self.pageHtml] baseURL:[NSURL URLWithString:self.urlString]];
}

- (void)shareTheNews {
    NSString *content = [NSString stringWithFormat:@"%@ %@ 下载「博客园新闻」看更多：%@", self.newsTitle, self.urlString, AppStoreShortUrl];
    
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:[@"博客园新闻 " stringByAppendingString:AppStoreUrl]
                                                image:nil
                                                title:@"博客园新闻"
                                                  url:self.urlString
                                          description:content
                                            mediaType:SSPublishContentMediaTypeText];
    
    //定制不同平台的分享内容
    //微信
    //印象笔记
    [publishContent addEvernoteUnitWithContent:[self evernoteContentForHtml:self.htmlBody]
                                         title:(self.newsTitle ? self.newsTitle : @"")
                                     resources:nil];
    //有道
    //QQ
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    [authOptions setPowerByHidden:YES];
    
    NSMutableArray *shareList = [NSMutableArray array];
    [shareList addObjectsFromArray:[ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeEvernote, nil]];
    if ([WXApi isWXAppInstalled]) {
        [shareList addObjectsFromArray:[ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeWeixiFav, nil]];
    }
    if ([QQApiInterface isQQInstalled] || [QQApiInterface isQQSupportApi]) {
        [shareList addObjectsFromArray:[ShareSDK getShareListWithType:ShareTypeQQ, ShareTypeQQSpace, nil]];
    }
    [shareList addObjectsFromArray:[ShareSDK getShareListWithType:
                                    ShareTypePocket,
                                    ShareTypeMail,
                                    ShareTypeCopy,
                                    ShareTypeAirPrint,nil]];
    
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"博客园新闻"
                                                              oneKeyShareList:shareList
                                                               qqButtonHidden:NO
                                                        wxSessionButtonHidden:NO
                                                       wxTimelineButtonHidden:NO
                                                         showKeyboardOnAppear:NO
                                                            shareViewDelegate:nil
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];
    
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithBarButtonItem:[self.navigationItem.rightBarButtonItems lastObject]
                                     arrowDirect:UIPopoverArrowDirectionUp];
    [container setIPhoneContainerWithViewController:self];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess) {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail) {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                }
                            }];
}

- (NSString *)evernoteContentForHtml:(NSString *)html {
    if ( ! [html length]) {
        return @"";
    }
    NSString *content = [[DNEvernoteUtil sharedClient] convertToENML:html];
    
    TFHpple *hpple = [TFHpple hppleWithData:[content dataUsingEncoding:NSUTF8StringEncoding] isXML:YES];
    TFHppleElement *element = [hpple peekAtSearchWithXPathQuery:@"//en-note"];
    
    //TODO:产生太多的中间字符串，可以优化
    content = [element raw];
    content = [content stringByReplacingOccurrencesOfString:@"<en-note>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"</en-note>" withString:@""];
    
    return content;
}


#pragma mark -
#pragma mark WebviewDeledate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [[[request URL] absoluteString] isEqualToString:self.urlString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.bufferData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.bufferData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSScanner *aScanner;
    NSString *htmlBody = @"";
    aScanner = [NSScanner scannerWithString:[[NSString alloc] initWithData:self.bufferData encoding:NSUTF8StringEncoding]];
    [aScanner scanUpToString:@"<div id=\"news_body\">" intoString:NULL];
    [aScanner scanUpToString:@"</div>" intoString:&htmlBody];
    if ([htmlBody length] > 0) {
        htmlBody = [htmlBody stringByAppendingString:@"</div>"];
        
    }
    
    self.htmlBody = htmlBody;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HTMLDoneNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[self convertHTMLWithBody:htmlBody] forKey:KeyHtml]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (activityIndicator) {
        [activityIndicator stopAnimating];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutForCurrentOrientation:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
//    [self layoutForCurrentOrientation:YES];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    [MobClick event:MobClickEventIdClickiAdBanner label:@"News Detail"];
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
}

@end
