//
//  TPTutorialContentViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/23/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPTutorialContentViewController.h"

@interface TPTutorialContentViewController ()
@property (strong, nonatomic) IBOutlet UILabel *screenLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)dismiss:(id)sender;

@end

@implementation TPTutorialContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageNamed:self.imageFile];
    self.screenLabel.text = self.titleText;
    
    
    
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

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
