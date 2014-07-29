//
//  TPSettingsViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/21/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPSettingsViewController.h"
#import <Parse/Parse.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TPAppDelegate.h"

@interface TPSettingsViewController () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phonenumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
- (IBAction)goBack:(id)sender;

@end

@implementation TPSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TPAppDelegate sendMixpanelEvent:@"Opened settings page"];
    
    [self initCredentialsRows];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationItem.rightBarButtonItem setTitle:@""];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 10) {
        [TPAppDelegate sendMixpanelEvent:@"Opened privacy policy"];
        NSURL *url = [NSURL URLWithString:@"http://www.gopopcast.com/privacy"];
        
        if (![[UIApplication sharedApplication] openURL:url]) {
            if (DEBUG) NSLog(@"%@%@",@"Failed to open url:",[url description]);
        }
        
        if (DEBUG) NSLog(@"This is privacy");
    } else if (cell.tag == 15) {
        [TPAppDelegate sendMixpanelEvent:@"Tapped send feedback"];
        
        [self sendFeedback];
    }else if (cell.tag == 11) {
            [TPAppDelegate sendMixpanelEvent:@"Logged out"];
        
        
        [PFUser logOut];
        
        
        if (DEBUG) NSLog(@"This is logout");
//        [self.navigationController popToRootViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userLoggedOut" object:nil];

        }];

    }
}


- (void)sendFeedback {
    // Email Subject
    NSString *emailTitle = @"Feedback on Popcast";
    // Email Content
    NSString *messageBody = @"Your feedback";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"founders@gopopcast.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

-(void)initCredentialsRows {
    self.usernameLabel.text = [[PFUser currentUser] objectForKey:@"username"];
    self.phonenumberLabel.text = [[PFUser currentUser] objectForKey:@"phoneNumber"];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            if (DEBUG) NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            if (DEBUG) NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
             if (DEBUG) NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            if (DEBUG) NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
//    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
