//
//  TPVerifyViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPVerifyViewController.h"

@interface TPVerifyViewController ()

@end

@implementation TPVerifyViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)verifyPhone
{
    
    NSString *code = [self.verifyField.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Twilio
    [PFCloud callFunctionInBackground:@"sendSms" withParameters:@{@"code": code} block:^(id object, NSError *error) {
        if(!error && ![object  isEqual: @"false"]){
            
            // Finally save this user
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
            //[PFCloud callFunctionInBackground:@"setupInstallation" withParameters:@{@"instId":Instid} target:nil selector:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Incorrect verification code." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Try again.", nil];
            [alert show];
        }
    }];
}



- (IBAction)verify:(id)sender {
    [self verifyPhone];
}
@end
