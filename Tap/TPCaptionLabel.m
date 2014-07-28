//
//  TPCaptionLabel.m
//  Tap
//
//  Created by Yagil Burowski on 7/27/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPCaptionLabel.h"

@implementation TPCaptionLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 5, 5, 5};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
