//
//  TPCameraViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPCameraViewController.h"
#import "TPProcessImage.h"

@interface TPCameraViewController (){
 
    BOOL takingPicture;
    int taps;
    BOOL frontCam;
}

@property (strong, nonatomic) IBOutlet UILabel *tapsCounter;

@end

@implementation TPCameraViewController
@synthesize captureManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    taps = 0;
    frontCam = NO;
    [self setupCamera];
    takingPicture = true;
    [self setupTap];
    
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
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapCamera)];
    [swipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRecognizer];
    swipeRecognizer.delegate = self;
}

-(void)touch:(UITapGestureRecognizer *)recognizer
{
    if(takingPicture){
        [self takePicture];
        taps++;
        self.tapsCounter.text = [NSString stringWithFormat:@"%d", taps];
    }
    [self resignFirstResponder];
}

-(void)takePicture{
    NSLog(@"Take Picture");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImage) name:kImageCapturedSuccessfully object:nil];
    [[self captureManager]captureStillImage];
//    takingPicture = false;
}

-(void)swapCamera {
    frontCam = !frontCam;
    [captureManager addVideoInputFrontCamera:frontCam];
}


-(void)saveImage{
//    _imageView.image = [captureManager stillImage];
    _selectedImage = [captureManager stillImage];
//    [[[self captureManager]captureSession]stopRunning];
    CGFloat newHeight = _selectedImage.size.height / 3.0f;
    CGFloat newWidth = _selectedImage.size.width / 3.0f;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContext(newSize);
    [_selectedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [TPProcessImage addPost:@"" andImage:newImage completed:^(BOOL success) {
        NSLog(@"HOly shit it saved?");
    }];
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

@end
