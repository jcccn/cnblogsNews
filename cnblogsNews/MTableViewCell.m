//
//  MTableViewCell.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 10/13/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "MTableViewCell.h"

@implementation MTableViewCell

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

@end
