//
//  MTableViewCell.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/13/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTableViewCell : UITableViewCell {
    BOOL useDarkBackground;
    
    NSString *summary;
    NSString *polularity;
    NSString *time;
    
    IBOutlet UILabel *summaryLabel;
    IBOutlet UILabel *popularityLabel;
    IBOutlet UILabel *timeLabel;
}

@property (nonatomic, assign) BOOL useDarkBackground;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *popularity;
@property (nonatomic, retain) NSString *time;


@end
