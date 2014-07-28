//
//  TPFriend.h
//  Tap
//
//  Created by Yagil Burowski on 7/27/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface TPFriend : NSManagedObject

@property (nonatomic, retain) NSString * parseUserId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * phoneNumber;


//@dynamic parseUserId;
//@dynamic username;
//@dynamic phoneNumber;

@end
