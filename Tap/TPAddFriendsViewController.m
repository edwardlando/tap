//
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

@interface TPAddFriendsViewController () {
    BOOL pendingFriendReqs;
}

- (IBAction)backButton:(id)sender;
- (IBAction)refreshPage:(id)sender;

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
    
    if ([self.appDelegate.friendsArray count] == 0) {
        NSLog(@"No friends in app delegate");
    }

    @try {
        [self.appDelegate loadFriends];
    }
    @catch (NSException *exception) {
        NSLog(@"load friends exception add friends screen %@", exception);
    }

    
    if ([self.appDelegate.pendingFriendRequests intValue] > 0) {
        pendingFriendReqs = YES;
    } else {
        pendingFriendReqs = NO;
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
    // Background color
    //    if (section == 0) {
//    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    view.tintColor = [UIColor whiteColor];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black"]]];
    [header.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f]];
    
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
                                                                       NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:23.0f],
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
        NSLog(@"section title %@ want to return %ld", [self.sections objectAtIndex:section], [self.objects count]);
//        return 0;
        return [self.objects count];
    }
    else if (section == 2){
        NSLog(@"section title %@ want to return %ld", [self.sections objectAtIndex:section], [[self.appDelegate.contactsDict allKeys] count]);
        return [[self.appDelegate.contactsDict allKeys] count];
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
        NSLog(@"section is 0");
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequests" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Friends Requests (%d)", [self.appDelegate.pendingFriendRequests intValue]];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
        NSLog(@"section is 1");
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
        NSLog(@"section is 2");
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inviteContactCell" forIndexPath:indexPath];

//            NSArray *keys = [self.appDelegate.contactsDict allKeys];
//        
//            NSString *number = [keys objectAtIndex:indexPath.row];
//        
//            NSString *name = [self.appDelegate.contactsDict objectForKey:number];
//            cell.textLabel.text = name;
//            cell.detailTextLabel.text = number;
        
        
        NSArray *keys = [self.appDelegate.contactsDict allKeys];
        
        NSString *number = [keys objectAtIndex:indexPath.row];
        
        NSString *name = [self.appDelegate.contactsDict objectForKey:number];
//        NSDictionary *contact = self.appDelegate.
        
        cell.textLabel.text = name;
        cell.detailTextLabel.text = number;
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


-(void)sendFriendRequest:(id )sender {
    NSLog(@"send friend request");
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:55];
    [ind startAnimating];
    [senderButton setHidden:YES];
    [ind setHidden:NO];

    PFUser *user = [self.objects objectAtIndex:indexPath.row];
    
    
    if (![[[PFUser currentUser] objectForKey:@"friendsArray"] containsObject:user] || [[[PFUser currentUser] objectForKey:@"friendRequestsSent"] containsObject:[user objectId]]) {
        PFObject *friendRequest = [[PFObject alloc] initWithClassName:@"FriendRequest"];
        friendRequest[@"requestingUser"] = [PFUser currentUser];
        friendRequest[@"targetUser"] = user;
        friendRequest[@"requestingUserPhoneNumber"] = [[PFUser currentUser] objectForKey:@"phoneNumber"];
        friendRequest[@"requestingUserUsername"] = [[PFUser currentUser] objectForKey:@"username"];
        friendRequest[@"status"] = @"pending";
        [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Saved friend request in background");
                //                [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:@{@"targetUserId":[user objectId]} block:^(id object, NSError *error) {
                
                [ind stopAnimating];
                [ind setHidden:YES];
                [self.appDelegate.friendRequestsSent addObject:[user objectForKey:@"phoneNumber"]];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Friend Request Sent" message:@"Succesfuly sent friend request" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                
                // adding friend to friend requests sent
                [[[PFUser currentUser] objectForKey:@"friendRequestsSent"] addObject:[user objectId]];
                
                [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                    NSLog(@"Added %@ to friend requests sent ", [user objectId]);
                }];
                
                //                }];
                
            } else {
                NSLog(@"Error: %@", error);
            }
            
        }];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Sent Friend Request" message:@"You had already sent a friend request to this user" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    
}

@end
