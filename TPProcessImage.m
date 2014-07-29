//
//  TPProcessImage.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPProcessImage.h"


#import <Parse/Parse.h>
#import "TPAppDelegate.h"

@implementation TPProcessImage


+(void)sendTapTo:(NSMutableArray *)recipients andImage:(NSData *)imageData inBatch:(NSString *)batchId withImageId: (int) taps withCaption:(NSString *)caption completed:(void (^)(BOOL success))completed{
        if (DEBUG) NSLog(@"trying to save");
    if (![PFUser currentUser].isAuthenticated) {
        if (DEBUG) NSLog(@"User not auth");
        return;
    }
    if(imageData){

        if (DEBUG) NSLog(@"Yes Image Data");
        PFFile *file = [PFFile fileWithName:@"image.png" data:imageData];
        
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (DEBUG) NSLog(@"Saved file in background");
            if (DEBUG) NSLog(@"Recipients %@", recipients);
            if (DEBUG) NSLog(@"batchId %@", batchId);
            if (DEBUG) NSLog(@"imageId %d", taps);
//            if (DEBUG) NSLog(@"Sender phone number %@", [[PFUser currentUser] objectForKey:@"phoneNumber"]);
            
            
            PFObject *msg = [PFObject objectWithClassName:@"Message"];
            msg[@"img"] = file;
            msg[@"sender"] = [PFUser currentUser];
            msg[@"senderId"] = [[PFUser currentUser] objectId];
            //        [recipients addObject:[PFUser currentUser]];
            msg[@"recipients"] = recipients;
            
            if (caption) {
                if (DEBUG) NSLog(@"There is caption in TPProcess image");
                msg[@"caption"] = caption;
            } else {
                if (DEBUG) NSLog(@"There is no caption %@", caption);
            }
            
            msg[@"read"] = [[NSMutableDictionary alloc] init];
            msg[@"readArray"] = [[NSMutableArray alloc] init];
            msg[@"batchId"] = batchId;
            msg[@"privacy"] = @"public";
            msg[@"imageId"] = @(taps);
            msg[@"senderPhoneNumber"] = [[PFUser currentUser] objectForKey:@"phoneNumber"];
            for (id recipient in recipients) {
                [msg[@"read"] setObject:[NSNumber numberWithBool:NO] forKey:[recipient objectId]];
            }
            [msg saveEventually:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    if (DEBUG) NSLog(@"Succeded");
                    if (DEBUG) NSLog(@"Sending in app notification: savedImageToServer");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"savedImageToServer" object:@(taps)];
                } else {
                    if (DEBUG) NSLog(@"Error: %@", error);
                }
            }];

        }];
    }
    else{
        if (DEBUG) NSLog(@"No Image Data");
    }
}


+(void)updateBroadcast:(NSString *)batchId withFirstCaption:(NSString *) caption {
    
    if (DEBUG) NSLog(@"updateBroadcast with batchId %@ and caption %@", batchId, caption);
    
    PFObject *flipcast = [PFObject objectWithClassName:@"Flipcast"];
    flipcast[@"owner"] = [PFUser currentUser];
    flipcast[@"batchId"] = batchId;
    flipcast[@"privacy"] = @"public";
    flipcast[@"read"] = [[NSMutableArray alloc] init];
    
    if (caption != nil) {
        if (DEBUG) NSLog(@"Caption is not nil, there fore save it as firstCaption %@", caption);
        flipcast[@"firstCaption"] = caption;
    }
    
    [flipcast saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (DEBUG) NSLog(@"Created Flipcasts");
    }];
    
    PFQuery *channelQuery = [PFQuery queryWithClassName:@"Broadcast"];
    [channelQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
    [channelQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if (!object) {
                if (DEBUG) NSLog(@"no broadcast found");
                [self createUserBroadcast:batchId withCaption:caption];
                return;
            } else {
                if (DEBUG) NSLog(@"Found broadcast");
                if ([object objectForKey:@"batchIds"]) {
                    if (DEBUG) NSLog(@"Already had batchIds array");
                    [[object objectForKey:@"batchIds"] addObject:batchId];

                } else {
                    if (DEBUG) NSLog(@"Didn't have batchIds array");
                    [object setObject:@[batchId] forKey:@"batchIds"];
                }
                
                if (caption != nil) {
                    if (DEBUG) NSLog(@"Caption is not nil, there fore save it %@", caption);
//                    object[@"latestStatus"] = caption;
                    [object setObject:caption forKey:@"latestStatus"];
                }
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        if (DEBUG) NSLog(@"Broadcast updated with batchId %@", batchId);
                        [TPAppDelegate sendMixpanelEvent:@"Took and sent a Popcast"];
                    } else {
                        if (DEBUG) NSLog(@"sdf %@", error);
                    }
                }];
            }
        } else {
            if (DEBUG) NSLog(@"Error in update broadcast: %@", error);
        }
    }];
}

+(void)createUserBroadcast:(NSString *)batchId withCaption:(NSString *)caption {
    if ([[[PFUser currentUser] objectForKey:@"broadcastCreated"] boolValue]) return;
    
    PFObject *cast = [PFObject objectWithClassName:@"Broadcast"];
    cast[@"owner"] = [PFUser currentUser];
    cast[@"updated"] = [NSNumber numberWithBool:NO];
    if (batchId) {
        cast[@"batchIds"] = @[batchId];
        
    }
    if (caption != nil) {
        if (DEBUG) NSLog(@"Creating user broadcast, caption is not nil and it is %@", caption);
        cast[@"latestStatus"] = caption;
    }
    
    [cast saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (DEBUG) NSLog(@"created user broadcast");
            [[PFUser currentUser] setObject:@(YES) forKey:@"broadcastCreated"];
            [[PFUser currentUser] saveInBackground];
        } else {
            if (DEBUG) NSLog(@"create user broadcast error: %@", error);
        }
    }];
}

+(void)updateInteractions:(NSMutableArray *)recipients withBatchId:(NSString *)batchId {
    if (DEBUG) NSLog(@"Update interaction");
    PFQuery *interactionQuery = [[PFQuery alloc] initWithClassName:@"Interaction"];
    [interactionQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [interactionQuery whereKey:@"recipient" containedIn:recipients];
    [interactionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (DEBUG) NSLog(@"Found %ld Interactions", (unsigned long)[objects count]);
        NSMutableArray *allRecipients = [[NSMutableArray alloc] init];
        NSMutableArray *allInteractions = [[NSMutableArray alloc] init];
        for (PFObject *interaction in objects) {
            [interaction[@"batchIds"] addObject:batchId];
            [allInteractions addObject:interaction];
            [allRecipients addObject:[[interaction objectForKey:@"recipient"] objectId]];
            
        }
        
        for (PFUser *recipient in recipients) {
            if (![allRecipients containsObject:[recipient objectId]]) {
                if (DEBUG) NSLog(@"%@ is not contained in %@", [recipient objectId], allRecipients);
                PFObject *interaction = [PFObject objectWithClassName:@"Interaction"];
                interaction[@"sender"] = [PFUser currentUser];
                interaction[@"recipient"] = recipient;
                interaction[@"batchIds"] = [[NSMutableArray alloc] init];
                [interaction[@"batchIds"] addObject:batchId];
                [allInteractions addObject:interaction];
            }
        }
        
        [PFObject saveAllInBackground:allInteractions block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if (DEBUG) NSLog(@"updated all interactions");
                NSMutableArray *recipientsObjectIds = [[NSMutableArray alloc] init];
                for (PFUser *recipient in recipients) {
                    [recipientsObjectIds addObject:[recipient objectId]];
                }
                if(succeeded){
                    if (DEBUG) NSLog(@"saved interactions and sendSprayPushNotifications");
                    [PFCloud callFunctionInBackground:@"sendSprayPushNotifications" withParameters:@{@"recipients":recipientsObjectIds} block:^(id object, NSError *error) {
                        if (error) {
                            if (DEBUG) NSLog(@"Error: %@", error);
                        } else {
                            
                        }
                    }];
                } else {
                    if (DEBUG) NSLog(@"Error: %@", error);
                }
            }
        }];
        
    }];
}
@end
