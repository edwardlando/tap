//
//  TPPhoneNumberViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPPhoneNumberViewController.h"
#import "TPVerifyViewController.h"
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
        
        if([phone characterAtIndex:0] != '1'){
            NSString *temp = @"1";
            phone = [temp stringByAppendingString:phone];
        }
        
        [self.user setObject:phone forKey:@"phone"];
        [self.user setObject:phone forKey:@"phoneNumber"];
        NSLog(@"%@", self.user);
        
        
        [PFCloud callFunctionInBackground:@"sendVerificationCode" withParameters:@{@"phoneNumber":phone} block:^(id object, NSError *error) {
            if (error) {
                NSLog(@"Error sending verification code");
            } else {
                [self performSegueWithIdentifier:@"showVerify" sender:self];
            }
            //
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showVerify"])
    {
        TPVerifyViewController *vc = (TPVerifyViewController *)[segue destinationViewController];
        NSLog(@"user %@", self.user);
        vc.user = self.user;
        NSLog(@"vc.user %@", vc.user);
        
        
    }
}



- (IBAction)continue:(id)sender {
    NSLog(@"Continue");
    [self savePhone];
}

@end
