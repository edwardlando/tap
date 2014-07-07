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


+(void)sendTapTo:(NSMutableArray *)recipients andImage:(NSData *)imageData inBatch:(NSString *)batchId withImageId: (int) taps completed:(void (^)(BOOL success))completed{

    if(imageData){
        NSLog(@"trying to save");
        PFFile *file = [PFFile fileWithName:@"image.png" data:imageData];
        PFObject *msg = [PFObject objectWithClassName:@"Message"];
        msg[@"img"] = file;
        msg[@"sender"] = [PFUser currentUser];
//        [recipients addObject:[PFUser currentUser]];
        msg[@"recipients"] = recipients;
        msg[@"read"] = [[NSMutableDictionary alloc] init];
        msg[@"readArray"] = [[NSMutableArray alloc] init];
        msg[@"batchId"] = batchId;
        msg[@"imageId"] = @(taps);
        for (id recipient in recipients) {
            [msg[@"read"] setObject:[NSNumber numberWithBool:NO] forKey:[recipient objectId]];
        }
        
        [msg saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                NSLog(@"Succeded");

            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
    else{

    }
}


+ (void) createSprayTo:(NSMutableArray *)recipients withBatchId: (NSString *) batchId withNumOfTaps: (NSUInteger) numOfTaps {
    PFObject *spray = [PFObject objectWithClassName:@"Spray"];
    spray[@"sender"] = [PFUser currentUser];
    spray[@"recipients"] = recipients;
    [recipients addObject:[PFUser currentUser]];    
    spray[@"batchId"] = batchId;
    spray[@"numOfTaps"] = @(numOfTaps);
    spray[@"read"] = [[NSMutableArray alloc] init];
    
    [spray saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Saved spray");
            
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

@end
