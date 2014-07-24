//
//  TPInboxViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#define FONTSIZE 20.0f

#import "TPInboxViewController.h"
#import "TPSingleTapViewController.h"
#import "TPAppDelegate.h"
#import "TPViewCell.h"
#import "TPCameraViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "CustomBadge.h"

@interface TPInboxViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>
- (IBAction)goToCamera:(id)sender;
@property (strong, nonatomic) NSMutableDictionary *allTaps;
@property (strong, nonatomic) PFObject *selectedInteraction;
@property (strong, nonatomic) PFObject *selectedBroadcast;
@property (strong, nonatomic) PFObject *flipcastToEdit;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSMutableArray *myFlipcasts;
@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary *allTapsImages;
@property (strong, nonatomic) NSMutableArray *allTapsArray;
@property (strong, nonatomic) NSMutableArray *loadedTapsByIndexPaths;
@property (strong, nonatomic) UITableViewCell *cellToRemove;
@property (strong, nonatomic) CustomBadge *customBadge;
@end

@implementation TPInboxViewController {
    BOOL shouldSkipFetchingMyFlips;
}
- (TPAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

-(NSMutableArray *)myFlipcasts {
    if (!_myFlipcasts) {
        _myFlipcasts = [[NSMutableArray alloc] init];
    }
    return _myFlipcasts;
}

-(NSMutableArray *)loadedTapsByIndexPaths {
    if (!_loadedTapsByIndexPaths) {
        _loadedTapsByIndexPaths = [[NSMutableArray alloc] init];
    }
    return _loadedTapsByIndexPaths;
}

-(NSMutableArray *)allTapsArray {
    if (!_allTapsArray) {
        _allTapsArray = [[NSMutableArray alloc] init];
    }
    return _allTapsArray;
}

-(NSMutableDictionary *)allTaps {
    if (!_allTaps) {
        _allTaps = [[NSMutableDictionary alloc] init];
    }
    return _allTaps;
}

-(NSMutableDictionary *)allTapsImages {
    if (!_allTapsImages) {
        _allTapsImages = [[NSMutableDictionary alloc] init];
    }
    return _allTapsImages;
}

-(PFObject *) selectedInteraction {
    if (!_selectedInteraction) {
        _selectedInteraction= [[PFObject alloc] initWithClassName:@"Interaction"];
    }
    return _selectedInteraction;
}

-(PFObject *) selectedBroadcast {
    if (!_selectedBroadcast) {
        _selectedBroadcast = [[PFObject alloc] initWithClassName:@"Broadcast"];
    }
    return _selectedBroadcast;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"Broadcast";
        
        // The key of the PFObject to display in the label of the default cell style
        // self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
//        self.objectsPerPage = 20;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = @[@"ME", @"FRIENDS"];
    NSLog(@"Inbox view did load");
    [self registerForNotifications];
//    [self setTapLogo];
    [self setNavbarIcon];
    [self setupNavBarStyle];
    
//    self.selectedInteraction =[[PFObject alloc] initWithClassName:@"Interaction"];
//    NSLog(@"selected interaction %@", self.selectedInteraction);
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

}

-(void) setNavbarIcon {
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor whiteColor];
    @try {
        [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                           NSForegroundColorAttributeName: [UIColor colorWithPatternImage:[UIImage imageNamed:@"white"]],
                                                                           NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:23.0f],
                                                                           NSShadowAttributeName: shadow
                                                                           }];

    }
    @catch (NSException *exception) {
        NSLog(@"set navbar exception: %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    // Background color
    //    if (section == 0) {
//    //    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    view.tintColor = [UIColor whiteColor];
//    view.backgroundColor = [UIColor whiteColor];
    // Text Color
//    if (section == 0) {
//        view.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
//        view.layer.borderWidth = 3.0f;
//    }
    
//    CALayer *TopBorder = [CALayer layer];
//    TopBorder.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, 3.0f);
//    TopBorder.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
//    [view.layer addSublayer:TopBorder];

    CALayer *BottomBorder = [CALayer layer];
    BottomBorder.frame = CGRectMake(0.0f, view.frame.size.height - 0.7f, view.frame.size.width, 0.7f);
    BottomBorder.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    [view.layer addSublayer:BottomBorder];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black"]]];
    [header.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f]];
    
}


-(void) setupNavBarStyle {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"lightGray"];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"black"] forBarMetrics:UIBarMetricsDefault];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    

}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) setTapLogo {
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabel setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    self.navigationItem.titleView = titleLabel;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.customBadge removeFromSuperview];
    NSLog(@"View disappeared");
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkUserSituation];
    [self.appDelegate loadFriends];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self countFriendRequests];
//    countFriendRequests
//    self.tapsCounterOutlet.frame = CGRectMake(self.tapsCounterOutlet.frame.origin.x, self.tapsCounterOutlet.frame.origin.y, 40, 40);
//    [self.tapsCounterOutlet setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]]];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSingleTapView:)
                                                 name:@"singleTapViewDismissed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewTaps)
                                                 name:@"newTaps"
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(goToCameraInstantaneous)
//                                                 name:@"appEnteredForeground"
//                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToCameraInstantaneous)
                                                 name:@"appEnteredBackground"
                                               object:nil];
    
}

-(void)goToCameraInstantaneous {
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)handleNewTaps {
    NSLog(@"handle new taps");
//    [self queryForTable];
//    self.view ref
//    [self.tableView reloadData];
//    [self viewDidLoad];
}

-(void)didDismissSingleTapView:(NSNotification *)notification {
    NSLog(@"Dismissed single tap view %@", notification.object);
    
    @try {
        
        [self.allTapsImages removeObjectForKey:[self.selectedBroadcast objectId]];
//        TPViewCell *cell = 
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Exceptions : %@", exception);
    }
    @finally {
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return [self.myFlipcasts count];
    } else if (section == 1){
        return [self.objects count];
    }
    
    return 0;

}

-(void)queryMyFlipcasts {
    if (![PFUser currentUser] || ![PFUser currentUser].isAuthenticated) {
        [self checkUserSituation];
        return;
    }
    NSLog(@"querying my broadcasts");

    PFQuery *myFlipcasts = [PFQuery queryWithClassName:@"Flipcast"];
    
    NSLog (@"my flipcasts has cached results %d",[myFlipcasts hasCachedResult]);
    
    [myFlipcasts whereKey:@"owner" equalTo:[PFUser currentUser]];
    myFlipcasts.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [myFlipcasts orderByDescending:@"createdAt"];
    [myFlipcasts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"self.myflip count %lu == objects count %lx", (unsigned long)[self.myFlipcasts count], (unsigned long)[objects count]);
        NSLog(@"[self.myFlipcasts count] != [objects count] ---- %d", [self.myFlipcasts count] != [objects count]);
        if ([self.myFlipcasts count] != [objects count]) {
            self.myFlipcasts = [objects mutableCopy];
            NSLog(@"shouldSkipFetchingMyFlips = NO");
            shouldSkipFetchingMyFlips = NO;
        } else {
            NSLog(@"shouldSkipFetchingMyFlips = YES");
            shouldSkipFetchingMyFlips = YES;
        }
        
        [self.tableView reloadData];
    }];
}

-(void)objectsWillLoad {
    [super objectsWillLoad];
    [self queryMyFlipcasts];
    
}

-(void) objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    NSLog(@"self.objects count %ld", (unsigned long)[self.objects count]);
    NSLog(@"self.mybroadcasts count %ld", (unsigned long)[self.myFlipcasts count]);
}

- (PFQuery *)queryForTable {

    if (![PFUser currentUser] || ![PFUser currentUser].isAuthenticated) {
        [self checkUserSituation];
        return nil;
    }
    
    PFQuery *friendsBroadcasts = [PFQuery queryWithClassName:self.parseClassName];

    [friendsBroadcasts whereKey:@"owner" containedIn:self.appDelegate.friendsArray];
    
    PFQuery *all = [PFQuery orQueryWithSubqueries:@[friendsBroadcasts]];
    [all orderByDescending:@"updatedAt"];
    [all includeKey:@"owner"];

    if ([self.objects count] == 0 ) {
        all.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    
    return all;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sections objectAtIndex:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 30.0f;
    }
}

- (void) initializeSwipeableCell:(TPViewCell *) cell {
    // Add utility buttons
//    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Edit"];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"Delete"];
    
//    cell.leftUtilityButtons = leftUtilityButtons;
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    // Configure the cell...
    // cell.patternLabel.text = [patterns objectAtIndex:indexPath.row];
    // cell.patternImageView.image = [UIImage imageNamed:[patternImages objectAtIndex:indexPath.row]];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
    TPViewCell *cell;
    PFObject *object;
    if (indexPath.section == 0) {

        cell = [tableView dequeueReusableCellWithIdentifier:@"sentTap" forIndexPath:indexPath];
        cell.myFlipcast = [NSNumber numberWithBool:YES];

        // object is class Flipcast
        object = [self.myFlipcasts objectAtIndex:indexPath.row];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recievedTap" forIndexPath:indexPath];

        // object is class Broadcast
        object = [self.objects objectAtIndex:indexPath.row];
    }

    
    // For swipeable cell

    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];


    cell.detailTextLabel.textColor = [UIColor grayColor];

//    PFObject *flipcast = [self.myFlipcasts objectAtIndex:indexPath.row];
    NSDate *created = [object updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
//    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];

    NSString *agoString = [NSString stringWithFormat:@"%@ ago",
                           [self dateDiff:[dateFormat stringFromDate:created]]];
    
    cell.sendingUser = [object objectForKey:@"owner"];
//    NSLog(@"This is the owner %@", [cell.sendingUser objectId]);
    
    if (indexPath.section == 0) {
//        cell.userInteractionEnabled = NO;
        [self initializeSwipeableCell:cell];

        cell.textLabel.text = agoString;
    } else {
//        cell.textLabel.text = ;
        NSString *friendPhoneNumber = [[object objectForKey:@"owner"] objectForKey:@"phoneNumber"];
        NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
        NSString *username = [[object objectForKey:@"owner"] objectForKey:@"username"];
        cell.textLabel.text = (friendNameInMyContacts) ? friendNameInMyContacts : username;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",agoString];

    }
        


    UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
    thumb.layer.cornerRadius = 5;

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
//        tapsQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    if (indexPath.section == 0) {
//        NSLog(@"Section 0 %@",[object objectForKey:@"batchId"]);
        [tapsQuery whereKey:@"batchId" equalTo:[object objectForKey:@"batchId"]];
    } else {
//        NSLog(@"Section 1 %@",[object objectForKey:@"batchIds"]);
        [tapsQuery whereKey:@"batchId" containedIn:[object objectForKey:@"batchIds"]];
    }
        [tapsQuery whereKey:@"imageId" equalTo:@(1)];
        [tapsQuery orderByAscending:@"batchId"];
        [tapsQuery whereKey:@"sender" equalTo:cell.sendingUser];
        [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
        [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
        [tapsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

            
            if (!error) {
                [ind setHidden:NO];
                [ind startAnimating];
 
                long viewsCount = [[object objectForKey:@"read"] count];
                __block int numOfTaps = 0;

                 
                
                    if (indexPath.section == 0) {
                        [tapsQuery whereKey:@"imageId" notEqualTo:@(1)];
                        [tapsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                            numOfTaps = number  + 1;
                            if (viewsCount > 0) {
                                if ([cell.hasLoaded boolValue] || [self.loadedTapsByIndexPaths containsObject:indexPath]) {
                                    cell.detailTextLabel.text = (viewsCount == 1) ? [NSString stringWithFormat:@"Tap to Load - %d taps - %ld view", number+1, viewsCount] : [NSString stringWithFormat:@"Tap to Load - %d taps - %ld views", number + 1, viewsCount];
                                    
                                } else {
                                    cell.detailTextLabel.text = (viewsCount == 1) ? [NSString stringWithFormat:@"Tap to Open - %d taps - %ld view", number+1, viewsCount] : [NSString stringWithFormat:@"Tap to Open - %d taps - %ld views", number + 1, viewsCount];
                                }
                                
                            } else {
                                if ([cell.hasLoaded boolValue] || [self.loadedTapsByIndexPaths containsObject:indexPath]) {
                                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tap to Open - %d taps", number + 1];
                                } else {
                                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tap to Load - %d taps", number + 1];
                                }

                            }
                            
                            
                        NSLog(@"This many taps %d", number + 1);
                        }];
                    } else if (indexPath.section == 1) {
                       cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONTSIZE];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - Tap to Load", agoString];
                        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
                    }


                PFFile *image = [object objectForKey:@"img"];
                NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           if ( !error )
                                           {
                                               UIImage *image = [[UIImage alloc] initWithData:data];
                                               thumb.image = image;
//                                               if (indexPath.section == 0)
//                                                   cell.detailTextLabel.text = @"Tap to Open";//[NSString stringWithFormat:@"Tap to Open - %d taps", numOfTaps];
                                               
                                               cell.hasNewTaps = @(YES);
                                               [ind stopAnimating];
                                               [ind setHidden:YES];
                                           } else {
                                               NSLog(@"Error gettings image");
                                           }
                                       }];
            } else {
                [ind stopAnimating];
                [ind setHidden:YES];
               cell.hasNewTaps = @(NO);
                NSLog(@"Error finding first object: %@", error);
            }
        }];
//        });
//    }
    return cell;
}

-(void)editFlipcast:(id)sender {
//    UIView *senderButton = (UIView*) sender;
    UITableViewCell *cell =sender;//(UITableViewCell *)[[[sender superview] superview] superview];
    self.cellToRemove = cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    
// remove batch Id from broadcast array
    
    PFObject *flipCast = [self.myFlipcasts objectAtIndex:indexPath.row];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.flipcastToEdit = flipCast;
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Edit Cast"
                                                      message:@"Confirm Deletion"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Delete", nil];
    [message setTag:1];
    [message show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Delete"])
        {
            NSLog(@"Delete %@", self.flipcastToEdit);
            [self deleteFlipCast:self.flipcastToEdit];
        }
    }
}

-(void)deleteFlipCast:(PFObject *)flipcast {
    NSString *batchId = [flipcast objectForKey:@"batchId"];
    PFQuery *mybroadcast = [PFQuery queryWithClassName:@"Broadcast"];
    [mybroadcast whereKey:@"owner" equalTo:[PFUser currentUser]];
    [mybroadcast getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSMutableArray *batchIds = [object objectForKey:@"batchIds"];
            if ([batchIds containsObject:batchId]) {
                NSLog(@"found batchId %@ in batchIds", batchId);
                [batchIds removeObject:batchId];
                [object setObject:batchIds forKey:@"batchIds"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        
//                        [self.cellToRemove removeFromSuperview];
                        [self.myFlipcasts removeObject:flipcast];
                        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:self.cellToRemove]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                        [self.tableView reloadData];
                        
                        NSLog(@"Successfuly removed batchId");
                    } else {
                        NSLog(@"Error removing batchId: %@", error);
                    }
                }];
            }
        } else {
            NSLog(@"Error getting broadcast: %@", error);
        }
    }];
    [flipcast deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Removed this cast");
        } else {
            NSLog(@"Error deleting cast: %@", error);
        }
    }];
}

-(NSString *)dateDiff:(NSString *)origDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    NSDate *convertedDate = [df dateFromString:origDate];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
    	return @"just now";
    } else if (ti < 60) {
    	return [NSString stringWithFormat:@"%ds", [@(ti) intValue] ];
    } else if (ti >= 60 && ti < 120) {
        return @"1m";
    } else if (ti >= 120 && ti < 3600) {
    	int diff = round(ti / 60);
    	return [NSString stringWithFormat:@"%dm", diff];
    } else if (ti > 3600 && ti < 7200) {
    	return @"1h";
    } else if (ti >= 7200 && ti < 86400) {
    	int diff = round(ti / 60 / 60);
    	return[NSString stringWithFormat:@"%dh", diff];
    }
    else if (ti >= 86400 && ti < 172800) {
        return @"1d";
    }
    else if (ti >= 172800 && ti < 2629743) {
    	int diff = round(ti / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%dd", diff];
    } else {
    	return @"";
    }
}

-(void) countFriendRequests {
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"targetUser" equalTo:[PFUser currentUser] ];
    [query whereKey:@"status" equalTo:@"pending"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"counted friend requests %d", number);
        self.appDelegate.pendingFriendRequests = @(number);
        [self initFriendRequestsBadge];
    }];
}

-(void)initFriendRequestsBadge {
    NSLog(@"initFriendRequestsBadge");
    
    if ([self.appDelegate.pendingFriendRequests intValue] > 0) {
        self.customBadge = [CustomBadge customBadgeWithString:[self.appDelegate.pendingFriendRequests stringValue]
                                                       withStringColor:[UIColor whiteColor]
                                                        withInsetColor:[UIColor blackColor]
                                                        withBadgeFrame:YES
                                                   withBadgeFrameColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]]
                                                             withScale:1.0
                                                           withShining:NO];
        
    [self.customBadge setFrame:CGRectMake(self.view.frame.size.width - 35, 20, self.customBadge.frame.size.width, self.customBadge.frame.size.height)];
    
        self.customBadge.userInteractionEnabled = YES;
        UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(showFriends:)];
        pgr.delegate = self;
        [self.customBadge addGestureRecognizer:pgr];
        
        
    [self.navigationController.view addSubview:self.customBadge];
//        ;
    }
}

-(void)checkUserSituation {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser && currentUser.isAuthenticated) {
        NSLog(@"No user on inbox");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)showFriends:(id)sender {
    [self.customBadge removeFromSuperview];
    [self performSegueWithIdentifier:@"showFriends" sender:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TPViewCell *cell = (TPViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"Cell.hasNewTaps %x", [cell.hasNewTaps boolValue]);
    
    if (![cell.hasNewTaps boolValue]) return;
    
    if (![self.loadedTapsByIndexPaths containsObject:indexPath]) {
        NSLog(@"Loaded taps doesn't contain this one: %@", indexPath);
//        cell.detailTextLabel.text = @"Loading...";
//        UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
//        [ind startAnimating];
//        [ind setHidden:NO];
        
        [self loadImagesForIndexPath:indexPath];
        return;
    }
    
    BOOL isMyFlipcast;
    
    if (indexPath.section == 0) {
        self.selectedBroadcast =[self.myFlipcasts objectAtIndex:indexPath.row];
        isMyFlipcast = YES;
    } else {
        self.selectedBroadcast =[self.objects objectAtIndex:indexPath.row];
        isMyFlipcast = NO;
    }
    
    NSMutableArray *batchTaps = [self.allTaps objectForKey:[self.selectedBroadcast objectId]];
//    NSMutableArray *batchTapsImages = [self.allTapsImages objectForKey:[self.selectedInteraction objectId]];
    NSMutableDictionary *allInteractionTaps =[self.allTapsImages objectForKey:[self.selectedBroadcast objectId]];
    
    
    UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
    [tapsCounter setHidden:YES];
    

    if (([batchTaps count] == 0 || !allInteractionTaps) && !isMyFlipcast) {
        NSLog(@"Batch taps is 0 or no interactionsTaps");
        NSLog(@"BatchTaps %@", batchTaps);
        NSLog(@"allInteractionTaps %@", allInteractionTaps);

//        PFUser *userToReply = cell.sendingUser;
//        [self performSegueWithIdentifier:@"showCamera" sender:userToReply];
////        [self goToCamera:self];
        
    } else {
        NSSortDescriptor *imageIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageId" ascending:YES];
        NSArray *sortDescriptors = @[imageIdDescriptor];
        
//        NSArray *sortedImagesArray = [batchTapsImages sortedArrayUsingDescriptors:sortDescriptors];
        NSArray *sortedTapsArray = [batchTaps sortedArrayUsingDescriptors:sortDescriptors];
        
//        NSLog(@"batch images array %@", batchTapsImages);
//        NSLog(@"sorted batch images array %@", sortedImagesArray);
//        NSLog(@"batch taps %@", batchTaps);
        
//        if (cell.justVisited) {
//            NSLog(@"tapped on the one visited");
//            batchTaps = [[NSMutableArray alloc] init];
//            sortedImagesArray = [[NSMutableArray alloc] init];
            
//        }
    
        
        NSMutableDictionary *allTapsDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *allFlipcastsArray = [[NSMutableArray alloc] init];
        
        for (id tap in self.allTapsArray) {
            NSString *tapBroadcastId = [tap objectForKey:@"broadcastId"];
            
            NSString *tapBatchId = [tap objectForKey:@"batchId"];

            if ([tapBroadcastId isEqualToString: [self.selectedBroadcast objectId]]) {
                if (![allFlipcastsArray containsObject:tapBatchId]) {
                    [allFlipcastsArray addObject:tapBatchId];
                }
                if (![allTapsDict objectForKey:tapBatchId]) {
                    NSLog(@"First tap %@", [tap objectForKey:@"imageId"]);
                    [allTapsDict setObject:[[NSMutableArray alloc] initWithObjects:tap, nil] forKey:tapBatchId];
                } else {
                    if (![[allTapsDict objectForKey:tapBatchId] containsObject:tap]) {
                        NSLog(@"adding this %@", [tap objectForKey:@"imageId"]);
                        [[allTapsDict objectForKey:tapBatchId] addObject:tap];
                    } else {
                        NSLog(@"aleady contains this tap %@", [tap objectForKey:@"imageId"]);
                    }
                }
            }
        }

        if (isMyFlipcast) {
         NSLog(@"It is my flipcast");
        } else {
            [[cell viewWithTag:516] setHidden:YES];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:FONTSIZE];

        }
        
        NSDictionary *senderObject = @{@"allInteractionTaps" :allTapsDict, @"allTapObjects": sortedTapsArray, @"isMyFlipcast":@(isMyFlipcast), @"allFlipcastsArray": allFlipcastsArray};
        
        [self performSegueWithIdentifier:@"showTap" sender:senderObject];
        
    }
}

-(void)loadImagesForIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"loadImagesForIndexPath %@", indexPath);
    
    TPViewCell *cell = (TPViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    
    
    

    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    [ind startAnimating];
    [ind setHidden:NO];
    
    if (indexPath.section == 0) {
//        static NSString *CellIdentifier = @"sentTap";
        
        NSLog(@"Section is 0: My Taps");
        
        PFObject *flipcast = [self.myFlipcasts objectAtIndex:indexPath.row];
        
        
        NSDate *created = [flipcast updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Loading...",
                                     [self dateDiff:[dateFormat stringFromDate:created]]];
        cell.userInteractionEnabled = NO;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:FONTSIZE];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ ago",
                               [self dateDiff:[dateFormat stringFromDate:created]]];
        
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        cell.sendingUser = [flipcast objectForKey:@"owner"];
        
        cell.myFlipcast = [NSNumber numberWithBool:YES];
        
        PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
//        tapsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        //         tapsQuery.cachePolicy = kPFCachePolicyCacheOnly;
        NSString *broadcastId = [flipcast objectId];
        
        UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
        UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
//        thumb.layer.cornerRadius = 5;
        NSLog(@"My Flipcasts count %ld", (unsigned long)[self.myFlipcasts count]);
        
//        if (shouldSkipFetchingMyFlips) {
//            NSLog(@"shouldSkipFetchingMyFlips in loadImagesForIndexPath");
//            cell.userInteractionEnabled = YES;
////            cell.hasLoaded = [NSNumber numberWithBool:YES];
//            [self.loadedTapsByIndexPaths addObject:indexPath];
//            return;
//        }
        
        [tapsQuery whereKey:@"batchId" equalTo:[flipcast objectForKey:@"batchId"]];
        [tapsQuery orderByAscending:@"batchId"];
        [tapsQuery whereKey:@"sender" equalTo:cell.sendingUser];
        [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
        [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
        [tapsQuery setLimit:1000];
        [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([objects count] > 0) {
//                    cell.detailTextLabel.text = @"Loading...";
//                    
//                    NSLog(@"Number of objects %ld", (unsigned long)[objects count]);
//                    cell.userInteractionEnabled = NO;
//                    [tapsCounter setHidden: YES];
//                    [ind startAnimating];
//                    [ind setHidden:NO];
                } else {
                    NSLog(@"No Objects");
                }
                
                [self.allTaps setObject:objects forKey:broadcastId];
                
                NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];
                NSMutableDictionary *allPhotosInBatchDict = [[NSMutableDictionary alloc] init];
                
                __block int iterations = 0;
                
                for (PFObject *tap in objects) {
                    PFFile *image = [tap objectForKey:@"img"];
                    NSString *imageId = [tap objectForKey:@"imageId"];
                    NSString *batchId = [tap objectForKey:@"batchId"];
                    
                    
                    
                    NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                    [NSURLConnection sendAsynchronousRequest:request
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               if ( !error )
                                               {
                                                   //                                                    NSLog(@"Start fetching photos");
                                                   //                                                    NSLog(@"read array %@", [tap objectForKey:@"readArray"]);
                                                   //                                                    long readArrayCount = [[tap objectForKey:@"readArray"] count];
                                                   //                                                    if (readArrayCount > 0) {
                                                   //                                                        cell.detailTextLabel.text = readArrayCount == 1 ? [NSString stringWithFormat:@"Tap to open - %ld view", readArrayCount] : [NSString stringWithFormat:@"Tap to open - %ld views", readArrayCount];
                                                   //                                                    }
                                                   // [self dateDiff:[dateFormat stringFromDate:created]]];
                                                   
                                                   [ind setHidden:NO];
                                                   [ind startAnimating];
                                                   
                                                   [ind hidesWhenStopped];
                                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                                   
                                                   if (iterations == 0) {
//                                                       thumb.image = image;
                                                   }
                                                   
                                                   [allPhotosInBatch addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId}];
                                                   id objectToAdd = @{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId};
                                                   
                                                   if (![self.allTapsArray containsObject:objectToAdd]){
                                                       [self.allTapsArray addObject:objectToAdd];
                                                   }
                                                   
                                                   
                                                   NSLog(@"%d iterations out of %ld objects", iterations, (unsigned long)[objects count]);
                                                   
                                                   iterations++;
                                                   if (iterations == [objects count]) {
                                                       
                                                       // setting the thumbnail
                                                       [thumb setAlpha:0.9];
                                                       long viewsCount = [[flipcast objectForKey:@"read"] count];
                                                       
                                                       if (viewsCount > 0) {
                                                           
                                                           cell.detailTextLabel.text = (viewsCount == 1) ? [NSString stringWithFormat:@"Tap to Open - %ld view", viewsCount] : [NSString stringWithFormat:@"Tap to Open - %ld views", viewsCount];
                                                           
                                                       } else {
                                                           cell.detailTextLabel.text = @"Tap to Open";//[NSString stringWithFormat:@"%@ ago - Tap to open",
                                                       }

//                                                       thumb.layer.cornerRadius = 5;
                                                       //                                                        [self.allTapsImages setObject:allPhotosInBatchDict forKey:batchId];
                                                       
                                                       [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                       
                                                       [allPhotosInBatchDict setObject: allPhotosInBatch forKey:batchId];
                                                       //                                                        NSLog(@"all photos in batch %@", allPhotosInBatch);
                                                       //  [self.allTapsImages setValue:allPhotosInBatch forKey:batchId];
                                                       //   NSLog(@"All taps images %@", self.allTapsImages);
                                                       [ind stopAnimating];
                                                       [ind setHidden:YES];
                                                       
                                                       cell.userInteractionEnabled = YES;
                                                       
                                                       [self.loadedTapsByIndexPaths addObject:indexPath];
                                                       tapsCounter.text = [NSString stringWithFormat:@"%ld",(unsigned long)[objects count] ];
                                                       
                                                       [thumb setHidden:NO];
                                                   }
                                                   //                                              completionBlock(YES,image);
                                               } else{
                                                   //                                               completionBlock(NO,nil);
                                               }
                                           }];
                    
                    
                }
                
                tapsCounter.layer.cornerRadius = 5;
                tapsCounter.clipsToBounds = YES;
                
                if ([objects count] > 0) {
                    //                      cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
                    
                    //                cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightGray"]];
                } else {
                    
//                    cell.userInteractionEnabled = YES;
                    //                cell.backgroundColor = [UIColor whiteColor];
                    [ind stopAnimating];
                    [ind setHidden:YES];
                    [tapsCounter setHidden:YES];
                    [thumb setHidden:YES];
                }
                
                
            } else {
                NSLog(@"Error: %@", error);
            }
        }];

        return;
        
    }
    else if (indexPath.section == 1) {
        
        static NSString *CellIdentifier = @"recievedTap";
        
//        TPViewCell *cell = (TPViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
//        cell.userInteractionEnabled = NO;
//        cell.detailTextLabel.text = @"Loading...";
        UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
        [ind startAnimating];
        [ind setHidden:NO];
        
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *friendPhoneNumber = [[object objectForKey:@"owner"] objectForKey:@"phoneNumber"];
        NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
        
        NSString *username = [[object objectForKey:@"owner"] objectForKey:@"username"];
        
        NSLog(@"username %@", username);
        NSLog(@"name %@", friendNameInMyContacts);
        
        cell.sendingUser = [object objectForKey:@"owner"];
        
        cell.textLabel.text = (friendNameInMyContacts) ? friendNameInMyContacts : username ;
        
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        NSDate *created = [object updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Loading...",
                                     [self dateDiff:[dateFormat stringFromDate:created]]];
        cell.backgroundColor = [UIColor whiteColor];
        
        @try {
            if ([self.selectedBroadcast isKindOfClass:[PFObject class]]) {
                if ([[object updatedAt] isEqual:[self.selectedBroadcast updatedAt]]) {
                    NSLog(@"not reloading the one just watched");
                    //                 cell.justVisited = [NSNumber numberWithBool:YES];
                    //                 return cell;
                } else {
                    //                 cell.justVisited = [NSNumber numberWithBool:NO];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
        }
        
        
        
        NSString *broadcastId = [object objectId];
        
        UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
        UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
        
        thumb.layer.cornerRadius = 5;
        
        //         self.allTapsArray = [[NSMutableArray alloc] init];
        PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
        [tapsQuery whereKey:@"batchId" containedIn:[object objectForKey:@"batchIds"]];
        [tapsQuery orderByAscending:@"batchId"];
        [tapsQuery whereKey:@"sender" equalTo:cell.sendingUser];
        [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
        [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
        [tapsQuery setLimit:1000];
        [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([objects count] > 0) {
//                    cell.detailTextLabel.text = @"Loading...";
                    NSLog(@"Number of objects %ld", (unsigned long)[objects count]);

//                    [tapsCounter setHidden: YES];
//                    [ind setHidden:NO];
//                    [ind startAnimating];
                } else {
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:FONTSIZE];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - no new taps",
                                                 [self dateDiff:[dateFormat stringFromDate:created]]];/*, (unsigned long)[objects count]*/
                }
                
                //            NSLog(@"Found %ld objects", [objects count]);
                [self.allTaps setObject:objects forKey:broadcastId];
                
                NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];
                NSMutableDictionary *allPhotosInBatchDict = [[NSMutableDictionary alloc] init];
                
                __block int iterations = 0;
                
                for (PFObject *tap in objects) {
                    PFFile *image = [tap objectForKey:@"img"];
                    NSString *imageId = [tap objectForKey:@"imageId"];
                    NSString *batchId = [tap objectForKey:@"batchId"];
                    
                    NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                    [NSURLConnection sendAsynchronousRequest:request
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               if ( !error )
                                               {
                                                   //                                                   NSLog(@"Start fetching photos");
                                                   cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONTSIZE];
                                                   
                                                   [ind setHidden:NO];
                                                   [ind startAnimating];
                                                   
                                                   [ind hidesWhenStopped];
                                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                                   if (iterations == 0) {
                                                       thumb.image = image;
                                                   }
                                                   [allPhotosInBatch addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId}];
                                                   
                                                   [self.allTapsArray addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId , @"broadcastId":broadcastId}];
                                                   
                                                   //                                                       NSLog(@"%d iterations out of %ld objects", iterations, (unsigned long)[objects count]);
                                                   
                                                   
                                                   iterations++;
                                                   if (iterations == [objects count]) {
                                                       
                                                       // setting the thumbnail
                                                       
                                                       [thumb setAlpha:0.9];
                                                       [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                       [allPhotosInBatchDict setObject: allPhotosInBatch forKey:[tap objectForKey:@"batchId"]];
                                                       cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to open",
                                                                                    [self dateDiff:[dateFormat stringFromDate:created]]];
                                                       
                                                       //                                                       NSLog(@"all photos in batch %@", allPhotosInBatch);
                                                       //  [self.allTapsImages setValue:allPhotosInBatch forKey:batchId];
                                                       //   NSLog(@"All taps images %@", self.allTapsImages);
                                                       [ind stopAnimating];
                                                       [ind setHidden:YES];
                                                       cell.userInteractionEnabled = YES;

                                                       [self.loadedTapsByIndexPaths addObject:indexPath];
                                                       
                                                       
                                                       tapsCounter.text = [NSString stringWithFormat:@"%ld",(unsigned long)[objects count] ];
                                                       
                                                       [thumb setHidden:NO];
                                                   }
                                                   //                                              completionBlock(YES,image);
                                               } else{
                                                   //                                               completionBlock(NO,nil);
                                               }
                                           }];
                    
                    
                }
                
                tapsCounter.layer.cornerRadius = 5;
                tapsCounter.clipsToBounds = YES;
                
                if ([objects count] > 0) {
                    //                cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightGray"]];
                } else {
                    
                    cell.userInteractionEnabled = YES;
                    //                cell.backgroundColor = [UIColor whiteColor];
                    [ind stopAnimating];
                    [ind setHidden:YES];
                    [tapsCounter setHidden:YES];
                    [thumb setHidden:YES];
                }
                
                
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
        return;
    }

}

- (IBAction)goToCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.customBadge removeFromSuperview];
    if ([segue.identifier isEqual:@"showTap"]) {
        NSLog(@"Performing segue show tap");
        
        TPSingleTapViewController *vc = (TPSingleTapViewController *)segue.destinationViewController;
//        vc.spray = self.selectedBroadcast;
        @try {
            vc.objects = [sender objectForKey:@"allTapObjects"];
            vc.allBatchImages = [sender objectForKey:@"batchImages"];
            
            vc.allFlipCasts = [sender objectForKey:@"allFlipcastsArray"];
            
            vc.allInteractionTaps = [sender objectForKey:@"allInteractionTaps"];
            vc.sendingUser = [self.selectedBroadcast objectForKey:@"owner"];
            
            
            NSLog(@"sender is my flip %@", [sender objectForKey:@"isMyFlipcast"]);
            vc.isMyFlipcast = [sender objectForKey:@"isMyFlipcast"];

        }
        @catch (NSException *exception) {
            NSLog(@"Exception getting all tap properties: %@", exception);
        }

        
    } else if ([segue.identifier isEqual:@"showCamera"]) {
        TPCameraViewController *vc = (TPCameraViewController *)segue.destinationViewController;
        vc.isReply = [NSNumber numberWithBool:YES];
        vc.directRecipient = sender;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Edit button is pressed
//            UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook", @"Share on Twitter", nil];
//            [shareActionSheet showInView:self.view];
            
            
            [self editFlipcast:cell];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
//        case 1:
//        {
//            // Delete button is pressed
//            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
////            [patterns removeObjectAtIndex:cellIndexPath.row];
////            [patternImages removeObjectAtIndex:cellIndexPath.row];
//            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
//            break;
//        }
        default:
            break;
    }
}


@end
