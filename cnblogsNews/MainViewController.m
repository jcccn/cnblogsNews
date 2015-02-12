//
//  MainViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "MainViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "UMFeedback.h"
#import "MobClick.h"
#import "MTableViewCell.h"
#import "NewsDetailViewController.h"
#import "Constants.h"

@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger loadingPage;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *bufferData;

- (void)loadDataWithCache;
- (void)loadDataAtPage:(NSInteger)page;

- (void)dataLoaded:(NSArray *)items atPage:(NSInteger)page success:(BOOL)success;

- (NSMutableArray *)parseArrayWithHTMLData:(NSData *)data;

- (NSString *)cacheFilePath;

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

@implementation MainViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MainTitle", @"cnblogs.com");
    self.listData = [NSMutableArray array];
    
    self.tableView.scrollsToTop = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    }
    
    self.bufferData = [NSMutableData data];
	
    __weak MainViewController *weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
        [MobClick event:MobClickEventIdRefreshNewsList label:@"Start to load"];
        [weakSelf loadDataAtPage:1];
    }];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"PullRefresh", @"Pull down to refresh") forState:SVPullToRefreshStateAll];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"ReleaseRrefresh", @"Release to refresh") forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"LoadingStatus", @"Loading...") forState:SVPullToRefreshStateLoading];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [MobClick event:MobClickEventIdClickNextPage label:[@"At page " stringByAppendingFormat:@"%d", weakSelf.currentPage]];
        [weakSelf loadDataAtPage:weakSelf.currentPage + 1];
    }];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.currentPage = 1;
    
    [self loadDataWithCache];
    
    [self loadDataAtPage:1];
}

- (void)infoButtonClicked:(id)sender {
    [MobClick event:MobClickEventIdClickInfoButton];
    [UMFeedback showFeedback:self withAppkey:UmengAppKey];
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

- (void)loadDataAtPage:(NSInteger)page{
    self.loadingPage = page;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:PageUrlFormat,page]]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)dataLoaded:(NSArray *)items atPage:(NSInteger)page success:(BOOL)success {
    if (success) {
        [MobClick event:MobClickEventIdRefreshNewsList label:@"Succeed to load"];
        if ([items count]) {
            if (page == 1) { //加载了第一页则是刷新
                [self.listData removeAllObjects];
            }
            self.currentPage = page;
            [self.listData addObjectsFromArray:items];
            [self.tableView reloadData];
            
            if (page == 1) {
                NSString *cacheHtml = [[NSString alloc] initWithData:self.bufferData encoding:NSUTF8StringEncoding];
                [cacheHtml writeToFile:[self cacheFilePath]
                            atomically:YES
                              encoding:NSUTF8StringEncoding
                                 error:nil];
            }
        }
    }
    else {
        [MobClick event:MobClickEventIdRefreshNewsList label:@"Failed to load"];
    }
    
    [self.tableView.pullToRefreshView stopAnimating];
    [self.tableView.infiniteScrollingView stopAnimating];
}

- (NSString *)cacheFilePath {
    NSString* documentsDirectory  = [NSHomeDirectory()
                                     stringByAppendingPathComponent:@"Documents"];
    
    return [documentsDirectory stringByAppendingPathComponent:@"cache.html"];
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    [self dataLoaded:newsArray atPage:self.loadingPage success:YES];
    
    self.connection = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self dataLoaded:nil atPage:self.loadingPage success:NO];
    
    self.connection = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [self.listData removeAllObjects];
    [self.tableView reloadData];
}

- (void)dealloc {
	[self.listData removeAllObjects];
}


@end

