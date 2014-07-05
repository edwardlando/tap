//
//  TPCameraViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPCameraViewController.h"

@interface TPCameraViewController (){
 
    BOOL takingPicture;
    BOOL frontCam;
}

@end

@implementation TPCameraViewController
@synthesize captureManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    frontCam = NO;
    [self setupCamera];
    takingPicture = true;
    [self setupTap];
}

-(void)setupTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touch:)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
}

-(void)touch:(UITapGestureRecognizer *)recognizer
{
    if(takingPicture){
        [self takePicture];
    }
    [self resignFirstResponder];
}

-(void)takePicture{
    NSLog(@"Take Picture");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImage) name:kImageCapturedSuccessfully object:nil];
    [[self captureManager]captureStillImage];
    takingPicture = false;
}


-(void)swapCamera {
    frontCam = !frontCam;
    [captureManager addVideoInputFrontCamera:frontCam];
}


-(void)saveImage{
    _imageView.image = [captureManager stillImage];
    _selectedImage = [captureManager stillImage];
    [[[self captureManager]captureSession]stopRunning];
    [self.cameraView setHidden:YES];
}


-(void)setupCamera{
    if(TARGET_IPHONE_SIMULATOR){
        return;
    }
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!input) {
        NSLog(@"Couldn't create video capture device");
    }
    [session addInput:input];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        UIView *view = self.cameraView;
        CALayer *viewLayer = [view layer];
        
        CGRect bounds=view.layer.bounds;
        newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        newCaptureVideoPreviewLayer.bounds=bounds;
        newCaptureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        
        [viewLayer addSublayer:newCaptureVideoPreviewLayer];
        
        self.cameraView = (UIView *)newCaptureVideoPreviewLayer;
        
        [session startRunning];
    });
}

@end
