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


+(void)addPost:(NSString *)text andImage:(UIImage *)image completed:(void (^)(BOOL success))completed{

    if(image){
        PFFile *file = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(image)];
        PFObject *msg = [PFObject objectWithClassName:@"Message"];
        msg[@"img"] = file;
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
