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
    [self createUserBroadcast];
    // Do any additional setup after loading the view.
    
}

- (void)verifyPhone
{
    
    NSString *code = [self.verifyField.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Twilio
    [PFCloud callFunctionInBackground:@"verifyCode" withParameters:@{@"code": code} block:^(id object, NSError *error) {
        if(!error && ![object isEqual: @"false"]){
            //[self dismissViewControllerAnimated:YES completion:nil];
            
            [self performSegueWithIdentifier:@"showAsk" sender:self];
            
//            [self.navigationController popToRootViewControllerAnimated:YES];
                        //[PFCloud callFunctionInBackground:@"setupInstallation" withParameters:@{@"instId":Instid} target:nil selector:nil];
        }
        else{
            NSLog(@"Error from verif code %@", error);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Incorrect verification code." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Try again.", nil];
            [alert show];
        }
    }];
}

-(void)createUserBroadcast {
    PFObject *cast = [PFObject objectWithClassName:@"Broadcast"];
    cast[@"owner"] = [PFUser currentUser];
    cast[@"updated"] = [NSNumber numberWithBool:NO];
    cast[@"batchIds"] = [[NSMutableArray alloc] init];
    [cast saveInBackground];
}



- (IBAction)verify:(id)sender {
    [self verifyPhone];
}
@end
