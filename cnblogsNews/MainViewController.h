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

//  Reloading should really be your tableviews model class
//  Putting it here for demo purposes 
BOOL _reloading;

}

@property(nonatomic,retain) NSMutableArray *listData;

@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
