//
//  TPMyGroupViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPMyGroupViewController.h"
#import "TPAppDelegate.h"
#import <Parse/Parse.h>

@interface TPMyGroupViewController ()

@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *friendsArray;

@end

@implementation TPMyGroupViewController

- (TPAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (PFUser *requester in [[PFUser currentUser] objectForKey:@"friendRequestsArray"]) {
        [requester fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            //
        }];
    }
    /*self.friendsArray =*/
    ;
    
//    for (PFUser *friend in [[PFUser currentUser] objectForKey:@"friendArray"]) {
//        [friend fetchIfNeeded];
//    }
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    if ([[[PFUser currentUser] objectForKey:@"friendRequestsArray"] count] > 0) {
        return 3;
    }
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

//    NSInteger totalFriends = [[[PFUser currentUser] objectForKey:@"friendsArray"] count];
    NSInteger totalFriends = [self.appDelegate.friendsPhoneNumbersArray count];
    NSInteger inMyGrounp = [[[PFUser currentUser] objectForKey:@"myGroup"] count];
    
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return inMyGrounp;
    } else {
        return totalFriends - inMyGrounp;
    }

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequests" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Friends Requests (%ld)", [[[PFUser currentUser] objectForKey:@"friendRequestsArray"] count]];
        
        
        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendInGroupCell" forIndexPath:indexPath];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
//        NSString *friendPhoneNumber = ;
//        NSString *friendName =
//        PFUser *friend = [[[PFUser currentUser] objectForKey:@"friendArray"] objectAtIndex:indexPath.row];
//        [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            NSLog(@"friends %@", object);
        
//            NSString *friendPhoneNumber = [object objectForKey:@"phoneNumber"];
//            NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
//            
//            if ([friendNameInMyContacts isEqual:@""]) {
//                cell.textLabel.text = [object objectForKey:@"username"];
//    //            cell.detailTextLabel.text = friendPhoneNumber;
//            } else {
//                cell.textLabel.text = friendNameInMyContacts;
//                cell.detailTextLabel.text = [object objectForKey:@"username"];
//            }
//        }];
        return cell;
    }

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Friend Requests";
    }
    else if (section == 1){
        return @"My Group";
    }
    else{
        return @"All Friends";
    }
}


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

@end
