//
//  TPTutorialViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/23/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPTutorialViewController.h"

@interface TPTutorialViewController ()

@end

@implementation TPTutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    pageControl.numberOfPages = 2;//set here pages which you want..
//    pageControl.currentPage = 0;
//    pageControl.autoresizingMask = UIViewAutoresizingNone;

//    [self.view addSubview:pageControl];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
