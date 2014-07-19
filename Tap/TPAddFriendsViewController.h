//
//  TPAddFriendsViewController.h
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TPAddFriendsViewController : PFQueryTableViewController
@property (strong, nonatomic) NSMutableArray *contactsPhoneNumbersArray;
@end
