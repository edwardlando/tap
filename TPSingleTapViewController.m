//
//  TPSingleTapViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/5/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPSingleTapViewController.h"
#import "TPCameraViewController.h"
#import "TPAppDelegate.h"

@interface TPSingleTapViewController () {
    int taps;
    int currentBatch;
    BOOL lastBatch;
    int numberOfTapsInBatch;
    int currentTap;
}

@property (strong, nonatomic) IBOutlet UILabel *tapsLabel;
@property (strong, nonatomic) NSMutableArray *tapsToSave;
@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *sortedKeysArray;

@end

@implementation TPSingleTapViewController

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
    self.tapsToSave = [[NSMutableArray alloc] init];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    UILabel *tapsLabel = (UILabel *)[self.view viewWithTag:10];
    tapsLabel.layer.cornerRadius = 5;

    self.sortedKeysArray = [[self.allInteractionTaps allKeys] sortedArrayUsingSelector:
                                @selector(localizedCaseInsensitiveCompare:)];
//    self.allBatchImages = [self allInteractionTapsToArray];

    currentTap = currentBatch = 0;
    numberOfTapsInBatch = (int)[[self.allInteractionTaps objectForKey:[self.sortedKeysArray objectAtIndex:0]] count];
    if ([self.sortedKeysArray count] == 1) {
        lastBatch = YES;
    }
    
    
    taps = [@(self.objects.count) intValue];
    
    if (taps > 2) {
        tapsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]];
    }

//    NSLog(@"self.objects.count %d", taps);
    if (taps == 0) {
        [self noMoreTaps];
    } else {
        [self setupTap];
        
//        NSLog(@"objects %@", self.objects);
        [self showTap];
    }
}

-(NSMutableArray *)allInteractionTapsToArray {
    NSMutableArray *allTaps = [[NSMutableArray alloc] init];
    NSArray *allBatchIds = [self.allInteractionTaps allKeys];
    
    NSLog(@"sortedKeysArray %@", self.sortedKeysArray);
    for (id key in self.sortedKeysArray) {
    NSSortDescriptor *imageIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageId" ascending:NO];
        NSArray *sortDescriptors = @[imageIdDescriptor];
        NSArray *sortedBatchPhotos = [[self.allInteractionTaps objectForKey:key] sortedArrayUsingDescriptors:sortDescriptors];
        [allTaps addObjectsFromArray:sortedBatchPhotos];
    }

    return allTaps;
}

-(void) showTap {
    self.tapsLabel.text = [NSString stringWithFormat:@"%d", taps];
    NSLog(@"Current Batch %d | numberOfTapsInBatch Length %d | currentTap %d | taps %d | last batch? %d", currentBatch, numberOfTapsInBatch, currentTap, taps, lastBatch);
    
    if (!lastBatch) {
        if (currentTap == numberOfTapsInBatch) {
            currentBatch++;
            NSString *batchId = [self.sortedKeysArray objectAtIndex:currentBatch];
            numberOfTapsInBatch = (int)[[self.allInteractionTaps objectForKey:batchId] count];
            currentTap = 0;
        }
    }
    
    if (currentBatch == [self.sortedKeysArray count] - 1) {
        if (!lastBatch) {
            lastBatch = YES;
            currentTap = 0;
        }

    }
    
    if (taps == 2) {
        UILabel *tapsLabel = (UILabel *)[self.view viewWithTag:10];
        tapsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    }
    if (taps - 1 < 0) {
        [self noMoreTaps];
        return;
    }
    
    PFObject *singleTap = [self.objects objectAtIndex:taps - 1];
    
    NSString *currentBatchId = [self.sortedKeysArray objectAtIndex:currentBatch];
    NSArray *batchImages = [self.allInteractionTaps objectForKey:currentBatchId];
    
    NSSortDescriptor *imageIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageId" ascending:NO];
    NSArray *sortDescriptors = @[imageIdDescriptor];
    NSArray *sortedBatchPhotos = [batchImages sortedArrayUsingDescriptors:sortDescriptors];

    PFObject *messageToShow = [sortedBatchPhotos objectAtIndex:currentTap];
    
    NSLog(@"Message to Show %@", messageToShow);
    
    
    UIImage *singleTapImage = [messageToShow objectForKey:@"image"];
                            
    
//    UIImage *singleTapImage = [[self.allBatchImages objectAtIndex:taps - 1] objectForKey:@"image"];
    
    [self markAsRead:singleTap];
    self.imageView.image = singleTapImage;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) setupTap {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    
}

-(void) tap:(UITapGestureRecognizer *)recognizer {

    

    
    if (taps >= 1) {
        taps--;
        currentTap++;
        [self showTap];
    } else {
        [self noMoreTaps];
    }

}

-(void)noMoreTaps {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    TPCameraViewController *camera = (TPCameraViewController*)[storyboard instantiateViewControllerWithIdentifier:@"camera"];
//    [self presentViewController:camera animated:NO completion:^{
//        //
//    }];
    [[self.spray objectForKey:@"read"] addObject:[PFUser currentUser]];
    [self.spray saveEventually];
    
    if ([self.tapsToSave count] > 0) {
        [PFObject saveAllInBackground:self.tapsToSave block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"just saved taps background like a boss");
            } else {
                NSLog(@"Error: %@", error);
            }

        }];
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = (currentInstallation.badge - 1 >= 0) ? currentInstallation.badge - 1 : 0;
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        NSLog(@"decremented installation badge to %ld", (long)currentInstallation.badge);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"singleTapViewDismissed"
                                                        object:nil
                                                      userInfo:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void) markAsRead:(PFObject *)message {
    [[message objectForKey:@"read"] setObject:[NSNumber numberWithBool:YES] forKey:[[PFUser currentUser] objectId]] ;
    [[message objectForKey:@"readArray"] addObject:[[PFUser currentUser] objectId]];
    [self.appDelegate.allReadTaps addObject:[message objectId]];
    NSLog(@"message read %@", [message objectId]);
    [self.tapsToSave addObject:message];

//    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"marked message as read");
//        } else {
//            NSLog(@"Error: %@", error);
//        }
//
//    }];

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
