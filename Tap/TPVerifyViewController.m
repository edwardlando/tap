//
//  TPVerifyViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPVerifyViewController.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "CaptureSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPVerifyViewController ()

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,retain) CaptureSessionManager *captureManager;
- (IBAction)goBack:(id)sender;

@end

@implementation TPVerifyViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCamera];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createUserBroadcast];
    [self.verifyField becomeFirstResponder];
}
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)verifyPhone
{
    NSString *code = [self.verifyField.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Verifying Code...";
    
    // Twilio
    [PFCloud callFunctionInBackground:@"verifyCode" withParameters:@{@"code": code} block:^(id object, NSError *error) {
        if(!error && ![object isEqual: @"false"]){
            [hud hide:YES];
            
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
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
