//
//  TPCameraViewController.h
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CaptureSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
//#import <GPUImage/GPUImage.h>
#import <Parse/Parse.h>
#import <ImageIO/ImageIO.h>

@interface TPCameraViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,retain) CaptureSessionManager *captureManager;
@property (nonatomic,retain) UIImage *selectedImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSNumber *isReply;
@property (strong, nonatomic) PFUser *directRecipient;

@end
