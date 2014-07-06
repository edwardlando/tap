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

@interface TPAllContactsViewController ()
- (IBAction)backButton:(id)sender;

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
//    NSLog(@"self.appdel %@", self.appDelegate.contactsPhoneNumbersArray);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor lightGrayColor];
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
    self.sections = @[@"My Friends on Tap", @"Invite Friends"];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSString *sectionTitle = [self.sections objectAtIndex:section];
//    NSArray *sectionContacts = [self.alphabeticalPhonebook objectForKey:sectionTitle];
//    if (section == 0) {
//    NSLog(@"self.objects %@", self.objects);
        return [self.objects count];
//    } else {
//        return [self.appDelegate.contactsPhoneNumbersArray count] - self.objects.count ;
//    }

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
    [addAsFriendButton addTarget:self action:@selector(addAsFriend:) forControlEvents:UIControlEventTouchUpInside];
//    NSString *sectionTitle = [self.sections objectAtIndex:indexPath.section];
//    NSArray *sectionContacts = [self.alphabeticalPhonebook objectForKey:sectionTitle];
    
//    if([self.selectedPeople containsObject:[sectionContacts objectAtIndex:index]]){
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    }
//    else{
//        [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
    
//    NSString *name = [[sectionContacts objectAtIndex:index]objectForKey:@"name"];
//    NSString *phone = [[sectionContacts objectAtIndex:index]objectForKey:@"phone"];
    
    cell.textLabel.text = [object objectForKey:@"username"];
    cell.detailTextLabel.text = [object objectForKey:@"phoneNumber"];
    
    return cell;
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return [self.sections count];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [self.sections objectAtIndex:section];
//}
//

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return self.sections;
//}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [self.sections indexOfObject:title];
//}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    // Background color
//    //    if (section == 0) {
//    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]];
//    
//    // Text Color
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    [header.textLabel setTextColor:[UIColor whiteColor]];
//    //    }
//}

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        return nil;
    }
    
    PFQuery *query = [PFUser query];
//    [query includeKey:@"phoneNumber"];
    
//    [query setLimit:0];
    
    [query whereKey:@"phoneNumber" containedIn:self.appDelegate.contactsPhoneNumbersArray];
    [query whereKey:@"phoneNumber" notContainedIn:self.appDelegate.friendsPhoneNumbersArray];
    
//    [query orderByDescending:@"createdAt"];

    return query;
    
}


- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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


-(void)addAsFriend:(id )sender {
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];

    PFUser *user = [self.objects objectAtIndex:indexPath.row];
    
    if (![[[PFUser currentUser] objectForKey:@"friendsArray"] containsObject:user]) {
        
        PFUser *currentUser = [PFUser currentUser];
//        if (![currentUser objectForKey:@"friendsArray"]) {
//            [currentUser objectForKey:@"friendsArray"] = [[NSMutableArray alloc] init];
//        }
        [[currentUser objectForKey:@"friendRequestsArray"] addObject:user];
        
//        [self.appDelegate.friendsPhoneNumbersArray addObject:[user objectForKey:@"phoneNumber"]];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"added as friend");
            } else {
                NSLog(@"Error: %@", error);
            }

        }];
    }
}

@end
