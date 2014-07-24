//
//  TPMyGroupViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPMyGroupViewController.h"
#import "TPAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "TPFriendRequestsViewController.h"

@interface TPMyGroupViewController () {
    BOOL pendingFriendReqs;
}

@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *friendsArray;
- (IBAction)backToCamera:(id)sender;

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

    if ([self.appDelegate.friendsArray count] == 0) {
        NSLog(@"No friends in app delegate");
    }
    [self.appDelegate loadFriends];
    if ([self.appDelegate.pendingFriendRequests intValue] > 0) {
        pendingFriendReqs = YES;
    } else {
        pendingFriendReqs = NO;
    }
    [self alertIfNoFriends];
    
    

    for (PFUser *friendInGroup in [[PFUser currentUser] objectForKey:@"myGroupArray"]) {
        [friendInGroup fetchIfNeeded];
    }

    for (PFUser *friend in [[PFUser currentUser] objectForKey:@"friendsArray"]) {
        [friend fetchIfNeeded];
    }
    
    [self setupNavBarStyle];
    [self setNavbarIcon];
}

-(void) setNavbarIcon {
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                       NSForegroundColorAttributeName: [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]],
                                                                       NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:23.0f],
                                                                       NSShadowAttributeName: shadow
                                                                       }];
}

-(void) setupNavBarStyle {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"lightGray"];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"white"] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"View Will Appear");
    
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"Refreshing user");
        [self.tableView reloadData];
    }];
}

-(void)alertIfNoFriends {
    NSInteger totalFriends = [self.appDelegate.friendsPhoneNumbersArray count];
    
    if (totalFriends == 0) {
        NSLog(@"No one in group");
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Have No Friends" message:@"Start by adding or inviting some cool people" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"FUCK YEAH!", nil];
//        [alert show];
    }

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
//    if (pendingFriendReqs) {
//        return 3;
//    } else {
//
//    }
//    
//    return 3;
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 30.0f;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //    if (section == 0) {
    view.tintColor = [UIColor whiteColor];
    //    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    //    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

//    NSInteger totalFriends = [[[PFUser currentUser] objectForKey:@"friendsArray"] count];
    NSInteger totalFriends = [self.appDelegate.friendsPhoneNumbersArray count];
    NSInteger inMyGroup = [[[PFUser currentUser] objectForKey:@"myGroupArray"] count];

    // Return the number of rows in the section.
    if (section == 0) {
        if (pendingFriendReqs) return 1;
        
        return 0;
    } else if (section == 1) {
        
        return inMyGroup;
    } else {
//        NSLog(@"section 2: %d", totalFriends - inMyGroup );
        return [self.appDelegate.friendsArray count];
    }

}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequests" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Friends Requests (%d)", [self.appDelegate.pendingFriendRequests intValue]];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendInGroupCell" forIndexPath:indexPath];
        PFUser *friendInGroup = [self.appDelegate.myGroup objectAtIndex:indexPath.row];
      
        NSLog(@"friend in group %@", [friendInGroup objectForKey:@"username"]);
        
        NSString *friendPhoneNumber = [friendInGroup objectForKey:@"phoneNumber"];
        NSString *friendUsername = [friendInGroup objectForKey:@"username"];
        NSString *friendName = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
        cell.textLabel.text = friendName;
        cell.detailTextLabel.text = friendUsername;
        UIButton *removeFromGroupButton = (UIButton *)[cell viewWithTag:11];
        [removeFromGroupButton setHidden:NO];
        removeFromGroupButton.layer.cornerRadius = 5;

        
//        [removeFromGroupButton.layer setBorderColor:[UIColor blueColor].CGColor];
//        [removeFromGroupButton.layer setBorderWidth:2.0f];
        
        [removeFromGroupButton addTarget:self action:@selector(removeFromGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
//        PFUser *friend = self.appDelegate.
        
        PFUser *friend = [self.appDelegate.friendsArray objectAtIndex:indexPath.row];
        if ([self.appDelegate.myGroup containsObject:friend]) {
//            return nil;
            NSLog(@"This guy is in group %@", friend);
        }
        NSString *friendPhoneNumber = [friend objectForKey:@"phoneNumber"];
        NSLog(@"Friend %@", friend);
        NSLog(@"Phone Number %@", friendPhoneNumber);
        NSString *friendName = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
        NSLog(@"Friend name %@", friendName);
//        NSString *friendName =
//        PFUser *friend = [[[PFUser currentUser] objectForKey:@"friendArray"] objectAtIndex:indexPath.row];
//        [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            NSLog(@"friends %@", object);
        
//            NSString *friendPhoneNumber = [object objectForKey:@"phoneNumber"];
//            NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
//
        UIButton *addToGroupButton = (UIButton *)[cell viewWithTag:10];
        [addToGroupButton setHidden:NO];
        //        [addToGroupButton setBackgroundImage: forState:UIControlStateNormal];
        [addToGroupButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]] ];
        
        addToGroupButton.layer.cornerRadius = 5;
        
//        [addToGroupButton.layer setBorderColor:[UIColor purpleColor].CGColor];
//        [addToGroupButton.layer setBorderWidth:2.0f];

        [addToGroupButton addTarget:self action:@selector(addToGroup:) forControlEvents:UIControlEventTouchUpInside];


        
            if (![friendName isEqual:@""]) {
                cell.textLabel.text = friendName;
                cell.detailTextLabel.text = [self.appDelegate.numbersToUsernamesDict objectForKey:friendPhoneNumber];
            }
//            else {
//                cell.textLabel.text = [object objectForKey:@"username"];
//                cell.detailTextLabel.text = [object objectForKey:@"username"];
//            }
//        }];
        return cell;
    }

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"FRIEND REQUESTS";
    }
//    else if (section == 1){
//        return @"MY GROUP";
//    }
    else{
        return @"FRIENDS";
    }
}



-(void) addToGroup:(id) sender {
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:9];
    [senderButton setHidden:YES];
    [ind startAnimating];
    [ind setHidden:NO];
    
    PFUser *friendToAdd = [self.appDelegate.friendsObjectsDict objectForKey:[self.appDelegate.friendsPhoneNumbersArray objectAtIndex:indexPath.row]];
    [[[PFUser currentUser] objectForKey:@"myGroupArray"] addObject:friendToAdd];
    [self.appDelegate.myGroup addObject:friendToAdd];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Added to group");
        [ind stopAnimating];
        [ind setHidden:YES];
        [self.tableView reloadData];
    }];
}

-(void) removeFromGroup:(id) sender {
    NSLog(@"Remove from group method");
    UIView *senderButton = (UIView*) sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:9];
    
    [senderButton setHidden:YES];
    [ind startAnimating];
    [ind setHidden:NO];

    PFUser *friendToRemove = [self.appDelegate.myGroup objectAtIndex:indexPath.row];
//     = [self.appDelegate.friendsObjectsDict objectForKey:[];
    
    [[[PFUser currentUser] objectForKey:@"myGroupArray"] removeObject:friendToRemove];
//    if ([self.appDelegate.myGroup containsObject:friendToRemove]) {
        [self.appDelegate.myGroup removeObject:friendToRemove];
//    }

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Removed from group");

        [ind stopAnimating];
        [ind setHidden:YES];
        
        [self.tableView reloadData];
        
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSLog(@"Going to friend requests");
        [self goToFriendRequests];
    }
}


-(void)goToFriendRequests {

    [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self performSegueWithIdentifier:@"showFriendRequests" sender:object];
    }];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFriendRequests"]) {
        TPFriendRequestsViewController *vc = (TPFriendRequestsViewController *)segue.destinationViewController;
        vc.user = sender;
        NSLog(@"this is sender %@", sender);
    }
}

//- (PFQuery *)queryForTable {
//    
//    if (![PFUser currentUser]) {
//        return nil;
//    }
//    
//    PFQuery *query = [PFUser query];
//    //    [query includeKey:@"phoneNumber"];
//    
//    //    [query setLimit:0];
//    
//    [query whereKey:@"phoneNumber" containedIn:self.appDelegate.contactsPhoneNumbersArray];
//    [query whereKey:@"phoneNumber" notContainedIn:self.appDelegate.friendsPhoneNumbersArray];
//    
//    //    [query orderByDescending:@"createdAt"];
//    
//    return query;
//    
//}

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

- (IBAction)backToCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
