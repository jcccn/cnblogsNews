//
//  MainViewController.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"

@class EGORefreshTableHeaderView;

@interface MainViewController : UITableViewController {

    NSMutableArray *listData;

    EGORefreshTableHeaderView *refreshHeaderView;
    UIView *footerView;

    BOOL _reloading;
    
    NSInteger currentPage;
    NSInteger loadingPageIndex;
    
    NSURLConnection *connection;
    NSMutableData *bufferData;
}

@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) UIView *footerView;
@property (assign, getter=isReloading) BOOL reloading;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *bufferData;

- (void)reloadTableViewDataWithPageIndex:(NSInteger)index;
- (void)doneLoadingTableViewData;

- (void)loadDataWithCache;
- (NSMutableArray *)parseArrayWithHTMLData:(NSData *)data;

- (NSString *)cacheFilePath;

@end
