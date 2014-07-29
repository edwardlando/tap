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
#import "TPCaptionLabel.h"

@interface TPCameraViewController () {
 
    BOOL takingPicture;
    int taps;
    BOOL frontCam;
    int messagesSaved;
    long batchId;
    NSString *firstCaption;
    BOOL interactionCreated;
    BOOL disappearOnSegue;
    BOOL shouldCreateInteraction;
    BOOL tutIsOn;
    int tutStep;
    BOOL duringAnimation;
}

@property (strong, nonatomic) IBOutlet UILabel *tapsCounter;
@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UILabel *sendingIndicator;
@property (strong, nonatomic) NSMutableArray *recipients;
@property (strong, nonatomic) NSArray *tutorialSteps;
@property (strong, nonatomic) IBOutlet UIImageView *tutImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *sendingActivityIndicator;
@property (strong, nonatomic) NSString *picCaption;
@property (strong, nonatomic) IBOutlet TPCaptionLabel *captionLabel;
@property (strong, nonatomic) UIImage *lastImageTaken;
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

-(NSArray *)tutorialSteps {
    if (!_tutorialSteps) {
        _tutorialSteps = @[@"tut1", @"tut2", @"tut2", @"tut2", @"tut3", @"tut4"];
    }
    return _tutorialSteps;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkUserSituation];
    if (DEBUG) NSLog(@"Checking user situation");
    [self initCaptionLabel];
    [self displayTutorial];
}

-(void)initCaptionLabel {
    if (DEBUG) NSLog(@"Init caption label");
    self.captionLabel.layer.cornerRadius = 5;
    self.captionLabel.adjustsFontSizeToFitWidth = YES;
    
    //    [self.captionLabel sizeToFit];
//    self.captionLabel.clipsToBounds = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self checkUserSituation];
    [self registerForNotifications];
    
//    messagesSaved = 0;
    if (![self.appDelegate.sending boolValue]) {
        if (DEBUG) NSLog(@"It's not sending");
        self.appDelegate.messagesSaved = @(0);
        self.appDelegate.taps = @(0);
    }
    
    
    if (DEBUG) NSLog(@"Camera did load");
    [self setupCameraScreen];
//    [self setupCameraScreen];
//    taps = 0;
    self.tapsCounter.layer.cornerRadius = 5;
    self.tapsCounter.layer.borderWidth = 2.0f;
    [self initCounterStyle];


    
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
//        [inboxButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]]];
//        [inboxButton setBackgroundColor:[UIColor clearColor]];

        [inboxButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:1.0]];
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    NSString *directPhoneNumber = [self.directRecipient objectForKey:@"phoneNumber"];
    NSString *nameInContacts = [self.appDelegate.contactsDict objectForKey:directPhoneNumber];
    
    NSString *replyMsg = [NSString stringWithFormat:@"You are replying directly to %@", nameInContacts];
    
    if (self.isReply) {

    }


    inboxButton.layer.cornerRadius = 5;
    
    // Login



    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self initCaptionLabelAndButton];
    [TPAppDelegate sendMixpanelEvent:@"Opened camera"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
//    taps = 0;
    if (![self.appDelegate.sending boolValue]) {
        if (DEBUG) NSLog(@"It's not sending");
        self.appDelegate.messagesSaved = @(0);
        self.appDelegate.taps = @(0);
        self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.appDelegate.taps intValue]];
    }

    self.recipients = [[NSMutableArray alloc] init];
    if (DEBUG) NSLog(@"View Will Appear");
    [self setupCameraScreen];
    [self setupTap];
    
}

-(void)displayTutorial {
    if (DEBUG) NSLog(@"Display Tut");
    UIButton *captionButton = (UIButton *)[self.view viewWithTag:524];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {

        [captionButton setHidden:YES];
        [self initTutorial];
    } else {
        if (DEBUG) NSLog(@"Already seen tut");
        [captionButton setHidden:NO];
    }
}

-(void)initTutorial {
    tutIsOn = YES;
    tutStep = 0;
    [self.tutImageView setHidden:NO];
    NSString *nextImageName = [self.tutorialSteps objectAtIndex:tutStep];
    UIImage *image = [UIImage imageNamed:nextImageName];
    self.tutImageView.image = image;
}

-(void)tutNextStep {
    if (DEBUG) NSLog(@"Tut next step");
    tutStep++;
    if (tutStep == [self.tutorialSteps count] - 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    } else if (tutStep == [self.tutorialSteps count]) {
        [self shouldFinishTutorial];
        return;
    }
    
    @try {

        NSString *nextImageName = [self.tutorialSteps objectAtIndex:tutStep];
        UIImage *image = [UIImage imageNamed:nextImageName];
        self.tutImageView.image = image;

    }
    @catch (NSException *exception) {
        if (DEBUG) NSLog(@"Tut error %@", exception);
        [self shouldFinishTutorial];
    }

}

-(void)shouldFinishTutorial {
    [self.tutImageView setHidden:YES];
    [self didFinishTutorial];
}

-(void)didFinishTutorial {
    if (DEBUG) NSLog(@"Finished tutorial");
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (DEBUG) NSLog(@"View Will Disappear");
    [self.tutImageView setHidden:YES];
//    if ([self.appDelegate.taps intValue] > 0) {
//        [self createInteraction];
//    }
    if (![self.appDelegate.sending boolValue]) {
        self.appDelegate.taps = @(0);
    }
}

-(void)checkUserSituation {
    PFUser *currentUser = [PFUser currentUser];

    if (currentUser && currentUser.isAuthenticated) {
//        [currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        
        
        [self fetchPhoneContacts];

    
        [currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (DEBUG) NSLog(@"Refreshed user");
            if (![[object objectForKey:@"phoneVerified"] boolValue]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone number verification" message:@"Please verify your phone number!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                [alertView show];
                [self performSegueWithIdentifier:@"verifyPhone" sender:self];
            }
        }];
        
        if (DEBUG) NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        if (DEBUG) NSLog(@"No user %@", currentUser);
        [self performSegueWithIdentifier:@"showLanding" sender:self];
        
//        if (![[currentUser objectForKey:@"phoneVerified"] boolValue]) {
//            [self performSegueWithIdentifier:@"verifyPhone" sender:self];
//        } else {
            [PFUser logOut];

//        }

        disappearOnSegue = YES;

        
    }

}

-(void)setupCameraScreen {
    
    if (DEBUG) NSLog(@"Set up camera screen");
//    [self registerForNotifications];
    interactionCreated = NO;
//    taps = 0;
    if (![self.appDelegate.sending boolValue]) {
        self.appDelegate.taps = @(0);
        self.appDelegate.messagesSaved = @(0);
    }
    frontCam = NO;
    [self resetBatchId];
    [self resetFirstCaption];
    [self setupCamera];
    
    takingPicture = true;
}

-(void)resetBatchId {
    batchId = [[NSDate date] timeIntervalSince1970];
}

-(void)resetFirstCaption {
    firstCaption = nil;
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
    
    UISwipeGestureRecognizer *upSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(addCaption)];
    [upSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    
    [self.view addGestureRecognizer:upSwipeRecognizer];
    upSwipeRecognizer.delegate = self;
    
}

-(void)addCaption {
    if (DEBUG) NSLog(@"Add caption");
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Add Caption"
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Save", nil];
    
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtF = [message textFieldAtIndex:0];
    txtF.placeholder = @"Type caption here...";
    txtF.text = self.captionLabel.text;
//    [txtF setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    [txtF setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [txtF setClearButtonMode:UITextFieldViewModeAlways];
    [message setTag:100];
    [message show];
}

-(void) handleNoFriends {
    if (DEBUG) NSLog(@"No Group");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Friends" message:@"It seems that you have no friends, start by adding a couple!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
    [alertView show];
    [self performSegueWithIdentifier:@"showAllContacts" sender:self];
}

-(void)touch:(UITapGestureRecognizer *)recognizer
{
//    if ([self.appDelegate.friendsArray count] <= 0) {
//        if (DEBUG) NSLog(@"Handle no friends");
////        [self handleNoGroup];
//        [self handleNoFriends];
//        return;
//    }

    if (DEBUG) NSLog(@"Tap");

    if ([self.appDelegate.taps intValue] >= 50) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Slow Down!" message:@"Hold it right there, young grasshopper. You cannot send more than 50 Pops a cast. Or casts a pop. Either way, slow down! 👋" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
        UIButton *captionButton = (UIButton *)[self.view viewWithTag:524];
        [captionButton setHidden:YES];
        return;
    }
    
    
    
    if ([self.appDelegate.isBlocked boolValue]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"It seems that you are blocked from sending Popcasts. If you believe this is a mistake, please contact us." delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [self takePicture];
    
    if (tutIsOn && tutStep != 4) {
        if (DEBUG) NSLog(@"Tut is on so next step %d out of %ld", tutStep, [self.tutorialSteps count]);
        [self tutNextStep];
    }

    
//    taps++;

    if (DEBUG) NSLog(@"Incremented app del taps %d", [self.appDelegate.taps intValue]);
//    [self sendingCounterStyle];
}



-(void) makeMainMenuPink {
    if (DEBUG) NSLog(@"making menu pink");
    UIButton *inboxButton = (UIButton *)[self.view viewWithTag:10];
    [inboxButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]]];
}


-(void)takePicture{
    if (DEBUG) NSLog(@"Take Picture");
    [self.sendingIndicator setHidden:NO];
    [self.sendingActivityIndicator setHidden:NO];
    [self.sendingActivityIndicator startAnimating];
//    [[self.view viewWithTag:929] setHidden:NO];
    [[self captureManager]captureStillImage];
}


-(void) registerForNotifications {
    
    [self unsubscribeFromNotifications];

    if (DEBUG) NSLog(@"Registered for notifications");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNeedsUpdateNotification:)
                                                 name:@"needsUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveImage)
                                                 name:kImageCapturedSuccessfully
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOnboardingFinished)
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupCameraScreen)
                                                 name:@"appEnteredForeground"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSavedImageNotification:)
                                                 name:@"savedImageToServer"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkUserSituation)
                                                 name:@"userLoggedOut"
                                               object:nil];
    
}

-(void) unsubscribeFromNotifications {
    if (DEBUG) NSLog(@"Unsubscribed from notifications");
    [[NSNotificationCenter defaultCenter] removeObserver:@"needsUpdate"];
    [[NSNotificationCenter defaultCenter] removeObserver:kImageCapturedSuccessfully];
    [[NSNotificationCenter defaultCenter] removeObserver:@"onboardingFinished"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"newTaps"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"userLoggedOut"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"appEnteredBackground"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"appEnteredForeground"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"savedImageToServer"];

}

-(void)handleOnboardingFinished {
    [self setupCameraScreen];
    [self initTutorial];
    
}

-(void)handleSavedImageNotification:(NSNotification *)notification {
//    messagesSaved++;
    if (DEBUG) NSLog(@"handleSavedImageNotification called");


    
    self.appDelegate.messagesSaved = @([self.appDelegate.messagesSaved intValue] + 1);
    
    if (DEBUG) NSLog(@"handleSavedImageNotification, incremented messagesSaved %d", [self.appDelegate.messagesSaved intValue]);
    if (DEBUG) NSLog(@"num of messages saved %d / num if taps %d / object %@", [self.appDelegate.messagesSaved intValue], [self.appDelegate.taps intValue], notification.object);
    self.sendingIndicator.text = [NSString stringWithFormat:@"Sending...%d/%d",[self.appDelegate.messagesSaved intValue], [self.appDelegate.taps intValue]] ;

    
    
    if ([self.appDelegate.messagesSaved intValue] == [self.appDelegate.taps intValue]) {
        if (DEBUG) NSLog(@"That was the last one");
        self.appDelegate.sending = @(NO);
        [self animateCounterHide];
        // Need to reset metrics here?
        self.sendingIndicator.text = @"Sending...";

        
        if (DEBUG) NSLog(@"Object %@", /*[sender objectForKey:@"object"]*/ notification.object);
        [self.sendingIndicator setHidden:YES];
        [self.sendingActivityIndicator setHidden:YES];
        [self.sendingActivityIndicator stopAnimating];
        
        [[self.view viewWithTag:929] setHidden:YES];
    }
}

-(void)initCounterStyle {
    if (DEBUG) NSLog(@"Counter init");
    [self.tapsCounter setAlpha:0.0];
    [self.tapsCounter setHidden:YES];
    /// make bg of inboxButton button right here
    self.imageView.layer.cornerRadius = 5;
    [self.imageView setHidden:NO];
    UIButton *inboxButton = (UIButton *)[self.view viewWithTag:10];
//    [inboxButton setBackgroundColor:[UIColor colorWithPatternImage:self.lastImageTaken]];
    
    self.imageView.image = self.lastImageTaken;
    
//    inboxButton.contentMode = UIViewContentModeScaleAspectFill;
//    self.tapsCounter.font = [UIFont fontWithName:@"HelveticaNeue-Bold"  size:102.0f];
//    [self.tapsCounter setHidden:YES];
//    self.tapsCounter.layer.borderColor = [UIColor clearColor].CGColor;
//    self.tapsCounter.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//    self.tapsCounter.backgroundColor = [UIColor clearColor];
//    self.tapsCounter.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.tapsCounter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
}

-(void)sendingCounterStyle {
    
//    [self.tapsCounter setHidden:NO];
    

//    self.tapsCounter.textColor  =[[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]] colorWithAlphaComponent:1.0f];
//    self.tapsCounter.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"purpleColor"]].CGColor;
//    
//    self.tapsCounter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"purpleColor"]];
}

-(void)createInteraction {
    if (DEBUG) NSLog(@"createInteraction called");
    if (!interactionCreated) {
        @try {
            interactionCreated = YES;
            if (DEBUG) NSLog(@"Creating / updating the Interaction object");
            NSString *batchIdString = [NSString stringWithFormat:@"%ld", batchId];
//            [TPProcessImage updateInteractions:self.recipients withBatchId:batchIdString];

            if (DEBUG) NSLog(@"This is the first caption %@", firstCaption);
            
            [TPProcessImage updateBroadcast:batchIdString withFirstCaption:firstCaption];
        }
        @catch (NSException *exception) {
            if (DEBUG) NSLog(@"Exception %@", exception);
        }

    }
}

-(void)swapCamera {
    if (tutIsOn && tutStep == 4) {
        if (DEBUG) NSLog(@"Tut is on so next step %d out of %ld", tutStep, [self.tutorialSteps count]);
        [self tutNextStep];
    }

    
    frontCam = !frontCam;
    [captureManager addVideoInputFrontCamera:frontCam];
}


-(void)saveImage{
    if (DEBUG) NSLog(@"save image");

    
//    _imageView.image = [captureManager stillImage];
    _selectedImage = [captureManager stillImage];
//    if (DEBUG) NSLog(@"Selected Image %@", [captureManager stillImage]);

//    [[[self captureManager]captureSession]stopRunning];
    CGFloat newHeight = _selectedImage.size.height / 2.5f;
    CGFloat newWidth = _selectedImage.size.width / 2.5f;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContext(newSize);

    [_selectedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    self.lastImageTaken = newImage;
    UIGraphicsEndImageContext();
    
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(newImage, 0.8);
    
    


//    UIImage *optimizedImage = [UIImage imageWithData:dataForJPEGFile];
    NSString *batchIdString = [NSString stringWithFormat:@"%ld", batchId];

    if (self.isReply) {
        [self.recipients addObject:self.directRecipient];
    } else {
        self.recipients = [[NSMutableArray alloc] init];//self.appDelegate.myGroup;
    }

//    if (DEBUG) NSLog(@"sending to %@", recipients);
//    [self.sendingIndicator startAnimating];
//    [self.sendingIndicator setHidden:NO];
    
    

    

    self.appDelegate.sending = @(YES);
    
    NSString *caption = nil;
    if ([[[self.captionLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""] length] != 0) {
        caption = self.captionLabel.text;
        if (DEBUG) NSLog(@"There is caption and it is %@", caption);
        
        if (firstCaption != nil) {
            if (DEBUG) NSLog(@"There's already a first caption");
        } else {
            if (DEBUG) NSLog(@"There's no caption and therefore we put this %@", caption);
            firstCaption = caption;
        }
    }
    
    if ([self.appDelegate.taps intValue] == 0) {
        // paste here
        [self createInteraction];
    }

    self.appDelegate.taps = @([self.appDelegate.taps intValue] + 1);
    [self sendingCounterStyle];
    
    [self animateCounterShow];
    
    self.tapsCounter.text = [NSString stringWithFormat:@"%d", [self.appDelegate.taps intValue]];
    
    [TPProcessImage sendTapTo:self.recipients andImage:dataForJPEGFile inBatch:batchIdString withImageId: [self.appDelegate.taps intValue] withCaption:caption completed:^(BOOL success) {
        //        if (DEBUG) NSLog(@"HOly shit it saved?");
    }];
    
    
}

-(void)animateCounterShow {
    if (DEBUG) NSLog(@"Counter show");
    
    [self initCounterStyle];
//    [self.view.layer removeAllAnimations];
    duringAnimation = YES;
//    [UIView beginAnimations: @"anim" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: 0.1f];
    [self.tapsCounter setAlpha:1.0];

//    self.tapsCounter.font = [UIFont fontWithName:@"HelveticaNeue-Bold"  size:200.0f];
    [self.tapsCounter setHidden:NO];
//    [UIView commitAnimations];
    
//    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2);
//    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
//        [self animateCounterHide];
//    });

    
}

-(void)animateCounterHide {
    if (DEBUG) NSLog(@"Counter hide");
//    [UIView beginAnimations: @"anim2" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: 0.3f];
    [self.tapsCounter setAlpha:0.0];
    [self.imageView setHidden:YES];
    //    self.tapsCounter.font = [UIFont fontWithName:@"HelveticaNeue-Bold"  size:200.0f];
    [self.tapsCounter setHidden:YES];
//    [UIView commitAnimations];
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
    if (DEBUG) NSLog(@"segue performed");
    [self resetBatch];
    [self resetFirstCaption];
    if ([segue.identifier isEqual:@"showAllContacts"]) {
//        TPAllContactsViewController *allConView = (TPAllContactsViewController*)segue.destinationViewController;
//        allConView.contactsPhoneNumbersArray
    } else if ([segue.identifier isEqual:@"showLanding"]) {
        if (DEBUG) NSLog(@"PERFORMING SHOW LANDING SEGUE");
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
                
                id contactRecord = @{@"name": compositeName, @"number": strippedPhone};
                
                if (![self.appDelegate.alphabeticalPhonebook containsObject:contact])
                    [self.appDelegate.alphabeticalPhonebook addObject:contactRecord];
                
            }
        }
        CFRelease(addressBook);
        allPeople = nil;
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        //        for (NSString *key in [self.alphabeticalPhonebook allKeys]) {
        [self.appDelegate.alphabeticalPhonebook sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        
    }
}

-(void)handleNeedsUpdateNotification:(NSNotification *)notification {
    NSString *content = notification.object;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version!" message:content delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Update Now!", nil];
    [alert setTag:500];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (DEBUG) NSLog(@"Alert view delegate");
    if(alertView.tag == 500){
        if(buttonIndex == 1){
            NSString *appStoreLink = @"http://gopopcast.com/update";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        }
    } else if (alertView.tag == 100) {
        if(buttonIndex == 1){
            UITextField *caption = [alertView textFieldAtIndex:0];
            self.captionLabel.text = caption.text;
            [self.captionLabel setHidden:NO];
//            [self.captionLabel sizeToFit];
//            self.captionLabel.clipsToBounds = YES;
            UIButton *captionButton = (UIButton *)[self.view viewWithTag:524];
            if ([[[caption.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""] length] == 0) {
//                [self.captionLabel setHidden:YES];§
                [self.captionLabel setHidden:YES];
                [captionButton setTitle:@"👆Swipe up to add caption" forState:UIControlStateNormal];
                captionButton.userInteractionEnabled = NO;
            } else {
                captionButton.userInteractionEnabled = YES;
                [captionButton setTitle:@"" forState:UIControlStateNormal];
            }
        }
    }
}

-(void)initCaptionLabelAndButton {
    UIButton *captionButton = (UIButton *)[self.view viewWithTag:524];
    [captionButton setTitle:@"👆Swipe up to add caption" forState:UIControlStateNormal];
    self.captionLabel.text = @"";
    [self.captionLabel setHidden:YES];
//    [self.captionLabel sizeToFit];
    
//    self.captionLabel.clipsToBounds = YES;
}

- (IBAction)addCaptionBtn:(id)sender {
    [self addCaption];
}
@end
