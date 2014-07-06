//
//  TPSingleTapViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/5/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPSingleTapViewController.h"
#import "TPCameraViewController.h"


@interface TPSingleTapViewController () {
    int taps;
}
@property (strong, nonatomic) IBOutlet UILabel *tapsLabel;

@end

@implementation TPSingleTapViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    UILabel *tapsLabel = (UILabel *)[self.view viewWithTag:10];
    tapsLabel.layer.cornerRadius = 5;
    
    taps = [@(self.objects.count) intValue];
    
    if (taps > 2) {
        tapsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]];
    }

    NSLog(@"self.objects.count %d", taps);
    if (taps == 0) {
        [self noMoreTaps];
    } else {
        [self setupTap];
        
        NSLog(@"objects %@", self.objects);
        [self showTap];
    }
}

-(void) showTap {
    self.tapsLabel.text = [NSString stringWithFormat:@"%d", taps];
    if (taps == 2) {
        UILabel *tapsLabel = (UILabel *)[self.view viewWithTag:10];
        tapsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    }
    if (taps - 1 < 0) {
        [self noMoreTaps];
        return;
    }
    
    PFObject *singleTap =[self.objects objectAtIndex:taps - 1];
//    PFFile *file = [singleTap objectForKey:@"img"];
    UIImage *singleTapImage = [self.allBatchImages objectAtIndex:taps - 1];

    [self markAsRead:singleTap];
    
//    self.imageView = [[PFImageView alloc] init];
    self.imageView.image = singleTapImage;
    
//    [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
//        if (!error) {
//            NSLog(@"Finished Loading Image");
//        } else {
//            NSLog(@"Error: %@", error);
//        }
//        
//    }];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"singleTapViewDismissed"
                                                        object:nil
                                                      userInfo:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void) markAsRead:(PFObject *)message {
    [[message objectForKey:@"read"] setObject:[NSNumber numberWithBool:YES] forKey:[[PFUser currentUser] objectId]] ;
    [[message objectForKey:@"readArray"] addObject:[[PFUser currentUser] objectId]];
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"marked as read");
        } else {
            NSLog(@"Error: %@", error);
        }

    }];
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
