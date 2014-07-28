///
//  TPAllContactsViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPAddFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBook.h>
#import "TPAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface TPAddFriendsViewController () <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate> {
    BOOL pendingFriendReqs;
}

- (IBAction)backButton:(id)sender;
- (IBAction)refreshPage:(id)sender;

- (IBAction)addByUsername:(id)sender;
@property (nonatomic, strong) NSMutableArray *phonebook;
@property (nonatomic, strong) NSMutableDictionary *alphabeticalPhonebook;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) TPAppDelegate *appDelegate;

@end

@implementation TPAddFriendsViewController

-(TPAppDelegate *)appDelegate {
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"User";
        
        // The key of the PFObject to display in the label of the default cell style
        // self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        self.loadingViewEnabled = NO;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        //        self.objectsPerPage = 40;
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    //    NSLog(@"self.appdel %@", self.appDelegate.contactsPhoneNumbersArray);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor lightGrayColor];
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    if ([self.appDelegate.friendsArray count] == 0) {
        NSLog(@"No friends in app delegate");
    }

    @try {
        [self.appDelegate loadFriends];
    }
    @catch (NSException *exception) {
        NSLog(@"load friends exception add friends screen %@", exception);
    }

    

    
//    [self alertIfNoFriends];
    
    self.sections = @[@"REQUESTS", @"CONTACTS ON TAP", @"INVITE CONTACTS"];
    
    [self setNavbarIcon];
    [self setupNavBarStyle];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 30.0f;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    return 3;
//    return 1;
    return [self.sections count];
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

    [header.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f]];
    view.tintColor = [UIColor whiteColor];
    [header.textLabel setTextColor:[UIColor darkGrayColor]];
    
    if (section == 0) {


    } else if (section == 1) {
//        [header.textLabel setTextColor:[UIColor whiteColor]];
//        view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hypemGreen"]];
    } else {
//        [header.textLabel setTextColor:[UIColor whiteColor]];
//        view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"radRed"]];
    }
    // Background color
    //    if (section == 0) {
//    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
//    view.tintColor = [UIColor whiteColor];
//    view.backgroundColor = [UIColor whiteColor];
    
    // Text Color

    
    CALayer *BottomBorder = [CALayer layer];
    BottomBorder.frame = CGRectMake(0.0f, view.frame.size.height - 0.7f, view.frame.size.width, 0.7f);
    BottomBorder.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    [view.layer addSublayer:BottomBorder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sections objectAtIndex:section];
}

-(void)alertIfNoFriends {
    
    NSInteger totalFriends = [self.appDelegate.friendsArray count];
    
    if (totalFriends == 0) {
        NSLog(@"No friends");
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Have No Friends" message:@"Start by adding or inviting some cool people" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"FUCK YEAH!", nil];
        //        [alert show];
    }
    
}

-(void) setNavbarIcon {
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                       NSForegroundColorAttributeName: [UIColor colorWithPatternImage:[UIImage imageNamed:@"white"]],
                                                                       NSFontAttributeName: [UIFont fontWithName:@"Avenir-Black" size:20.0f],
                                                                       NSShadowAttributeName: shadow
                                                                       }];
}

-(void) setupNavBarStyle {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    //    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"lightGray"];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"black"] forBarMetrics:UIBarMetricsDefault];
}



-(void)goToFriendRequests {
    
    [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self performSegueWithIdentifier:@"showFriendRequests" sender:object];
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSLog(@"Going to friend requests");
        [self goToFriendRequests];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    if (section == 0) {

        if (pendingFriendReqs) {
        NSLog(@"section title %@ want to return %d", [self.sections objectAtIndex:section], 1);
//            return 1;
            return 1;
        } else {
        NSLog(@"section title %@ want to return %d", [self.sections objectAtIndex:section], 0);
            return 0;
        }
    } else if (section == 1) {
//        NSLog(@"section title %@ want to return %ld", [self.sections objectAtIndex:section], [self.objects count]);
//        return 0;
        return [self.objects count];
    }
    else if (section == 2){
//        NSLog(@"section title %@ want to return %ld", [self.sections objectAtIndex:section], [[self.appDelegate.contactsDict allKeys] count]);
        return [self.appDelegate.alphabeticalPhonebook count];
    }

    return 0;

}


-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    NSLog(@"Objects did load");
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

//    NSLog(@"cell for row");
    
    if (indexPath.section == 0) {
//        NSLog(@"section is 0");
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequests" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Friend Requests (%d)", [self.appDelegate.pendingFriendRequests intValue]];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
//        NSLog(@"section is 1");
        cell.detailTextLabel.textColor = [UIColor grayColor];
        //    NSInteger index = indexPath.row;
        
        UIButton *addAsFriendButton = (UIButton *) [cell viewWithTag:1];
        [addAsFriendButton addTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        addAsFriendButton.layer.cornerRadius = 5;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *username = [object objectForKey:@"username"];

        cell.textLabel.text = username;
        cell.detailTextLabel.text = [object objectForKey:@"phoneNumber"];
        
        NSString *friendPhoneNumber = [object objectForKey:@"phoneNumber"];
        
        NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
        
        if (![friendNameInMyContacts isEqual:@""]) {
            cell.textLabel.text = friendNameInMyContacts;
            cell.detailTextLabel.text = username;
            //        cell.detailTextLabel.text = username;
        }
        
        
        
        return cell;
    } else {
//        NSLog(@"section is 2");
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inviteContactCell" forIndexPath:indexPath];
        UIButton *inviteFriendButton = (UIButton *) [cell viewWithTag:3];
        [inviteFriendButton addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        inviteFriendButton.layer.cornerRadius = 5;
        NSArray *keys = [self.appDelegate.contactsDict allKeys];
        
        NSDictionary *contact = [self.appDelegate.alphabeticalPhonebook objectAtIndex:indexPath.row];
        
        NSString *number = [contact objectForKey:@"number"];
        NSString *name = [contact objectForKey:@"name"];
        
        cell.textLabel.text = name;
//        cell.detailTextLabel.text = number;
        return cell;
        
    }
    

}



- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        return nil;
    }
    
    NSLog(@"Queryring for table");
    PFQuery *query = [PFUser query];

    NSArray *friendsPhoneNumbers = self.appDelegate.friendsPhoneNumbersArray;
    
    [query whereKey:@"phoneNumber" containedIn:self.appDelegate.contactsPhoneNumbersArray];
    NSArray *forbiddenNumbers = [friendsPhoneNumbers arrayByAddingObjectsFromArray: self.appDelegate.friendRequestsSent];

    NSLog(@"These are friend requests sent: %@",[[PFUser currentUser]objectForKey:@"friendRequestsSent"]);
    NSArray *friendRequestsSent = [[PFUser currentUser] objectForKey:@"friendRequestsSent"];
    
    [query whereKey:@"objectId" notContainedIn:friendRequestsSent];
    
    NSMutableArray *forbiddenNumbersWithOwnNumber = [forbiddenNumbers mutableCopy];
    [forbiddenNumbersWithOwnNumber addObject:[[PFUser currentUser] objectForKey:@"phoneNumber"]];
    
    [query whereKey:@"phone" notContainedIn: forbiddenNumbersWithOwnNumber];
    
    query.cachePolicy =  kPFCachePolicyCacheThenNetwork;
    return query;
}

- (IBAction)backButton:(id)sender {
    //    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refreshPage:(id)sender {
    //    [self.tableView reloadData];
    //    [self loadView];
    //    [self refreshPage:self];
    [self viewDidLoad];
    
}

- (IBAction)addByUsername:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Add Friend"
                                                      message:@"Enter friend's username"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Add as Friend", nil];
    
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [message show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Add as Friend"])
    {
        UITextField *usernameField = [alertView textFieldAtIndex:0];
        NSString *username = usernameField.text;
        [self getUserByUsernameAndAddAsFriend:username];
    }
}

-(void) getUserByUsernameAndAddAsFriend:(NSString *)username {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            for (id user in [[PFUser currentUser] objectForKey:@"friendsArray"]) {
                if ([[user objectId] isEqual:[object objectId]]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"It seems that you are already friends with this user." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    return;
                }
            }

            
            [self addUserAsFriend:(PFUser *)object andActivityIndicator:nil];

            
        } else {
            NSLog(@"Error finding user by username");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"We couldn't find any user by that username! Please make sure you've got the right one." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

-(void)addUserAsFriend:(PFUser *)user andActivityIndicator:(UIActivityIndicatorView *)ind{
    if (![[[PFUser currentUser] objectForKey:@"friendsArray"] containsObject:user] || [[[PFUser currentUser] objectForKey:@"friendRequestsSent"] containsObject:[user objectId]]) {
        PFObject *friendRequest = [[PFObject alloc] initWithClassName:@"FriendRequest"];
        friendRequest[@"requestingUser"] = [PFUser currentUser];
        friendRequest[@"targetUser"] = user;
        friendRequest[@"requestingUserPhoneNumber"] = [[PFUser currentUser] objectForKey:@"phoneNumber"];
        friendRequest[@"requestingUserUsername"] = [[PFUser currentUser] objectForKey:@"username"];
        friendRequest[@"status"] = @"pending";
        MBProgressHUD *hud;
        if (!ind) {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Adding...";
        }

        
        [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Saved friend request in background");
                //                [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:@{@"targetUserId":[user objectId]} block:^(id object, NSError *error) {
                if (ind) {
                    [ind stopAnimating];
                    [ind setHidden:YES];
                } else {
                    [hud hide:YES];
                }

                [self.appDelegate.friendRequestsSent addObject:[user objectForKey:@"phoneNumber"]];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Friend Request Sent" message:@"Successfuly sent friend request" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                
                // adding friend to friend requests sent
                [[[PFUser currentUser] objectForKey:@"friendRequestsSent"] addObject:[user objectId]];
                
                [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                    NSLog(@"Added %@ to friend requests sent ", [user objectId]);
                    [self loadObjects];
                    [self.tableView reloadData];
                }];
                
                //                }];
                
            } else {
                NSLog(@"Error: %@", error);
            }
            
            //            [self.appDelegate.friendRequestsSent addObject:[user objectForKey:@"phoneNumber"]];
            [self.tableView reloadData];
            
            //            [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
        }];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Sent Friend Request" message:@"You had already sent a friend request to this user" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    
}

-(void) countFriendRequests {
    if (![PFUser currentUser].isAuthenticated){
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"targetUser" equalTo:[PFUser currentUser] ];
    
    NSLog(@"Friends phone numbers array %@", self.appDelegate.friendsPhoneNumbersArray);
    [query whereKey:@"requestingUserPhoneNumber" notContainedIn:self.appDelegate.friendsPhoneNumbersArray];
    [query whereKey:@"status" equalTo:@"pending"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"counted friend requests %d", number);
        self.appDelegate.pendingFriendRequests = @(number);
    }];
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self countFriendRequests];
    [self loadObjects];
    [TPAppDelegate sendMixpanelEvent:@"Opened Add Friends Screen"];
    if ([self.appDelegate.pendingFriendRequests intValue] > 0) {
        pendingFriendReqs = YES;
    } else {
        pendingFriendReqs = NO;
    }
//    [self.tableView reloadData];
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
        
        self.phonebook = [[NSMutableArray alloc] initWithCapacity:[allPeople count]]; // capacity is only
        
        
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
                
                [contact setObject:compositeName forKey:phone];
                
                if (![self.phonebook containsObject:contact]) {
                    [self.phonebook addObject:contact];
                }
                
            }
        }
        CFRelease(addressBook);
        
        //        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        //        //        for (id contact in self.appDelegate.contactsPhoneNumbersArray) {
        //        [self.phonebook sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        //        }
        [self.phonebook sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        allPeople = nil;
        //        NSArray *temp = [[PFUser currentUser]objectForKey:@"contacts"];
        //        if(temp == nil || temp == NULL){
        //            [[PFUser currentUser]setObject:self.phonebook forKey:@"contacts"];
        //            [[PFUser currentUser]saveInBackground];
        //        }
    }
}


-(void)inviteFriend:(id)sender {
    NSLog(@"invite friend");
    [TPAppDelegate sendMixpanelEvent:@"Invited a friend"];
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    id contact = [self.appDelegate.alphabeticalPhonebook objectAtIndex:indexPath.row];
    
    NSString *number = [contact objectForKey:@"number"];
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invite" message:[NSString stringWithFormat:@"This will open a text message with this number %@", number] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"FUCK YEAH!", nil];
//    [alert show];
    
    [self showSMS:self.appDelegate.inviteMessageText andRecipients:number];
}

- (void)showSMS:(NSString*)message andRecipients:(NSString *)number {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[number];
//    NSString *message = message;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


-(void)sendFriendRequest:(id)sender {
    NSLog(@"send friend request");
    [TPAppDelegate sendMixpanelEvent:@"Sent friend request"];
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:55];
    [ind startAnimating];
    [senderButton setHidden:YES];
    [ind setHidden:NO];

    PFUser *user = [self.objects objectAtIndex:indexPath.row];
    [self addUserAsFriend:user andActivityIndicator:ind];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            NSLog(@"sent invite");
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
