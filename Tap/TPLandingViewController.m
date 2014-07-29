//
//  TPLandingViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPLandingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <ImageIO/ImageIO.h>

@interface TPLandingViewController ()
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,retain) CaptureSessionManager *captureManager;
@property (strong, nonatomic) IBOutlet UIButton *mainMenu;

@end

@implementation TPLandingViewController

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.mainMenu.layer.cornerRadius = 5;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCamera];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
