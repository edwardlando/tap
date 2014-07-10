//
//  TPProcessImage.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPProcessImage.h"


#import <Parse/Parse.h>


@implementation TPProcessImage


//+(void)sendTapTo:(NSMutableArray *)recipients andImage:(NSData *)imageData inBatch:(NSString *)batchId withImageId: (int) taps completed:(void (^)(BOOL success))completed{
//
//    if(imageData){
//        NSLog(@"trying to save");
//        PFFile *file = [PFFile fileWithName:@"image.png" data:imageData];
//        PFObject *msg = [PFObject objectWithClassName:@"Message"];
//        msg[@"img"] = file;
//        msg[@"sender"] = [PFUser currentUser];
////        [recipients addObject:[PFUser currentUser]];
//        msg[@"recipients"] = recipients;
//        msg[@"read"] = [[NSMutableDictionary alloc] init];
//        msg[@"readArray"] = [[NSMutableArray alloc] init];
//        msg[@"batchId"] = batchId;
//        msg[@"imageId"] = @(taps);
//        for (id recipient in recipients) {
//            [msg[@"read"] setObject:[NSNumber numberWithBool:NO] forKey:[recipient objectId]];
//        }
////        [msg saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
////
////        }];
//        [msg saveEventually:^(BOOL succeeded, NSError *error) {
//            if(succeeded){
//                NSLog(@"Succeded");
//            } else {
//                NSLog(@"Error: %@", error);
//            }
//        }];
//    }
//    else{
//
//    }
//}

+(void)sendTapTo:(NSMutableArray *)recipients andImage:(NSData *)imageData inBatch:(NSString *)batchId withImageId: (int) taps completed:(void (^)(BOOL success))completed{
        NSLog(@"trying to save");
    if(imageData){

        NSLog(@"Yes Image Data");
        PFFile *file = [PFFile fileWithName:@"image.png" data:imageData];
        
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Saved file in background");
            PFObject *msg = [PFObject objectWithClassName:@"Message"];
            msg[@"img"] = file;
            msg[@"sender"] = [PFUser currentUser];
            //        [recipients addObject:[PFUser currentUser]];
            msg[@"recipients"] = recipients;
            msg[@"read"] = [[NSMutableDictionary alloc] init];
            msg[@"readArray"] = [[NSMutableArray alloc] init];
            msg[@"batchId"] = batchId;
            msg[@"imageId"] = @(taps);
            msg[@"senderPhoneNumber"] = [[PFUser currentUser] objectForKey:@"phoneNumber"];
            for (id recipient in recipients) {
                [msg[@"read"] setObject:[NSNumber numberWithBool:NO] forKey:[recipient objectId]];
            }
            [msg saveEventually:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    NSLog(@"Succeded");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"savedImageToServer" object:@(taps)];

                } else {
                    NSLog(@"Error: %@", error);
                }
            }];

        }];
    }
    else{
        NSLog(@"No Image Data");
    }
}


+ (void) createSprayTo:(NSMutableArray *)recipients withBatchId: (NSString *) batchId withNumOfTaps: (NSUInteger) numOfTaps withDirect: (BOOL) isDirect {
    PFObject *spray = [PFObject objectWithClassName:@"Spray"];
    spray[@"sender"] = [PFUser currentUser];
    spray[@"recipients"] = recipients;
    [recipients addObject:[PFUser currentUser]];
    spray[@"batchId"] = batchId;
    spray[@"numOfTaps"] = @(numOfTaps);
    spray[@"read"] = [[NSMutableArray alloc] init];
    if (isDirect) {
        spray[@"direct"] = [NSNumber numberWithBool:YES];
    }
    
    NSMutableArray *recipientsObjectIds = [[NSMutableArray alloc] init];
    for (PFUser *recipient in recipients) {
        [recipientsObjectIds addObject:[recipient objectId]];
    }
    [spray saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Saved spray");
//            sendSprayPushNotifications
            [PFCloud callFunctionInBackground:@"sendSprayPushNotifications" withParameters:@{@"recipients":recipientsObjectIds} block:^(id object, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                } else {
                    
                }
            }];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

+ (void) updateInteractions:(NSMutableArray *)recipients withBatchId:(NSString *)batchId {
    NSLog(@"Update interaction");
    PFQuery *interactionQuery = [[PFQuery alloc] initWithClassName:@"Interaction"];
    [interactionQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [interactionQuery whereKey:@"recipient" containedIn:recipients];
    [interactionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Found %ld Interactions", [objects count]);
        NSMutableArray *allRecipients = [[NSMutableArray alloc] init];
        NSMutableArray *allInteractions = [[NSMutableArray alloc] init];
        for (PFObject *interaction in objects) {
            [allInteractions addObject:interaction];
            [interaction[@"batchIds"] addObject:batchId];
            [allRecipients addObject:[[interaction objectForKey:@"recipient"] objectId]];
            
        }
        
        for (PFUser *recipient in recipients) {
            if (![allRecipients containsObject:[recipient objectId]]) {
                NSLog(@"%@ is not contained in %@", [recipient objectId], allRecipients);
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
                NSLog(@"updated all interactions");
                NSMutableArray *recipientsObjectIds = [[NSMutableArray alloc] init];
                for (PFUser *recipient in recipients) {
                    [recipientsObjectIds addObject:[recipient objectId]];
                }
                if(succeeded){
                    NSLog(@"saved interactions and sendSprayPushNotifications");
                    [PFCloud callFunctionInBackground:@"sendSprayPushNotifications" withParameters:@{@"recipients":recipientsObjectIds} block:^(id object, NSError *error) {
                        if (error) {
                            NSLog(@"Error: %@", error);
                        } else {
                            
                        }
                    }];
                } else {
                    NSLog(@"Error: %@", error);
                }
            }
        }];
        
    }];
}
@end
