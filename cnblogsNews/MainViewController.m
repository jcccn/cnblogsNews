//
//  MainViewController.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "MainViewController.h"
#import "NewsDetailViewController.h"
#import "EGORefreshTableHeaderView.h"

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

#define LoadNoneNotification    @"LoadNoneNotification"

@implementation MainViewController

@synthesize listData;
@synthesize reloading=_reloading;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MainTitle", @"cnblogs.com");
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doneLoading:)
                                                 name:LoadNoneNotification
                                               object:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(setLoadData) withObject:nil];
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@",WebSite,
    [(NSDictionary *)[listData objectAtIndex:indexPath.row] objectForKey:KeyUrl]];
    
    NewsDetailViewController *detailViewController = [[NewsDetailViewController alloc] init];
    detailViewController.urlString = urlString;
    detailViewController.newsTitle = [(NSDictionary *)[listData objectAtIndex:indexPath.row] objectForKey:KeyTitle];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.backgroundView = bgView;
        [bgView release];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        textLabel.numberOfLines = 2;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.tag = TagLabel;
        textLabel.frame = CGRectMake(10, 0, cell.contentView.bounds.size.width-40, TableViewCellHeight*2/3);
        [cell.contentView addSubview:textLabel];
        [textLabel release];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.tag = TagDetailLabel;
        detailLabel.frame = CGRectMake(10, TableViewCellHeight*2/3, 160, TableViewCellHeight/3);
        detailLabel.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:detailLabel];
        [detailLabel release];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 12)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.lineBreakMode = UILineBreakModeClip;
        timeLabel.tag = TagTimeLabel;
        timeLabel.frame = CGRectMake(cell.contentView.bounds.size.width-120, TableViewCellHeight*2/3, 100, TableViewCellHeight/3);
        timeLabel.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:timeLabel];
        [timeLabel release];
    }
    
	// Configure the cell.
	NSInteger row = [indexPath row];
    if (indexPath.row % 2 == 0) {
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    }
    else {
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    NSDictionary *news = (NSDictionary *)[listData objectAtIndex:row];
    
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:TagLabel];
    if (textLabel) {
        textLabel.text = [news valueForKey:KeyTitle];

    }
    
    UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:TagDetailLabel];
    if (detailLabel) {
        detailLabel.text = [NSString stringWithFormat:@"%@, %@%@", 
                            [news valueForKey:KeyView],
                            [news valueForKey:KeyDigg],
                            NSLocalizedString(@"DiggText", @"diggs")];
    }
    
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:TagTimeLabel];
    if (timeLabel) {
        timeLabel.text = [news valueForKey:KeyTime];
    }
    
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

- (void)setLoadData{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *siteData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:WebSite]];
	
	TFHpple *xpathParser = [TFHpple hppleWithHTMLData:siteData];
    NSMutableArray *newsArray = [NSMutableArray arrayWithCapacity:30];
    NSArray *elements = [xpathParser searchWithXPathQuery:@"//div[@class='news_block']"];
    for (TFHppleElement *element in elements) {
        NSMutableDictionary *news = [NSMutableDictionary dictionaryWithCapacity:3];
        
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
                NSString *newsView = [elementFooter content];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LoadNoneNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:newsArray forKey:KeyNews]];
    [pool release];
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
        self.listData = newsArray;
    }
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

