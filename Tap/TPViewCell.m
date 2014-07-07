//
//  TPViewCell.m
//  Tap
//
//  Created by Yagil Burowski on 7/7/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPViewCell.h"

@implementation TPViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
