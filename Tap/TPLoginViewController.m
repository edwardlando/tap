//
//  TPLoginViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPLoginViewController.h"
#import "TPAppDelegate.h"

#import <Parse/Parse.h>


#import "TPPhoneNumberViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import <ImageIO/ImageIO.h>

@interface TPLoginViewController ()
@property (strong, nonatomic) TPAppDelegate *appDelegate;
- (IBAction)goBack:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,retain) CaptureSessionManager *captureManager;

@end

@implementation TPLoginViewController
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
-(TPAppDelegate *)appDelegate {
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.usernameField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCamera];
}
- (IBAction)login:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username and a password!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    }
    else {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                [self.appDelegate loadFriends];
                 [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}


@end
