//
//  TPAppDelegate.h
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *myGroup;
@property (strong, nonatomic) NSMutableArray *contactsPhoneNumbersArray;

@property (strong, nonatomic) NSMutableArray *friendsPhoneNumbersArray;
@property (strong, nonatomic) NSMutableArray *friendRequestsSent;
@property (strong, nonatomic) NSMutableArray *friendsArray;

@property (strong, nonatomic) NSNumber *pendingFriendRequests;

@property (strong, nonatomic) NSMutableDictionary *contactsDict;
@property (strong, nonatomic) NSMutableDictionary *numbersToUsernamesDict;
@property (strong, nonatomic) NSMutableDictionary *friendsObjectsDict;
@property (strong, nonatomic) NSMutableArray *allReadTaps;
@property (strong, nonatomic) NSNumber *taps;
@property (strong, nonatomic) NSNumber *messagesSaved;
@property (strong, nonatomic) NSNumber *sending;


-(void)loadFriends;
@end
