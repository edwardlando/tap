//
//  TPViewCell.h
//  Tap
//
//  Created by Yagil Burowski on 7/7/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TPViewCell : UITableViewCell
@property (strong, nonatomic) PFUser *sendingUser;
@property (strong, nonatomic) NSArray *taps;

@end
