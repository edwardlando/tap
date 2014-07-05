//
//  TPPhoneNumberViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPPhoneNumberViewController.h"
#import <Parse/Parse.h>

@interface TPPhoneNumberViewController ()

@end

@implementation TPPhoneNumberViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)savePhone{
    NSLog(@"Saving phone");
    NSString *phone = [self.phoneField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    if ([phone length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter your phone number" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    }
    else {
        NSLog(@"Phone not length 0");
        [self.user setObject:phone forKey:@"phone"];
        NSLog(@"%@", self.user);
        
        NSLog(@"Saving user");
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                // Take me to the camera
                NSLog(@"About to be taken to camera");
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}



- (IBAction)continue:(id)sender {
    NSLog(@"Continue");
    [self savePhone];
}

@end
