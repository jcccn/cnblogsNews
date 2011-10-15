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
    ADBannerView *adBannerView;
}
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *newsTitle;

- (void)startLoadPage;
- (NSString *)convertHTMLWithBody:(NSString *)htmlBody;

@end
