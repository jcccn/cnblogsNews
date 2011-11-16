//
//  NewsDetailViewController.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/14/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface NewsDetailViewController : UIViewController <UIWebViewDelegate, ADBannerViewDelegate> {
    NSString *urlString;
    NSString *newsTitle;
    
    UIWebView *webView;
    NSString *pageHtml;
    ADBannerView *adBannerView;
    UIActivityIndicatorView *activityIndicator;
    
    NSURLConnection *connection;
    NSMutableData *bufferData;
    
}
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *newsTitle;
@property (nonatomic, retain) NSString *pageHtml;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *bufferData;

- (NSString *)convertHTMLWithBody:(NSString *)htmlBody;
- (void)htmlGettingFinshed:(NSNotification *)notification;

- (void)showPagePictures;
- (void)hidePagePictures;

@end
