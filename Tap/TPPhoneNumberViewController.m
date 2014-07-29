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
#import <AVFoundation/AVFoundation.h>
#import "CaptureSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <ImageIO/ImageIO.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPPhoneNumberViewController ()
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,retain) CaptureSessionManager *captureManager;

@end

@implementation TPPhoneNumberViewController

-(void)setupCamera{
    if(TARGET_IPHONE_SIMULATOR){
        return;
    }
    
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
	[[self captureManager] addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camer
    [[self captureManager] addStillImageOutput];
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self cameraView] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self cameraView] layer] addSublayer:[[self captureManager] previewLayer]];
    
    [[[self captureManager]captureSession]startRunning];
    
    //    UIButton *mainMenu = (UIButton *)[self.view viewWithTag:10];
    //    mainMenu.layer.cornerRadius = 5;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (DEBUG) NSLog(@"Phone Number View Did Load");
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    self.phoneField.leftView = paddingView;

    self.phoneField.leftViewMode = UITextFieldViewModeAlways;


    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.phoneField.leftView = paddingView;
    
    
    self.phoneField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.phoneField becomeFirstResponder];
    [self setupCamera];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)savePhone{
    if (DEBUG) NSLog(@"Saving phone");
    NSString *phone = [self.phoneField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    if ([phone length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter your phone number" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    }
    else {
        if (DEBUG) NSLog(@"Phone not length 0");
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Verifying...";
        
//        if ([phone characterAtIndex:0] == '+' && [phone characterAtIndex:1] == '1') {
//            phone = [phone stringByReplacingOccurrencesOfString:@"+1" withString:@"1"];
//            phone = [phone stringByReplacingOccurrencesOfString:@"+1 " withString:@"1"];
//        }
        if([phone characterAtIndex:0] != '1'){
            NSString *temp = @"1";
            phone = [temp stringByAppendingString:phone];
        }
        
        

        
        if (DEBUG) NSLog(@"this is the user %@", self.user);
        
        
        [PFCloud callFunctionInBackground:@"sendVerificationCode" withParameters:@{@"phoneNumber":phone} block:^(id object, NSError *error) {
            [hud hide:YES];
            if (error) {
                if (DEBUG) NSLog(@"Error sending verification code %@", error);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again. Make sure your internet connection is strong and that you didn't sign up with this number before." delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                    [alertView show];

                
                // phone number taken
                
                
            } else {
                [self.user setObject:phone forKey:@"phone"];
                [self.user setObject:phone forKey:@"phoneNumber"];
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
        if (DEBUG) NSLog(@"user %@", self.user);
        vc.user = self.user;
        if (DEBUG) NSLog(@"vc.user %@", vc.user);
        
        
    }
}



- (IBAction)continue:(id)sender {
    if (DEBUG) NSLog(@"Continue");
    [self savePhone];
}

@end
