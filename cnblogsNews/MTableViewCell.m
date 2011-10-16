//
//  MTableViewCell.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/13/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "MTableViewCell.h"

@implementation MTableViewCell
@synthesize useDarkBackground, summary, popularity, time;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUseDarkBackground:(BOOL)_useDarkBackground
{
    if (_useDarkBackground != useDarkBackground || !self.backgroundView)
        {
        useDarkBackground = _useDarkBackground;
        
//        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
//        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
//        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
//        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.backgroundView.frame = self.bounds;
        
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
        CGFloat color = useDarkBackground ? 0.9f: 1.0f;
        UIColor *backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0f];
        self.backgroundView.backgroundColor = backgroundColor;
        summaryLabel.backgroundColor = backgroundColor;
        popularityLabel.backgroundColor = backgroundColor;
        timeLabel.backgroundColor = backgroundColor;
        }
}

- (void)setSummary:(NSString *)_summary {
    summary = _summary;
    summaryLabel.text = summary;
}

- (void)setPopularity:(NSString *)_popularity {
    popularity = _popularity;
    popularityLabel.text = popularity;
}

- (void)setTime:(NSString *)_time {
    time = _time;
    timeLabel.text = time;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = summaryLabel.frame;
    frame.size.width = self.bounds.size.width-40;
    summaryLabel.frame = frame;
    frame = timeLabel.frame;
    frame.origin.x = self.bounds.size.width - 40 - frame.size.width;
    timeLabel.frame = frame;
}

@end
