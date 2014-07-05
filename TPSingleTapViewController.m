//
//  TPSingleTapViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/5/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPSingleTapViewController.h"

//#import <SDWebImage/UIImageView+WebCache.h>

@interface TPSingleTapViewController ()

@end

@implementation TPSingleTapViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self setupTap];
    NSLog(@"objects %@", self.objects);
    
    PFFile *file = [[self.objects objectAtIndex:0] objectForKey:@"img"];

    //    self.imageView = [[PFImageView alloc] init];
    
    self.imageView.file = file;
    [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
        if (!error) {
            NSLog(@"Finished Loading Image");
        } else {
            NSLog(@"Error: %@", error);
        }

    }];
    
    
    
    
    
    
    // Do any additional setup after loading the view.
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
    [self dismissViewControllerAnimated:NO completion:nil];
}

//-(void) markAsRead:
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
