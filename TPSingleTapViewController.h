//
//  TPSingleTapViewController.h
//  Tap
//
//  Created by Yagil Burowski on 7/5/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TPSingleTapViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSMutableArray *allBatchImages;
@property (strong, nonatomic) PFObject *spray;
@property (strong, nonatomic) NSArray *allFlipCasts;
@property (strong, nonatomic) IBOutlet PFImageView *imageView;
@property (strong, nonatomic) NSMutableDictionary *allInteractionTaps;
@property (strong, nonatomic) NSNumber *isMyFlipcast;
@property (strong, nonatomic) PFUser *sendingUser;
@property (strong, nonatomic) NSIndexPath *indexPath;
@end
