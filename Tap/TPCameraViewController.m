//
//  TPCameraViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPCameraViewController.h"
#import <Parse/Parse.h>
#import "TPProcessImage.h"
#import "TPAppDelegate.h"

@interface TPCameraViewController (){
 
    BOOL takingPicture;
    int taps;
    BOOL frontCam;
    long batchId;
}

@property (strong, nonatomic) IBOutlet UILabel *tapsCounter;
@property (strong, nonatomic) TPAppDelegate *appDelegate;

@end

@implementation TPCameraViewController
@synthesize captureManager;

- (TPAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    UIButton *inboxButton = (UIButton *)[self.view viewWithTag:10];
    inboxButton.layer.cornerRadius = 5;
    
    // Login
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        NSLog(@"Segue time!!!!");
        [self performSegueWithIdentifier:@"showLanding" sender:self];
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self resetBatchId];
    taps = 0;

    frontCam = NO;
    [self setupCamera];
    takingPicture = true;
    [self setupTap];
    
}

-(void)resetBatchId {
    batchId = [[NSDate date] timeIntervalSince1970];
}

-(void)viewDidDisappear:(BOOL)animated {
    taps = 0;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touch:)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapCamera)];
    [rightSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];

    [self.view addGestureRecognizer:rightSwipeRecognizer];
    rightSwipeRecognizer.delegate = self;
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapCamera)];
    [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    leftSwipeRecognizer.delegate = self;
    
}

-(void)touch:(UITapGestureRecognizer *)recognizer
{
//    if(takingPicture){
        [self takePicture];
//    NSLog(@"tap");
        taps++;
        self.tapsCounter.text = [NSString stringWithFormat:@"%d", taps];
//    }
//    [self resignFirstResponder];
}

-(void)takePicture{
    NSLog(@"Take Picture");
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImage) name:kImageCapturedSuccessfully object:nil];

    [[self captureManager]captureStillImage];
    [self saveImage];
//    takingPicture = false;
}

-(void)swapCamera {
    frontCam = !frontCam;
    [captureManager addVideoInputFrontCamera:frontCam];
}

-(void)saveImage{
    NSLog(@"save image");
//    _imageView.image = [captureManager stillImage];
    _selectedImage = [captureManager stillImage];
//    [[[self captureManager]captureSession]stopRunning];
    CGFloat newHeight = _selectedImage.size.height / 3.0f;
    CGFloat newWidth = _selectedImage.size.width / 3.0f;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContext(newSize);

    [[captureManager stillImage] drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(newImage, 0.6);
//    UIImage *optimizedImage = [UIImage imageWithData:dataForJPEGFile];
    NSString *batchIdString = [NSString stringWithFormat:@"%ld", batchId];
    if (taps == 0) {
        [TPProcessImage createSprayTo:self.appDelegate.myGroup withBatchId:batchIdString withNumOfTaps:0];
    }
    
    [TPProcessImage sendTapTo:self.appDelegate.myGroup andImage:dataForJPEGFile inBatch:batchIdString withImageId: taps completed:^(BOOL success) {
        NSLog(@"HOly shit it saved?");
    }];
    
}

-(void) resetBatch {
    taps = 0;
    self.tapsCounter.text = [NSString stringWithFormat:@"%d", taps];
    [self resetBatchId];
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
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"segue performed");
    [self resetBatch];
}

@end
