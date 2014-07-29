//
//  TPSignUpViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPSignUpViewController.h"
#import "TPPhoneNumberViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <ImageIO/ImageIO.h>

#import <MBProgressHUD/MBProgressHUD.h>

@interface TPSignUpViewController ()
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,retain) CaptureSessionManager *captureManager;
- (IBAction)back:(id)sender;

@end

@implementation TPSignUpViewController
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
    if (DEBUG) NSLog(@"Signup view did load");
    [self setupCamera];
    self.passwordField.secureTextEntry = YES;
    
//    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.passwordField.leftView = paddingView;
    self.usernameField.leftView = paddingView2;
    
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.usernameField becomeFirstResponder];
    
    
    if ([PFUser currentUser]) {
        if (DEBUG) NSLog(@"User existing %@", [PFUser currentUser]);
        self.user = [PFUser currentUser];
        [self performSegueWithIdentifier:@"showPhone" sender:self];
    }
    // self.user = [PFUser user];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (DEBUG) NSLog(@"Sign Up View will appear");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)signup {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Choose Username" message:@"Make sure you enter a username" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    } else if ([username length] < 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username Length" message:@"Username must be more than 3 characters" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    }
    else if ([password length] < 6) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Length" message:@"Password must be more than 6 characters" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //    hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Signing Up...";

        if (DEBUG) NSLog(@"password and username not empty %@ %@", username, password);
        // Do I need to initialize the PFUser?
        self.user.username = username;
        self.user.password = password;
        
        [self.user setObject:[[NSMutableArray alloc] init] forKey:@"friendRequestsArray"];
        [self.user setObject:[[NSMutableArray alloc] init] forKey:@"friendsArray"];
        [self.user setObject:[[NSMutableArray alloc] init] forKey:@"friendRequestsSent"];
//        [self.user setObject:[[NSMutableArray alloc] init] forKey:@"myGroupArray"];
        [self.user setObject:[[NSMutableArray alloc] init] forKey:@"friendsPhones"];
        [self.user setObject:[[NSMutableDictionary alloc] init] forKey:@"contactsDict"];

        [self.user setObject:@(NO) forKey:@"blocked"];
        
        // Finally save this user
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [hud hide:YES];
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                self.user = nil;
                
                [alertView show];
            }
            else {
                if (DEBUG) NSLog(@"Showing phone input screen");
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
        if (DEBUG) NSLog(@"PERFORMED SEGUE SHOW PHONE");
        TPPhoneNumberViewController *vc = (TPPhoneNumberViewController *)[segue destinationViewController];
        if (DEBUG) NSLog(@"user %@", self.user);
        vc.user = self.user;
        if (DEBUG) NSLog(@"vc.user %@", vc.user);
    }
}

- (IBAction)continueToPhone:(id)sender {
    [self signup];
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
