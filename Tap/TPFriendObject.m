//
//  TPFriendObject.m
//  Tap
//
//  Created by Yagil Burowski on 7/27/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPFriendObject.h"

@implementation TPFriendObject


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        self.parseUserId = [decoder decodeObjectForKey:@"parseUserId"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.parseUserId forKey:@"parseUserId"];
    [coder encodeObject:self.username forKey:@"username"];
    [coder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
}


@end
