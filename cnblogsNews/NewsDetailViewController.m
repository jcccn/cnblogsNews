//
//  NewsDetailViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/14/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "TFHpple.h"

#define TagWebView  1001

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (webView == nil) {
        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        webView.frame = CGRectMake(0, 0, 320, 416);
        webView.scalesPageToFit = NO;
        webView.tag = TagWebView;
        [self.view addSubview:webView];
    }
    
    [self performSelector:@selector(startLoadPage) withObject:nil afterDelay:0.1f];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [webView release];
    [super dealloc];
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

@end
