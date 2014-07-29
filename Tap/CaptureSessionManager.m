#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
//        if (DEBUG) NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
//                if (DEBUG) NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
//                if (DEBUG) NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        self.frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            [[self captureSession]removeInput:self.backFacingCameraDeviceInput];
            if ([[self captureSession] canAddInput:self.frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:self.frontFacingCameraDeviceInput];
            } else {
                if (DEBUG) NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        self.backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            [[self captureSession]removeInput:self.frontFacingCameraDeviceInput];
            if ([[self captureSession] canAddInput:self.backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:self.backFacingCameraDeviceInput];
            } else {
                if (DEBUG) NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

- (void)addStillImageOutput 
{
  [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
  [[self stillImageOutput] setOutputSettings:outputSettings];
  
  AVCaptureConnection *videoConnection = nil;
  for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
    for (AVCaptureInputPort *port in [connection inputPorts]) {
      if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection) { 
      break; 
    }
  }
  
  [[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    
    @try {
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                             completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                                 CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                 [self setStillImage:image];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                             }];
    }
    @catch (NSException *exception) {
        
//        [self init];
        
        if (DEBUG) NSLog(@"Exception capturing screen %@", exception);
    }
}

@end
