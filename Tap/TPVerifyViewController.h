//
//  TPVerifyViewController.h
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TPVerifyViewController : UIViewController

@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UITextField *verifyField;
- (IBAction)verify:(id)sender;


@end
