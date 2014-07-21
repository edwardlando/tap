//
//  TPCameraViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPCameraViewController.h"

#import "TPProcessImage.h"
#import "TPAppDelegate.h"
#import "TPAllContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBook.h>

@interface TPCameraViewController (){
 
    BOOL takingPicture;
    int taps;
    BOOL frontCam;
    int messagesSaved;
    long batchId;
    BOOL interactionCreated;
    BOOL disappearOnSegue;
    BOOL shouldCreateInteraction;
}

@property (strong, nonatomic) IBOutlet UILabel *tapsCounter;
@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UILabel *sendingIndicator;
@property (strong, nonatomic) NSMutableArray *recipients;
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
    [self checkUserSituation];
    
    [self registerForNotifications];
    
//    messagesSaved = 0;
    if (![self.appDelegate.sending boolValue]) {
        NSLog(@"It's not sending");
        self.appDelegate.messagesSaved = @(0);
        self.appDelegate.taps = @(0);
    }
    
    
    NSLog(@"Camera did load");
    [self setupCameraScreen];
//    [self setupCameraScreen];
//    taps = 0;

//    self.tapsCounter.text = [NSString stringWithFormat:@"%d", taps];
    self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.appDelegate.taps intValue]];

    
    UIButton *inboxButton = (UIButton *)[self.view viewWithTag:10];
    inboxButton.layer.borderColor = [UIColor whiteColor].CGColor;
    inboxButton.layer.borderWidth = 2.0f;
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

//    currentInstallation.badge = 0;
    
    
    if (currentInstallation.badge != 0) {
        // turn button to red
        [self makeMainMenuPink];
    } else {
        [inboxButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black"]]];
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    NSString *directPhoneNumber = [self.directRecipient objectForKey:@"phoneNumber"];
    NSString *nameInContacts = [self.appDelegate.contactsDict objectForKey:directPhoneNumber];
    NSString *replyMsg = [NSString stringWithFormat:@"You are replying directly to %@", nameInContacts];
    if (self.isReply) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Direct Reply" message:replyMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"FUCK YEAH!", nil];
//        [alert show];
    }
    [self fetchPhoneContacts];

    inboxButton.layer.cornerRadius = 5;
    
    // Login



    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
//    taps = 0;
    if (![self.appDelegate.sending boolValue]) {
        NSLog(@"It's not sending");
        self.appDelegate.messagesSaved = @(0);
        self.appDelegate.taps = @(0);
        self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.appDelegate.taps intValue]];
    }

    self.recipients = [[NSMutableArray alloc] init];
    NSLog(@"View Will Appear");
    [self setupCameraScreen];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"View Will Disappear");
    if ([self.appDelegate.taps intValue] > 0) {
        [self createInteraction];
    }
    if (![self.appDelegate.sending boolValue]) {
        self.appDelegate.taps = @(0);
    }

    
}

-(void)checkUserSituation {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (![[PFUser currentUser] objectForKey:@"phoneVerified"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Please verify your phone number!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                [alertView show];
                [self performSegueWithIdentifier:@"showLanding" sender:self];
            }
        }];
        
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        NSLog(@"No user");
        disappearOnSegue = YES;
        [self performSegueWithIdentifier:@"showLanding" sender:self];
        
    }
}

-(void)setupCameraScreen {
    
    NSLog(@"Set up camera screen");
//    [self registerForNotifications];
    interactionCreated = NO;
//    taps = 0;
    if (![self.appDelegate.sending boolValue]) {
        self.appDelegate.taps = @(0);
        self.appDelegate.messagesSaved = @(0);
    }
    frontCam = NO;
    [self resetBatchId];
    [self setupTap];
    [self setupCamera];
    
    takingPicture = true;
}

-(void)resetBatchId {
    batchId = [[NSDate date] timeIntervalSince1970];
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

-(void) handleNoFriends {
    NSLog(@"No Group");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Friends" message:@"It seems that you have no friends, start by adding a couple!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
    [alertView show];
    [self performSegueWithIdentifier:@"showAllContacts" sender:self];
}

-(void)touch:(UITapGestureRecognizer *)recognizer
{
//    if ([self.appDelegate.friendsArray count] <= 0) {
//        NSLog(@"Handle no friends");
////        [self handleNoGroup];
//        [self handleNoFriends];
//        return;
//    }

    NSLog(@"Tap");

    [self takePicture];
    
    
//    taps++;

    NSLog(@"Incremented app del taps %d", [self.appDelegate.taps intValue]);
    
    if ([self.appDelegate.taps intValue] == 0) {
        [self createInteraction];
    }

}



-(void) makeMainMenuPink {
    NSLog(@"making menu pink");
    UIButton *inboxButton = (UIButton *)[self.view viewWithTag:10];
    [inboxButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]]];
}

-(void)takePicture{
    NSLog(@"Take Picture");
    [self.sendingIndicator setHidden:NO];
    [[self captureManager]captureStillImage];
}


-(void) registerForNotifications {
    
    [self unsubscribeFromNotifications];

    NSLog(@"Registered for notifications");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNeedsUpdateNotification:)
                                                 name:@"needsUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveImage)
                                                 name:kImageCapturedSuccessfully
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupCameraScreen)
                                                 name:@"onboardingFinished"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeMainMenuPink)
                                                 name:@"newTaps"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillDisappear:)
                                                 name:@"appEnteredBackground"
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(viewDidLoad)
//                                                 name:@"appEnteredForeground"
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSavedImageNotification:)
                                                 name:@"savedImageToServer"
                                               object:nil];
    
}

-(void) unsubscribeFromNotifications {
    NSLog(@"Unsubscribed from notifications");
    [[NSNotificationCenter defaultCenter] removeObserver:@"needsUpdate"];
    [[NSNotificationCenter defaultCenter] removeObserver:kImageCapturedSuccessfully];
    [[NSNotificationCenter defaultCenter] removeObserver:@"onboardingFinished"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"newTaps"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"appEnteredBackground"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"appEnteredForeground"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"savedImageToServer"];

}

-(void)handleSavedImageNotification:(NSNotification *)notification {
//    messagesSaved++;
    
    NSLog(@"handleSavedImageNotification called");
    
    self.appDelegate.messagesSaved = @([self.appDelegate.messagesSaved intValue] + 1);
    
    NSLog(@"handleSavedImageNotification, incremented messagesSaved %d", [self.appDelegate.messagesSaved intValue]);
    NSLog(@"num of messages saved %d / num if taps %d / object %@", [self.appDelegate.messagesSaved intValue], [self.appDelegate.taps intValue], notification.object);
    
    self.sendingIndicator.text = [NSString stringWithFormat:@"Sending...%d/%d",[self.appDelegate.messagesSaved intValue], [self.appDelegate.taps intValue]] ;
//    self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.tapsCounter.text intValue] - 1];
    
    if ([self.appDelegate.messagesSaved intValue] == [self.appDelegate.taps intValue]) {
        NSLog(@"That was the last one");
        self.appDelegate.sending = @(NO);
        
        // Need to reset metrics here?
        self.sendingIndicator.text = @"Sending...";
        NSLog(@"Object %@", /*[sender objectForKey:@"object"]*/ notification.object);
        [self.sendingIndicator setHidden:YES];
    }
}

-(void)createInteraction {
    
    if (!interactionCreated) {
        @try {
            interactionCreated = YES;
            NSLog(@"Creating / updating the Interaction object");
            NSString *batchIdString = [NSString stringWithFormat:@"%ld", batchId];
//            [TPProcessImage updateInteractions:self.recipients withBatchId:batchIdString];

            [TPProcessImage updateBroadcast:batchIdString];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception %@", exception);
        }

    }
}

-(void)swapCamera {
    frontCam = !frontCam;
    [captureManager addVideoInputFrontCamera:frontCam];
}


-(void)saveImage{
    NSLog(@"save image");
//    _imageView.image = [captureManager stillImage];
    _selectedImage = [captureManager stillImage];
//    NSLog(@"Selected Image %@", [captureManager stillImage]);

//    [[[self captureManager]captureSession]stopRunning];
    CGFloat newHeight = _selectedImage.size.height / 2.5f;
    CGFloat newWidth = _selectedImage.size.width / 2.5f;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContext(newSize);

    [_selectedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(newImage, 0.8);
    
//    UIImage *optimizedImage = [UIImage imageWithData:dataForJPEGFile];
    NSString *batchIdString = [NSString stringWithFormat:@"%ld", batchId];

    if (self.isReply) {
        [self.recipients addObject:self.directRecipient];
    } else {
        self.recipients = self.appDelegate.myGroup;
    }

//    NSLog(@"sending to %@", recipients);
//    [self.sendingIndicator startAnimating];
//    [self.sendingIndicator setHidden:NO];
    
    self.appDelegate.taps = @([self.appDelegate.taps intValue] + 1);
    self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.appDelegate.taps intValue]];
    self.appDelegate.sending = @(YES);
    [TPProcessImage sendTapTo:self.recipients andImage:dataForJPEGFile inBatch:batchIdString withImageId: [self.appDelegate.taps intValue] completed:^(BOOL success) {
        //        NSLog(@"HOly shit it saved?");
    }];
    
    
    

    
}

-(void) resetBatch {
//    taps = 0;
    if (![self.appDelegate.sending boolValue]) {
        self.appDelegate.taps = @(0);
    }
//    self.tapsCounter.text = [NSString stringWithFormat:@"%d", taps];
    self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.appDelegate.taps intValue]];
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
    if ([segue.identifier isEqual:@"showAllContacts"]) {
//        TPAllContactsViewController *allConView = (TPAllContactsViewController*)segue.destinationViewController;
//        allConView.contactsPhoneNumbersArray
    } else if ([segue.identifier isEqual:@"showLanding"]) {
        NSLog(@"PERFORMING SHOW LANDING SEGUE");
    }
}

-(void) fetchPhoneContacts {
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    
    if (!accessGranted) {
        //
    } else {
        
        NSArray *allPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        self.appDelegate.contactsPhoneNumbersArray = [[NSMutableArray alloc] initWithCapacity:[allPeople count]]; // capacity is only a rough guess, but better than nothing

        for (id record in allPeople) {
            CFTypeRef phoneProperty = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonPhoneProperty);
            NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
            CFRelease(phoneProperty);
            for (NSString *phone in phones) {
                NSString* compositeName = (__bridge NSString *)ABRecordCopyCompositeName((__bridge ABRecordRef)record);
                NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];

                if(compositeName == nil)
                {
                    continue;
                }
                if(phone == nil){
                    continue;
                }
                
                NSString *strippedPhone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];

                if (![self.appDelegate.contactsPhoneNumbersArray containsObject:phone]) {
                    
                    if ([strippedPhone isEqual:@""]) continue;
                    if([strippedPhone characterAtIndex:0] != '1'){
                        NSString *temp = @"1";
                        strippedPhone = [temp stringByAppendingString:strippedPhone];
                    }
                    
                    [self.appDelegate.contactsPhoneNumbersArray addObject:strippedPhone];
                }
                
                if (![self.appDelegate.contactsDict objectForKey:strippedPhone]) {
                    [self.appDelegate.contactsDict setObject:compositeName forKey:strippedPhone];
                }
            }
        }
        CFRelease(addressBook);
        allPeople = nil;
    }
}

-(void)handleNeedsUpdateNotification:(NSNotification *)notification {
    NSString *content = notification.object;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version!" message:content delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Update Now!", nil];
    [alert setTag:500];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Alert view delegate");
    if(alertView.tag == 500){
        if(buttonIndex == 1){
            NSString *appStoreLink = @"https://itunes.apple.com/us/app/notice-anonymous-campus/id829934488?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        }
    }
}


@end
