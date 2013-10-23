//
//  MainViewController.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"

@interface MainViewController : UITableViewController {
    NSInteger loadingPageIndex;
}

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) UIView *footerView;
@property (assign, getter=isReloading) BOOL reloading;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *bufferData;

- (void)reloadTableViewDataWithPageIndex:(NSInteger)index;
- (void)doneLoadingTableViewData;

- (void)loadDataWithCache;
- (NSMutableArray *)parseArrayWithHTMLData:(NSData *)data;

- (NSString *)cacheFilePath;

@end
