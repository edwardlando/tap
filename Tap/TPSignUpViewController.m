//
//  TPSignUpViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPSignUpViewController.h"
#import "TPPhoneNumberViewController.h"
#import <Parse/Parse.h>

@interface TPSignUpViewController ()

@end

@implementation TPSignUpViewController

- (PFUser *)user
{
    if (!_user) {
        _user = [PFUser user];
    }
    
    return _user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordField.secureTextEntry = YES;
    // self.user = [PFUser user];
    // Do any additional setup after loading the view.
}

- (void)signup {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username and a password!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    }
    else {
        NSLog(@"password and username not empty");
        // Do I need to initialize the PFUser?
        self.user.username = username;
        self.user.password = password;
        
        
        // Finally save this user
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                NSLog(@"Showing phone input screen");
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                [currentInstallation saveInBackground];
                
                [self performSegueWithIdentifier:@"showPhone" sender:self];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showPhone"])
    {
        TPPhoneNumberViewController *vc = (TPPhoneNumberViewController *)[segue destinationViewController];
        NSLog(@"user %@", self.user);
        vc.user = self.user;
        NSLog(@"vc.user %@", vc.user);
    }
}

- (IBAction)continueToPhone:(id)sender {
    [self signup];
    
}
@end
