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

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.friendRequests = [[PFUser currentUser] objectForKey:@"friendRequestsArray"];
//    NSLog(@"self.frie %@", self.friendRequests);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    return [[[PFUser currentUser] objectForKey:@"friendRequestsArray"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequest" forIndexPath:indexPath];
    
    PFUser *friendsRequester = [self.friendRequests objectAtIndex:indexPath.row];
    [friendsRequester fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSString *friendRequesterPhoneNumber = [object objectForKey:@"phoneNumber"];
        NSString *friendRequesterNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendRequesterPhoneNumber];

        if ([friendRequesterNameInMyContacts isEqual:@""]) {
            cell.textLabel.text = [object objectForKey:@"username"];
            cell.detailTextLabel.text = friendRequesterPhoneNumber;
        } else {
            cell.textLabel.text = friendRequesterNameInMyContacts;
            cell.detailTextLabel.text = [object objectForKey:@"username"];
        }

        UIButton *addButton = (UIButton *)[cell viewWithTag:55];
    [addButton addTarget:self action:@selector(confirmFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    
//        NSLog(@"ob %@", object);
    }];

    // Configure the cell...
    
    return cell;
}



-(void)confirmFriendRequest:(id)sender {
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[[[senderButton superview]superview] superview]];
    
    PFUser *user = [self.friendRequests objectAtIndex:indexPath.row];
    
    NSLog(@"Adding this guy as a friend %@", [user objectForKey:@"username"]);
    if (![[[PFUser currentUser] objectForKey:@"friendsArray"] containsObject:user]) {
        
        PFUser *currentUser = [PFUser currentUser];
        
        [[currentUser objectForKey:@"friendsArray"] addObject:user];
        [[currentUser objectForKey:@"friendsPhones"] addObject:[user objectForKey:@"phoneNumber"] ];
        
//        [[user objectForKey:@"friendsArray"] addObject:currentUser];
        [[currentUser objectForKey:@"friendRequestsArray"] removeObject:user];
        
        [self.appDelegate.friendsPhoneNumbersArray addObject:[user objectForKey:@"phoneNumber"]];
        
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
                            [self.tableView reloadData];
                            [self.appDelegate loadFriends];
                        }
                        //
                }];
            } else {
                NSLog(@"Error: %@", error);
            }
            
        }];
    }
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
