//
//  TPInboxViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPInboxViewController.h"
#import "TPSingleTapViewController.h"
#import "TPAppDelegate.h"
#import "TPViewCell.h"
#import "TPCameraViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface TPInboxViewController () <UIAlertViewDelegate>
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
@property (strong, nonatomic) UITableViewCell *cellToRemove;

@end

@implementation TPInboxViewController
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
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                       NSForegroundColorAttributeName: [UIColor colorWithPatternImage:[UIImage imageNamed:@"white"]],
                                                                       NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:23.0f],
                                                                       NSShadowAttributeName: shadow
                                                                       }];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    // Background color
    //    if (section == 0) {
    //    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    view.tintColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor whiteColor];
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


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    NSLog(@"querying my broadcasts");

    PFQuery *myFlipcasts = [PFQuery queryWithClassName:@"Flipcast"];
    
    NSLog (@"my flipcasts has cached results %d",[myFlipcasts hasCachedResult]);
    
    [myFlipcasts whereKey:@"owner" equalTo:[PFUser currentUser]];
    myFlipcasts.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [myFlipcasts orderByDescending:@"createdAt"];
    [myFlipcasts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.myFlipcasts = [objects mutableCopy];
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


 - (TPViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSLog(@"CEll For Row");
     if (indexPath.section == 0) {
         static NSString *CellIdentifier = @"sentTap";
         
         TPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
         
         // For swipeable cell
         [self initializeSwipeableCell:cell];
         
         UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
         [ind setHidden:YES];
         PFObject *flipcast = [self.myFlipcasts objectAtIndex:indexPath.row];
         NSDate *created = [flipcast updatedAt];
         NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
         [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
         cell.userInteractionEnabled = NO;

         cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
         cell.textLabel.text = [NSString stringWithFormat:@"%@ ago",
                                      [self dateDiff:[dateFormat stringFromDate:created]]];
         cell.detailTextLabel.textColor = [UIColor grayColor];
         
         
         cell.sendingUser = [flipcast objectForKey:@"owner"];
         cell.myFlipcast = [NSNumber numberWithBool:YES];
         
         PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
         tapsQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
//         tapsQuery.cachePolicy = kPFCachePolicyCacheOnly;
         NSString *broadcastId = [flipcast objectId];
         
         UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
         UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
         UIButton *editButton = (UIButton *)[cell viewWithTag:476];
         
         [editButton addTarget:self action:@selector(editFlipcast:) forControlEvents:UIControlEventTouchUpInside];
         
         thumb.layer.cornerRadius = 5;
         
         self.allTapsArray = [[NSMutableArray alloc] init];
         
         [tapsQuery whereKey:@"batchId" equalTo:[flipcast objectForKey:@"batchId"]];
         [tapsQuery orderByAscending:@"batchId"];
         [tapsQuery whereKey:@"sender" equalTo:cell.sendingUser];
         [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
         [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
         
         
         [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             if (!error) {
                 if ([objects count] > 0) {
                     cell.detailTextLabel.text = @"Loading...";
                     NSLog(@"Number of objects %ld", (unsigned long)[objects count]);
                     cell.userInteractionEnabled = NO;
                     [tapsCounter setHidden: YES];
                     [ind startAnimating];
                     [ind setHidden:NO];
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
                                                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
                                                    
                                                    cell.detailTextLabel.text = @"Tap to open";//[NSString stringWithFormat:@"%@ ago - Tap to open",
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
                                                        thumb.image = image;
                                                    }
                                                    
                                                    [allPhotosInBatch addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId}];
                                                    id objectToAdd = @{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId};
                                                    
                                                    if (![self.allTapsArray containsObject:objectToAdd]){
                                                            [self.allTapsArray addObject:objectToAdd];
                                                        }
                                                    
                                                    
//                                                    NSLog(@"%d iterations out of %ld objects", iterations, (unsigned long)[objects count]);
                                                    
                                                    iterations++;
                                                    if (iterations == [objects count]) {
                                                        
                                                        // setting the thumbnail
                                                        
                                                        thumb.layer.cornerRadius = 5;
//                                                        [self.allTapsImages setObject:allPhotosInBatchDict forKey:batchId];
                                                        
                                                        [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                        
                                                        [allPhotosInBatchDict setObject: allPhotosInBatch forKey:batchId];
//                                                        NSLog(@"all photos in batch %@", allPhotosInBatch);
                                                        //  [self.allTapsImages setValue:allPhotosInBatch forKey:batchId];
                                                        //   NSLog(@"All taps images %@", self.allTapsImages);
                                                        [ind stopAnimating];
                                                        [ind setHidden:YES];

                                                        cell.userInteractionEnabled = YES;
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
         return cell;
         
     }
     else if (indexPath.section == 1) {
         
        static NSString *CellIdentifier = @"recievedTap";

        TPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
         
        UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
       [ind setHidden:YES];
      [ind stopAnimating];
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
        cell.userInteractionEnabled = NO;
         cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
         cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - no new taps 😭",
          [self dateDiff:[dateFormat stringFromDate:created]]];/*, (unsigned long)[objects count]*/

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
         
         PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];

         NSString *broadcastId = [object objectId];
         
         UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
         UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
         
         thumb.layer.cornerRadius = 5;
         
         self.allTapsArray = [[NSMutableArray alloc] init];
         
        [tapsQuery whereKey:@"batchId" containedIn:[object objectForKey:@"batchIds"]];
        [tapsQuery orderByAscending:@"batchId"];
        [tapsQuery whereKey:@"sender" equalTo:cell.sendingUser];
        [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
        [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
         
        [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([objects count] > 0) {
                    cell.detailTextLabel.text = @"Loading...";
                    NSLog(@"Number of objects %ld", (unsigned long)[objects count]);
                    cell.userInteractionEnabled = NO;
                    [tapsCounter setHidden: YES];
                    [ind setHidden:NO];
                     [ind startAnimating];
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
                                                   cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
                                                   
                                                   cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to open",
                                                                                [self dateDiff:[dateFormat stringFromDate:created]]];
                                                   
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

                                                       thumb.layer.cornerRadius = 5;
                                                       [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                      [allPhotosInBatchDict setObject: allPhotosInBatch forKey:[tap objectForKey:@"batchId"]];
//                                                       NSLog(@"all photos in batch %@", allPhotosInBatch);
                                                       //  [self.allTapsImages setValue:allPhotosInBatch forKey:batchId];
                                                       //   NSLog(@"All taps images %@", self.allTapsImages);
                                                       [ind stopAnimating];
                                                       [ind setHidden:YES];
                                                       cell.userInteractionEnabled = YES;
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
         return cell;
     }
    
    return [[UITableViewCell alloc] init];
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
    }];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

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
    
    
//    NSLog(@"batch taps %@", batchTaps);
    
    TPViewCell *cell = (TPViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
    [tapsCounter setHidden:YES];
    

    if ([batchTaps count] == 0 || !allInteractionTaps) {

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
        
        for (id tap in self.allTapsArray) {
            NSString *tapBroadcastId = [tap objectForKey:@"broadcastId"];
            
            NSString *tapBatchId = [tap objectForKey:@"batchId"];
            if ([tapBroadcastId isEqualToString: [self.selectedBroadcast objectId]]) {
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

        if (isMyFlipcast) NSLog(@"It is my flipcast");
        
        NSDictionary *senderObject = @{@"allInteractionTaps" :allTapsDict, @"allTapObjects": sortedTapsArray, @"isMyFlipcast":@(isMyFlipcast)};
        
        [self performSegueWithIdentifier:@"showTap" sender:senderObject];
        
        
    }

}

- (IBAction)goToCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showTap"]) {
        TPSingleTapViewController *vc = (TPSingleTapViewController *)segue.destinationViewController;
        vc.spray = self.selectedBroadcast;
        vc.objects = [sender objectForKey:@"allTapObjects"];
        vc.allBatchImages = [sender objectForKey:@"batchImages"];
        
//        vc.allInteractionTaps = allTapsDict;
        vc.allInteractionTaps = [sender objectForKey:@"allInteractionTaps"];
        
        NSLog(@"sender is my flip %@", [sender objectForKey:@"isMyFlipcast"]);
        vc.isMyFlipcast = [sender objectForKey:@"isMyFlipcast"];
        
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
