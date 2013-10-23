//
//  MainViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "MainViewController.h"
#import "MTableViewCell.h"
#import "NewsDetailViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "MobClick.h"
#import "MTStatusBarOverlay.h"
#import "Constants.h"
#import "UMFeedback.h"

@interface MainViewController (Private)

- (void)dataSourceDidFinishLoadingNewData;

@end

#define DefaultPageURL  @"http://news.cnblogs.com/n/page/1/"
#define PageUrlFormat   @"http://news.cnblogs.com/n/page/%d/"
#define BaseURL         @"http://news.cnblogs.com"

#define KeyTitle    @"KeyTitle"
#define KeyUrl      @"KeyUrl"
#define KeySummary  @"KeySummary"
#define KeyContributer      @"KeyContributer"
#define KeyTag      @"KeyTag"
#define KeyComment  @"KeyComment"
#define KeyView     @"KeyView"
#define KeyTime     @"KeyTime"
#define KeyDigg     @"KeyDigg"

#define KeyNews     @"KeyNews"
#define KeyPageIndex @"PageIndex"

#define TagLabel        10000
#define TagDetailLabel  10001
#define TagTimeLabel    10002
#define TagPreButton    20001
#define TagNextButton   20002

#define TableViewCellHeight 70.0f

#define LoadDoneNotification    @"LoadDoneNotification"

@implementation MainViewController

#pragma mark -
#pragma mark View lifecycle

BOOL usingCache = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MainTitle", @"cnblogs.com");
    self.listData = [NSMutableArray array];
    
    self.tableView.scrollsToTop = YES;
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    }
    
    self.bufferData = [NSMutableData data];
	
    __weak MainViewController *weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
        [MobClick event:MobClickEventIdRefreshNewsList label:@"Start to load"];
        [weakSelf reloadTableViewDataWithPageIndex:1];
    }];
    
    if ( ! self.footerView) {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, TableViewCellHeight)];
        footView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LightCellBg.png"]];
        self.footerView = footView;
        
        CGFloat margin = (((int)self.tableView.bounds.size.width - 2 * 120) / 3) - 1.0;
        UIButton *prePageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        prePageButton.frame = CGRectMake(margin, 15, 120, 43 );
        prePageButton.tag = TagPreButton;
        [prePageButton setBackgroundImage:[UIImage imageNamed:@"buttonGray.png"] forState:UIControlStateNormal];
        [prePageButton setBackgroundImage:[UIImage imageNamed:@"buttonYellow.png"] forState:UIControlStateHighlighted];
        [prePageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [prePageButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [prePageButton setTitle:NSLocalizedString(@"PrePageText", @"Pre Page") forState:UIControlStateNormal];
        [prePageButton addTarget:self action:@selector(preButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        prePageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.footerView addSubview:prePageButton];
        
        UIButton *nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextPageButton.frame = CGRectMake(self.tableView.bounds.size.width - 120 - margin, 15, 119, 43 );
        nextPageButton.tag = TagNextButton;
        [nextPageButton setBackgroundImage:[UIImage imageNamed:@"buttonGray.png"] forState:UIControlStateNormal];
        [nextPageButton setBackgroundImage:[UIImage imageNamed:@"buttonYellow.png"] forState:UIControlStateHighlighted];
        [nextPageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nextPageButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [nextPageButton setTitle:NSLocalizedString(@"NextPageText", @"Next Page") forState:UIControlStateNormal];
        [nextPageButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        nextPageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.footerView addSubview:nextPageButton];
    }
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.currentPage = 1;
    loadingPageIndex = 1;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (usingCache) {
        self.tableView.tableFooterView = nil;
        [self loadDataWithCache];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(doneLoading:)
                                                     name:LoadDoneNotification
                                                   object:nil];
        [self reloadTableViewDataWithPageIndex:1];
        [[MTStatusBarOverlay sharedInstance] postFinishMessage:NSLocalizedString(@"WelcomeTip", @"Welcome to read cnblogs IT News") duration:3 animated:YES];
    }
}

- (void)infoButtonClicked:(id)sender {
    [MobClick event:MobClickEventIdClickInfoButton];
    [UMFeedback showFeedback:self withAppkey:MobClickAppKey];
}

- (void)preButtonClicked:(id)sender {
    [self reloadTableViewDataWithPageIndex:self.currentPage - 1];
    self.tableView.tableFooterView = nil;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.reloading = YES;

    [MobClick event:MobClickEventIdClickPrePage label:[@"At page " stringByAppendingFormat:@"%d", self.currentPage]];
}

- (void)nextButtonClicked:(id)sender {
    [self reloadTableViewDataWithPageIndex:self.currentPage + 1];
        self.tableView.tableFooterView = nil;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.reloading = YES;

    [MobClick event:MobClickEventIdClickNextPage label:[@"At page " stringByAppendingFormat:@"%d", self.currentPage]];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.connection != nil) {
        [self.connection cancel];
        self.tableView.tableFooterView = self.footerView;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *news = (NSDictionary *)[self.listData objectAtIndex:indexPath.row];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BaseURL, [news objectForKey:KeyUrl]];
    
    NewsDetailViewController *detailViewController = [[NewsDetailViewController alloc] init];
    detailViewController.urlString = urlString;
    detailViewController.newsTitle = [news objectForKey:KeyTitle];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    [MobClick event:MobClickEventIdReadNewsDetail label:[NSString stringWithFormat:@"url=%@",[news objectForKey:KeyUrl]]];
    for (NSString *newsTag in [[news objectForKey:KeyTag] componentsSeparatedByString:@"|"]) {
        [MobClick event:MobClickEventIdReadNewsDetailTag label:newsTag];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MTableViewCell";
    
    MTableViewCell *cell = (MTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibTableCells = [[NSBundle mainBundle] loadNibNamed:@"MTableViewCell" owner:self options:nil];
        cell = [nibTableCells objectAtIndex:0];
    }
    
	// Configure the cell.
	NSInteger row = [indexPath row];
    NSDictionary *news = (NSDictionary *)[self.listData objectAtIndex:row];
    
    cell.useDarkBackground = (indexPath.row % 2 == 1);
    cell.summary = [news valueForKey:KeyTitle];
    cell.popularity = [NSString stringWithFormat:@"%d%@, %@%@", 
                       [[news valueForKey:KeyView] integerValue],
                       NSLocalizedString(@"ViewerText", @"viewers"),
                       [news valueForKey:KeyDigg],
                       NSLocalizedString(@"DiggText", @"diggs")];
    cell.time = [news valueForKey:KeyTime];
    
    return cell;
}

#pragma mark-
#pragma mark data conduction

- (void)loadDataWithCache {
    NSData *cacheData = [NSData dataWithContentsOfFile:[self cacheFilePath]];
    if (cacheData) {
        self.listData = [self parseArrayWithHTMLData:cacheData];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)parseArrayWithHTMLData:(NSData *)data {
    TFHpple *xpathParser = [TFHpple hppleWithHTMLData:data];
    NSMutableArray *newsArray = [NSMutableArray arrayWithCapacity:30];
    NSArray *elements = [xpathParser searchWithXPathQuery:@"//div[@class='news_block']"];
    for (TFHppleElement *element in elements) {
        NSMutableDictionary *news = [NSMutableDictionary dictionaryWithCapacity:9];
        
        //Digg
        TFHppleElement *elementDigg = [[[[element firstChildWithClassName:@"action"] firstChildWithClassName:@"diggit"] firstChildWithClassName:@"diggnum"] firstTextChild];
        [news setValue:[elementDigg content] forKey:KeyDigg];
        
        //Title
        TFHppleElement *elementTitle = [[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"news_entry"] firstChildWithTagName:@"a"];
        NSString *newsTitle = [[elementTitle firstTextChild] content];
        [news setValue:newsTitle forKey:KeyTitle];
        
        //Url
        NSString *newsUrl = [elementTitle objectForKey:@"href"];
        [news setValue:newsUrl forKey:KeyUrl];
        
        //Summary
        TFHppleElement *elementSummary = [[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"entry_summary"] firstTextChild];
        NSString *newsSummary = [elementSummary content];
        [news setValue:newsSummary forKey:KeySummary];
        
        //Comment
        NSString *newsComment = [[[[[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"entry_footer"] firstChildWithClassName:@"comment"] firstChildWithClassName:@"gray"] firstTextChild] content];
        [news setValue:newsComment forKey:KeyComment];
        
        //View
        NSString *newsView = [[[[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"entry_footer"] firstChildWithClassName:@"view"] firstTextChild] content];
        [news setValue:newsView forKey:KeyView];
        
        //Tag
        NSMutableArray *tags = [NSMutableArray array];
        for (TFHppleElement *tagElement in [[[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"entry_footer"] firstChildWithClassName:@"tag"] childrenWithClassName:@"gray"]) {
            NSString *tag = [tagElement content];
            if (tag != nil) {
                [tags addObject:[tagElement content]];
            }
        }
        NSString *newsTag = [tags componentsJoinedByString:@"|"];
        [news setValue:newsTag forKey:KeyTag];
        
        //Contributer
        NSString *newsContributer = [[[[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"entry_footer"] firstChildWithClassName:@"gray"] firstTextChild] content];
        [news setValue:newsContributer forKey:KeyContributer];
        
        //Time
        NSString *newsTime = [[[[[[element firstChildWithClassName:@"content"] firstChildWithClassName:@"entry_footer"] childrenWithClassName:@"gray"] lastObject] firstTextChild] content];
        [news setValue:newsTime forKey:KeyTime];
        
        [newsArray addObject:news];
    }
    return newsArray;
}

- (void)reloadTableViewDataWithPageIndex:(NSInteger)index{
    loadingPageIndex = index;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:PageUrlFormat,index]]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
}
     
- (void)doneLoading:(NSNotification *)notification {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (notification) {
        NSMutableArray *newsArray = [[notification userInfo] objectForKey:KeyNews];
        if (!newsArray || [newsArray count]==0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkDataErrorTitle", "Data Error")
                                                                message:NSLocalizedString(@"NetworkDataErrorMessage", "Please check whether the network is OK")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"NetworkDataErrorOK", "OK")
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            if (! usingCache) {
                [MobClick event:MobClickEventIdRefreshNewsList label:@"Failed to load"];
            }
        }
        else {
            self.listData = [NSMutableArray arrayWithArray:newsArray];
            self.currentPage = [[[notification userInfo] objectForKey:KeyPageIndex] intValue];
            if (! usingCache) {
                [MobClick event:MobClickEventIdRefreshNewsList label:@"Succeed to load"];
            }
        }
    }
    usingCache = NO;
    
    self.reloading = NO;
    
	[self.tableView reloadData];
    self.tableView.tableFooterView = self.footerView;
    
    [self.tableView.pullToRefreshView stopAnimating];
}

- (NSString *)cacheFilePath {
    NSString* documentsDirectory  = [NSHomeDirectory() 
                                     stringByAppendingPathComponent:@"Documents"];

    return [documentsDirectory stringByAppendingPathComponent:@"cache.html"];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    UIButton *prePageButton = (UIButton *)[self.footerView viewWithTag:TagPreButton];
    if (currentPage <= 1) {
        if (prePageButton) {
            prePageButton.enabled = NO;
        }
    }
    else {
        if (prePageButton) {
            prePageButton.enabled = YES;
        }
    }
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
    NSMutableArray *newsArray = [self parseArrayWithHTMLData:self.bufferData];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoadDoneNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:newsArray, KeyNews, [NSNumber numberWithInt:loadingPageIndex], KeyPageIndex, nil]];
    self.connection = nil;
    
    if ([newsArray count] > 0) {
        NSString *cacheHtml = [[NSString alloc] initWithData:self.bufferData encoding:NSUTF8StringEncoding];
        [cacheHtml writeToFile:[self cacheFilePath]
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:LoadDoneNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array], KeyNews, [NSNumber numberWithInt:loadingPageIndex], KeyPageIndex, nil]];
    self.connection = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[self.listData removeAllObjects];
}


@end

