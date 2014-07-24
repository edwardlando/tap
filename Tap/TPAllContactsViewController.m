//
//  TPAllContactsViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPAllContactsViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBook.h>
#import "TPAppDelegate.h"

@interface TPAllContactsViewController () {
    BOOL pendingFriendReqs;
}

- (IBAction)backButton:(id)sender;
- (IBAction)refreshPage:(id)sender;

@property (nonatomic, strong) NSMutableArray *phonebook;
@property (nonatomic, strong) NSMutableDictionary *alphabeticalPhonebook;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) TPAppDelegate *appDelegate;

@end

@implementation TPAllContactsViewController

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
    
    NSLog(@"This is still being run");
    
//    NSLog(@"self.appdel %@", self.appDelegate.contactsPhoneNumbersArray);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor lightGrayColor];
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
    


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

    
    self.sections = @[@"Friend Requests", @"Contacts on Tap", @"Invite Contacts"];

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sections objectAtIndex:section];
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


-(void)alertIfNoFriends {
    NSInteger totalFriends = [self.appDelegate.friendsArray count];
    
    if (totalFriends == 0) {
        NSLog(@"No one in group");
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Have No Friends" message:@"Start by adding or inviting some cool people" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"FUCK YEAH!", nil];
        //        [alert show];
    }
    
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


#pragma mark - Table view data source

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
        return [self.objects count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    static NSString *CellIdentifier = @"userCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    int index = indexPath.row;
    
    UIButton *addAsFriendButton = (UIButton *) [cell viewWithTag:1];
    [addAsFriendButton addTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    
    addAsFriendButton.layer.cornerRadius = 5;
    
    
    NSString *username = [object objectForKey:@"username"];
    cell.textLabel.text = username;
    cell.detailTextLabel.text = [object objectForKey:@"phoneNumber"];
    
    NSString *friendPhoneNumber = [object objectForKey:@"phoneNumber"];
    
    NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
    
    if (![friendNameInMyContacts isEqual:@""]) {
        cell.textLabel.text = friendNameInMyContacts;
//        cell.detailTextLabel.text = username;
    }
    

    
    return cell;
}



- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        return nil;
    }
    
    PFQuery *query = [PFUser query];
    NSLog(@"self.friends numbers %@", self.appDelegate.friendsPhoneNumbersArray);
    NSArray *friendsPhoneNumbers = self.appDelegate.friendsPhoneNumbersArray;
    
    [query whereKey:@"phoneNumber" containedIn:self.appDelegate.contactsPhoneNumbersArray];
    
    [query whereKey:@"phone" notContainedIn:[friendsPhoneNumbers arrayByAddingObjectsFromArray: self.appDelegate.friendRequestsSent ]];
    
//    [query whereKey:@"phoneNumber" notContainedIn:self.appDelegate.friendRequestsSent];
    
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
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Friend Request Sent" message:@"Successfuly sent friend request" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
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
