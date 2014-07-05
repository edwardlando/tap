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


+(void)sendTapTo:(NSMutableArray *)recipients andImage:(UIImage *)image inBatch:(NSString *)batchId completed:(void (^)(BOOL success))completed{

    if(image){
        NSLog(@"trying to save");
        PFFile *file = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(image)];
        PFObject *msg = [PFObject objectWithClassName:@"Message"];
        msg[@"img"] = file;
        msg[@"sender"] = [PFUser currentUser];
        recipients = [@[[PFUser currentUser]] mutableCopy];
        msg[@"recipients"] = recipients;
        msg[@"read"] = [[NSMutableDictionary alloc] init];
        msg[@"batchId"] = batchId;
        
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



@end
