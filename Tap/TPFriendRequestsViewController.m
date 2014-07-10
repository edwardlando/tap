//
//  TPFriendRequestsViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/6/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPFriendRequestsViewController.h"
#import "TPAppDelegate.h"

@interface TPFriendRequestsViewController ()

@property (strong, nonatomic) NSArray *friendRequests;
@property (strong, nonatomic) TPAppDelegate *appDelegate;

- (IBAction)goBack:(id)sender;

@end

@implementation TPFriendRequestsViewController

- (TPAppDelegate *)appDelegate
{
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
        self.parseClassName = @"FriendRequest";
        
        // The key of the PFObject to display in the label of the default cell style
        // self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
//        self.objectsPerPage = 10;
        
        
    }
    return self;
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.friendRequests = [self.user objectForKey:@"friendRequestsArray"];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [self.objects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequest" forIndexPath:indexPath];
    
//    PFUser *friendsRequester = [self.friendRequests objectAtIndex:indexPath.row];
//    [friendsRequester fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        NSString *friendRequesterPhoneNumber = [object objectForKey:@"requestingUserPhoneNumber"];
        NSString *friendRequesterNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendRequesterPhoneNumber];
        NSString *friendRequesterUsername = [object objectForKey:@"requestingUserUsername"];
    
        if ([friendRequesterNameInMyContacts isEqual:@""]) {
            cell.textLabel.text = friendRequesterUsername;
            cell.detailTextLabel.text = friendRequesterPhoneNumber;
        } else {
            cell.textLabel.text = friendRequesterNameInMyContacts;
            cell.detailTextLabel.text = friendRequesterUsername;
        }

        UIButton *addButton = (UIButton *)[cell viewWithTag:55];
        
        addButton.layer.cornerRadius = 5;
        [addButton addTarget:self action:@selector(confirmFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *rejectButton = (UIButton *)[cell viewWithTag:2];
        rejectButton.layer.cornerRadius = 5;
        [rejectButton addTarget:self action:@selector(rejectFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
//    }];

    // Configure the cell...
    
    return cell;
}


-(void)rejectFriendRequest:(id) sender {
    NSLog(@"Reject friend request");
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    PFObject *friendRequest = [self.objects objectAtIndex:indexPath.row];
    
    friendRequest[@"status"] = @"rejected";
    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.tableView reloadData];
    }];
}

-(void)confirmFriendRequest:(id)sender {
    UIView *senderButton = (UIView*) sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    PFObject *friendRequest = [self.objects objectAtIndex:indexPath.row];
    
    PFUser *user = [friendRequest objectForKey:@"requestingUser"];
    NSString *friendRequesterPhoneNumber = [friendRequest objectForKey:@"requestingUserPhoneNumber"];
    NSString *friendRequesterNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendRequesterPhoneNumber];
    NSString *friendRequesterUsername = [friendRequest objectForKey:@"requestingUserUsername"];
    
    NSLog(@"Adding this guy as a friend %@", friendRequesterUsername);
    if (![[self.user objectForKey:@"friendsArray"] containsObject:user]) {
        
        PFUser *currentUser = [PFUser currentUser];
        
        [[currentUser objectForKey:@"friendsArray"] addObject:user];
        [[currentUser objectForKey:@"friendsPhones"] addObject:friendRequesterPhoneNumber];
        [[currentUser objectForKey:@"friendsPhonesDict"] setObject:friendRequesterNameInMyContacts forKey:friendRequesterPhoneNumber];
            
//        [[user objectForKey:@"friendsArray"] addObject:currentUser];
//        [[currentUser objectForKey:@"friendRequestsArray"] removeObject:user];
        
        [self.appDelegate.friendsPhoneNumbersArray addObject:friendRequesterPhoneNumber];
        
        friendRequest[@"status"] = @"approved";
        [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Friend request saved in background");
                
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Approved Friend Request");
                        [PFCloud callFunctionInBackground:@"confirmFriendRequest"
                                           withParameters:@{@"reqUserId":[user objectId]}
                                                    block:^(id object, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Error: %@", error);
                                                        } else {
                                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Accepted Friend Request" message:@"You're now friends with this dude" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"FUCK YEAH!", nil];
                                                            [alert show];
                                                            [self viewDidLoad];
                                                        }
                                                        //
                                                    }];
                    } else {
                        NSLog(@"Error: %@", error);
                    }
                    
                }];


            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        return nil;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"targetUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"status" equalTo:@"pending"];
    
    [query orderByDescending:@"createdAt"];
    return query;
}

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

@end
