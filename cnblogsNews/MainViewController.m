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
#import "EGORefreshTableHeaderView.h"
#import "MobClick.h"
#import "Constants.h"

@interface MainViewController (Private)

- (void)dataSourceDidFinishLoadingNewData;

@end

#define WebSite @"http://news.cnblogs.com"

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

#define TagLabel        10000
#define TagDetailLabel  10001
#define TagTimeLabel    10002

#define TableViewCellHeight 70.0f

#define LoadDoneNotification    @"LoadDoneNotification"

@implementation MainViewController

@synthesize listData;
@synthesize reloading=_reloading;

#pragma mark -
#pragma mark View lifecycle

BOOL usingCache = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MainTitle", @"cnblogs.com");
    self.listData = [NSMutableArray array];
    self.tableView.scrollsToTop = YES;
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (usingCache) {
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
        [self loadDataWithCache];
//        usingCache = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(doneLoading:)
                                                     name:LoadDoneNotification
                                                   object:nil];
        [self reloadTableViewDataSource];

    }
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *news = (NSDictionary *)[listData objectAtIndex:indexPath.row];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",WebSite, [news objectForKey:KeyUrl]];
    
    NewsDetailViewController *detailViewController = [[NewsDetailViewController alloc] init];
    detailViewController.urlString = urlString;
    detailViewController.newsTitle = [news objectForKey:KeyTitle];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    [MobClick event:MobClickEventIdReadNewsDetail label:[news objectForKey:KeyUrl]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}


/*
 // Override to support row selection in the table view.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
 // Navigation logic may go here -- for example, create and push another view controller.
 // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
 // [self.navigationController pushViewController:anotherViewController animated:YES];
 // [anotherViewController release];
 }
 */


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listData count];
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
    NSDictionary *news = (NSDictionary *)[listData objectAtIndex:row];
    
    cell.useDarkBackground = (indexPath.row % 2 == 1);
    cell.summary = [news valueForKey:KeyTitle];
    cell.popularity = [NSString stringWithFormat:@"%@%@, %@%@", 
                       [news valueForKey:KeyView],
                       NSLocalizedString(@"ViewerText", @"viewers"),
                       [news valueForKey:KeyDigg],
                       NSLocalizedString(@"DiggText", @"diggs")];
    cell.time = [news valueForKey:KeyTime];
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark-
#pragma mark data conduction

- (void)loadDataWithCache {
//    [refreshHeaderView setState:EGOOPullRefreshLoading];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
//    [UIView commitAnimations];
    
    NSData *cacheData = [NSData dataWithContentsOfFile:[self cacheFilePath]];
    if (cacheData) {
        self.listData = [self parseArrayWithHTMLData:cacheData];
        [self.tableView reloadData];
    }
    
//    [self reloadTableViewDataSource];
    
}

- (void)setLoadData{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSData *siteData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:WebSite]];
	NSMutableArray *newsArray = [self parseArrayWithHTMLData:siteData];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoadDoneNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:newsArray forKey:KeyNews]];
    if ([newsArray count] > 0) {
        NSString *cacheHtml = [[NSString alloc] initWithData:siteData encoding:NSUTF8StringEncoding];
        [cacheHtml writeToFile:[self cacheFilePath]
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
        [cacheHtml release];
    }
    
    [pool release];
}

- (NSMutableArray *)parseArrayWithHTMLData:(NSData *)data {
    TFHpple *xpathParser = [TFHpple hppleWithHTMLData:data];
    NSMutableArray *newsArray = [NSMutableArray arrayWithCapacity:30];
    NSArray *elements = [xpathParser searchWithXPathQuery:@"//div[@class='news_block']"];
    for (TFHppleElement *element in elements) {
        NSMutableDictionary *news = [NSMutableDictionary dictionaryWithCapacity:9];
        
        //Digg
        TFHppleElement *elementDigg = [[[element firstChild] firstChild] firstChild];
        [news setValue:[elementDigg content] forKey:KeyDigg];
        
        NSArray *children = nil;
        for (TFHppleElement *ele in [element children]) {
            if ([[[ele attributes] objectForKey:@"class"] isEqualToString:@"content"]) {
                children = [ele children];
            }
        }
        
        //Title
        TFHppleElement *elementTitle = [[[children objectAtIndex:0] children] objectAtIndex:0];
        NSString *newsTitle = [elementTitle content];
        [news setValue:newsTitle forKey:KeyTitle];
        
        //Url
        NSString *newsUrl = [elementTitle objectForKey:@"href"];
        [news setValue:newsUrl forKey:KeyUrl];
        
        //Summary
        TFHppleElement *elementSummary = [children objectAtIndex:1];
        NSString *newsSummary = [elementSummary content];
        [news setValue:newsSummary forKey:KeySummary];
        
        NSArray *elementsFooter = [[children objectAtIndex:2] children];
        for (TFHppleElement *elementFooter in elementsFooter) {
            
            //Comment
            if ([[[elementFooter attributes] objectForKey:@"class"] isEqualToString:@"comment"]) {
                NSString *newsComment = [[[elementFooter children] objectAtIndex:0] content];
                [news setValue:newsComment forKey:KeyComment]; 
            }
            
            //View
            else if ([[[elementFooter attributes] objectForKey:@"class"] isEqualToString:@"view"]) {
                NSString *newsView = [NSString stringWithFormat:@"%d",[[elementFooter content] intValue]];
                [news setValue:newsView forKey:KeyView]; 
            }
            
            //Tag
            else if ([[[elementFooter attributes] objectForKey:@"class"] isEqualToString:@"tag"]) {
                NSString *newsTag = @"";
                for (TFHppleElement *tagElement in [elementFooter children]) {
                    newsTag = [newsTag stringByAppendingFormat:@" %@",[tagElement content]];
                }
                [news setValue:newsTag forKey:KeyTag]; 
            }
            
            else if ([[[elementFooter attributes] objectForKey:@"class"] isEqualToString:@"gray"]) {
                //Contributer
                if ([[elementFooter tagName] isEqualToString:@"a"]) {
                    NSString *newsContributer = [elementFooter content];
                    [news setValue:newsContributer forKey:KeyContributer];
                }
                //Time
                else if ([[elementFooter tagName] isEqualToString:@"span"]) {
                    NSString *newsTime = [elementFooter content];
                    [news setValue:newsTime forKey:KeyTime];
                }
            }
        }
        
        [newsArray addObject:news];
    }
    return newsArray;
}

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload
	//  put here just for demo
    [self performSelectorInBackground:@selector(setLoadData) withObject:nil];
//	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}


- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[self dataSourceDidFinishLoadingNewData];
}
     
- (void)doneLoading:(NSNotification *)notification {
    if (notification) {
        NSMutableArray *newsArray = [[notification userInfo] objectForKey:KeyNews];
        if (!newsArray || [newsArray count]==0) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkDataErrorTitle", "Data Error")
                                                                message:NSLocalizedString(@"NetworkDataErrorMessage", "Please check whether the network is OK")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"NetworkDataErrorOK", "OK")
                                                      otherButtonTitles:nil, nil] autorelease];
            [alertView show];
            if (! usingCache) {
                [MobClick event:MobClickEventIdRefreshNewsList label:@"Failed to load"];
            }
        }
        else {
            self.listData = newsArray;
            if (! usingCache) {
                [MobClick event:MobClickEventIdRefreshNewsList label:@"Succeed to load"];
            }
        }
    }
    usingCache = NO;
    [self performSelector:@selector(doneLoadingTableViewData)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
        [MobClick event:MobClickEventIdRefreshNewsList label:@"Start to load"];
	}
}

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	[self.tableView reloadData];
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

- (NSString *)cacheFilePath {
    NSString* documentsDirectory  = [NSHomeDirectory() 
                                     stringByAppendingPathComponent:@"Documents"];

    return [documentsDirectory stringByAppendingPathComponent:@"cache.html"];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	refreshHeaderView=nil;
}

- (void)dealloc {
	[listData release];
    [super dealloc];
}


@end

