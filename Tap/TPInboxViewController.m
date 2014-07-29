//
//  TPInboxViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#define FONTSIZE 18.0f
#define DEFAULT_FONT [UIFont fontWithName:@"HelveticaNeue-Medium" size:FONTSIZE]

#import "TPInboxViewController.h"
#import "TPSingleTapViewController.h"
#import "TPAppDelegate.h"
#import "TPViewCell.h"
#import "TPCameraViewController.h"
#import "CustomBadge.h"
#import <QuartzCore/QuartzCore.h>

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
@property (strong, nonatomic) NSMutableArray *loadedTapsByBatchId;

@property (strong, nonatomic) NSMutableArray *preLoadedTapsByIndexPaths;

@property (strong, nonatomic) UITableViewCell *cellToRemove;
@property (strong, nonatomic) CustomBadge *customBadge;

@property (strong, nonatomic) NSMutableDictionary *additionalInformationForSenderId;
@property (strong, nonatomic) NSMutableDictionary *additionalInformationForBatchId;

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


-(NSMutableArray *)loadedTapsByBatchId {
    if (!_loadedTapsByBatchId) {
        _loadedTapsByBatchId = [[NSMutableArray alloc] init];
    }
    return _loadedTapsByBatchId;
}


-(NSMutableArray *)preLoadedTapsByIndexPaths {
    if (!_preLoadedTapsByIndexPaths) {
        _preLoadedTapsByIndexPaths = [[NSMutableArray alloc] init];
    }
    return _preLoadedTapsByIndexPaths;
}

-(NSMutableArray *)allTapsArray {
    if (!_allTapsArray) {
        _allTapsArray = [[NSMutableArray alloc] init];
    }
    return _allTapsArray;
}


-(NSMutableDictionary *)additionalInformationForBatchId {
    if (!_additionalInformationForBatchId) {
        _additionalInformationForBatchId = [[NSMutableDictionary alloc] init];
    }
    return _additionalInformationForBatchId;
}

-(NSMutableDictionary *)additionalInformationForSenderId {
    if (!_additionalInformationForSenderId) {
        _additionalInformationForSenderId = [[NSMutableDictionary alloc] init];
    }
    return _additionalInformationForSenderId;
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
        
        self.loadingViewEnabled = NO;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        self.objectsPerPage = 100;
        
        
    }
    return self;
}

-(void)loadedForFirstTime {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"This is your inbox" message:@"Here you'll find your casts and your friends'. Casts live for 24 hours and can only be viewed once. Have fun 😎" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK!", nil];
    [alert show];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasOpenedInbox"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = @[@"ME", @"FRIENDS"];
    if (DEBUG) NSLog(@"Inbox view did load");
//    self.loadedTapsByIndexPaths = nil;
    [self registerForNotifications];
//    [self setTapLogo];
    [self setNavbarIcon];
    [self setupNavBarStyle];
    
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasOpenedInbox"]) {
            [self loadedForFirstTime];
        }
//    self.selectedInteraction =[[PFObject alloc] initWithClassName:@"Interaction"];
//    if (DEBUG) NSLog(@"selected interaction %@", self.selectedInteraction);
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
        if (DEBUG) NSLog(@"set navbar exception: %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkGray34"]];
    
    // Background color
    if (section == 0) {
//        view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hypemGreen"]];
    } else {
//        view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    }
//    //    view.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
//    view.tintColor = [UIColor whiteColor];
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
    [header.textLabel setTextColor:[UIColor whiteColor]];
    [header.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f]];
    
}


-(void) setupNavBarStyle {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"lightGray"];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"newPurple"] forBarMetrics:UIBarMetricsDefault];

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
    if (DEBUG) NSLog(@"View disappeared");
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkUserSituation];
    [TPAppDelegate sendMixpanelEvent:@"Opened inbox"];
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
    if (DEBUG) NSLog(@"handle new taps");
//    [self queryForTable];
//    self.view ref
//    [self.tableView reloadData];
//    [self viewDidLoad];
}

-(void)didDismissSingleTapView:(NSNotification *)notification {
    if (DEBUG) NSLog(@"Dismissed single tap view %@", notification.object);
    
    @try {
        

        
        TPViewCell *cell = (TPViewCell*)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)notification.object];

        cell.userInteractionEnabled = NO;
        
        [self.allTapsImages removeObjectForKey:[self.selectedBroadcast objectId]];
        
        [self.additionalInformationForSenderId removeObjectForKey:[[self.selectedBroadcast objectForKey:@"owner" ] objectId]];
        
        [self initCell:cell];
        [self cellHasNoTaps:cell withObject:self.selectedBroadcast];
        
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        if (DEBUG) NSLog(@"Exceptions : %@", exception);
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
    if (DEBUG) NSLog(@"querying my broadcasts");

    PFQuery *myFlipcasts = [PFQuery queryWithClassName:@"Flipcast"];
    
    if (DEBUG) NSLog (@"my flipcasts has cached results %d",[myFlipcasts hasCachedResult]);
    
    [myFlipcasts whereKey:@"owner" equalTo:[PFUser currentUser]];
    
    if ([self.myFlipcasts count] == 0)
        myFlipcasts.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [myFlipcasts orderByDescending:@"createdAt"];
    [myFlipcasts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (DEBUG) NSLog(@"self.myflip count %lu == objects count %lx", (unsigned long)[self.myFlipcasts count], (unsigned long)[objects count]);
        if (DEBUG) NSLog(@"[self.myFlipcasts count] != [objects count] ---- %d", [self.myFlipcasts count] != [objects count]);
        if ([self.myFlipcasts count] != [objects count]) {
            self.myFlipcasts = [objects mutableCopy];
            if (DEBUG) NSLog(@"shouldSkipFetchingMyFlips = NO");
            shouldSkipFetchingMyFlips = NO;
        } else {
            if (DEBUG) NSLog(@"shouldSkipFetchingMyFlips = YES");
            shouldSkipFetchingMyFlips = YES;
        }
//        [self viewDidLoad];
        [self getThumbnailAndAdditionalDataForMyPopcasts];
//        [self.tableView reloadData];
    }];
}

-(void)objectsWillLoad {
    [super objectsWillLoad];
    [self queryMyFlipcasts];
    
}

-(void) objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    if (DEBUG) NSLog(@"self.objects count %ld", (unsigned long)[self.objects count]);
    if (DEBUG) NSLog(@"self.mybroadcasts count %ld", (unsigned long)[self.myFlipcasts count]);
    [self getThumbnailAndAdditionalDataForAllObjects];

}

-(void)getThumbnailAndAdditionalDataForMyPopcasts {
    if (DEBUG) NSLog(@"getThumbnailAndAdditionalDataForMyPopcasts");
    
    if (!self.myFlipcasts) {
        if (DEBUG) NSLog(@"No flipcasts");
        return;
    } else {
        if (DEBUG) NSLog(@"Got flipcasts");
    }
    
    NSMutableArray *batchIds = [[NSMutableArray alloc] init];
    
    for (PFObject *popcast in self.myFlipcasts) {
        NSString *batchId = [popcast objectForKey:@"batchId"];
        [batchIds addObject:batchId];
    }
    
    PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
    [tapsQuery whereKey:@"batchId" containedIn:batchIds];
//    if (DEBUG) NSLog(@"batchId contained in %@",batchIds);
    [tapsQuery whereKey:@"imageId" equalTo:@(1)];
    [tapsQuery orderByAscending:@"createdAt"];
    [tapsQuery whereKey:@"senderId" equalTo:[[PFUser currentUser] objectId]];
    [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (DEBUG) NSLog(@"got first ones in my flipcasts. Number of first ones: %ld", [objects count]);
            for (PFObject *message in objects) {
                if (DEBUG) NSLog(@"This is a first with batchId %@", [message objectForKey:@"batchId"]);


                NSString *batchId = [message objectForKey:@"batchId"];
                
                if (![self.additionalInformationForBatchId objectForKey:batchId]) {
                    if (DEBUG) NSLog(@"Adding first one with batchId %@",batchId);
                    [self.additionalInformationForBatchId setObject:message forKey: batchId];
                    [self.tableView reloadData];
                } else {
                    if (DEBUG) NSLog(@"Already got first one with batchId %@",batchId);
                }
                
            }
        } else {
            if (DEBUG) NSLog(@"Error getting the first ones %@", error);
        }
    }];
    
}

-(void)getThumbnailAndAdditionalDataForAllObjects {
    
    if (DEBUG) NSLog(@"getThumbnailAndAdditionalDataForAllObjects");
    
    if (!self.objects) {
        if (DEBUG) NSLog(@"No objects");
        return;
    } else {
        if (DEBUG) NSLog(@"Got objects");
    }
    
    NSMutableArray *sendingUsersIds = [[NSMutableArray alloc] init];
    NSMutableArray *batchIds = [[NSMutableArray alloc] init];

    for (PFObject *broadcast in self.objects) {
        [sendingUsersIds addObject:[[broadcast objectForKey:@"owner"] objectId]];
        NSArray *batchIdsArray = [broadcast objectForKey:@"batchIds"];
        for (NSString *batchId in batchIdsArray) {
            [batchIds addObject:batchId];
        }
    }
    
    PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];

    [tapsQuery whereKey:@"batchId" containedIn:batchIds];
//    if (DEBUG) NSLog(@"batchId contained in %@",batchIds);
    [tapsQuery whereKey:@"imageId" equalTo:@(1)];
    [tapsQuery orderByAscending:@"createdAt"];
    [tapsQuery whereKey:@"senderId" containedIn:sendingUsersIds];
//    if (DEBUG) NSLog(@"senderId contained in %@",sendingUsersIds);
    [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
    [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
    
    [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (DEBUG) NSLog(@"got first ones. Number of first ones: %ld", [objects count]);
            for (PFObject *message in objects) {
                if (DEBUG) NSLog(@"This is a first one  by %@", [message objectForKey:@"sender"]);
                NSString *senderId = [[message objectForKey:@"sender"] objectId];
                
                if (![self.additionalInformationForSenderId objectForKey:senderId]) {
                    if (DEBUG) NSLog(@"Adding first one from %@",senderId);
                    [self.additionalInformationForSenderId setObject:message forKey: senderId];
                    [self.tableView reloadData];
                } else {
                    if (DEBUG) NSLog(@"Already got first one from %@",senderId);
                }

            }
        } else {
            if (DEBUG) NSLog(@"Error getting the first ones %@", error);
        }
    }];
}


- (PFQuery *)queryForTable {

    if (![PFUser currentUser] || ![PFUser currentUser].isAuthenticated) {
        [self checkUserSituation];
        return nil;
    }
    
    self.loadedTapsByIndexPaths = nil;
    self.preLoadedTapsByIndexPaths = nil;
    
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

-(void)initCell:(TPViewCell *)cell {
    if ([cell.hasNewTaps boolValue]) return;
    cell.hasNewTaps = @(NO);
    cell.textLabel.font = DEFAULT_FONT;
    cell.detailTextLabel.text = @"Loading...";
//    if (![self.loadedTapsByIndexPaths containsObject:indexPath])
    UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
    thumb.layer.cornerRadius = 5;
    thumb.layer.masksToBounds = YES;
    [thumb setHidden:YES];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    [ind startAnimating];
    [ind setHidden:NO];

    
}


-(void)cellHasNoTaps:(TPViewCell *)cell withObject:(PFObject *)object{
    if (DEBUG) NSLog(@"This is cellHasNoTaps");
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = DEFAULT_FONT;
//    @try {
//
//            NSDate *created = [object updatedAt];
//            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//            [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
//            NSString *latestStatus = [object objectForKey:@"latestStatus"];
//            NSString *detailString = @"";
//            if (latestStatus != nil && ![latestStatus isEqualToString:@""]) {
//                detailString = [NSString stringWithFormat:@"%@ ago - %@",
//                                          [self dateDiff:[dateFormat stringFromDate:created]], [object objectForKey:@"latestStatus"]];
//                
//            }
//            cell.detailTextLabel.text = detailString;
//
//    }
//    @catch (NSException *exception) {
//        cell.detailTextLabel.text = @"";
//        if (DEBUG) NSLog(@"latest status exception %@", exception);
//    }
    cell.detailTextLabel.text = @"";

    [[cell viewWithTag:516] setHidden:YES];
    cell.backgroundColor = [UIColor whiteColor];
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    [ind stopAnimating];
    [ind setHidden:YES];
}


-(TPViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPViewCell *cell;
    PFObject *object;

    // init thumbnail and indicator
    
    // init cells
    
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"sentTap" forIndexPath:indexPath];
        
        if (cell == nil)
        {
            cell = [[TPViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sentTap"];
            [self initCell:cell];
        }
        
        [self initializeSwipeableCell:cell];
        
//        if (![self.preLoadedTapsByIndexPaths containsObject:indexPath]
//            && ![self.loadedTapsByIndexPaths containsObject:indexPath]) {
//            [self initCell:cell];
//        }
        
        cell.myFlipcast = [NSNumber numberWithBool:YES];
        
        // object is class Flipcast
        object = [self.myFlipcasts objectAtIndex:indexPath.row];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recievedTap" forIndexPath:indexPath];
        
        if (cell == nil)
        {
            cell = [[TPViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"recievedTap"];
            [self initCell:cell];
            
        }
//        if (![self.preLoadedTapsByIndexPaths containsObject:indexPath]
//            && ![self.loadedTapsByIndexPaths containsObject:indexPath]) {
//            [self initCell:cell];
//        }
        
        // object is class Broadcast
        object = [self.objects objectAtIndex:indexPath.row];
    }
    
    
    
    NSDate *created = [object updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    
    NSString *agoString = [NSString stringWithFormat:@"%@ ago",
                           [self dateDiff:[dateFormat stringFromDate:created]]];
    
    
    cell.sendingUser = [object objectForKey:@"owner"];
    
    
    if (indexPath.section == 0) {
        // text label for my castsx

//        if (!shouldSkipFetchingMyFlips)
//            cell.textLabel.text = @"Loading...";
        
        NSString *batchId = [object objectForKey:@"batchId"];
        
        if ([self.additionalInformationForBatchId objectForKey:batchId] && ![self.loadedTapsByBatchId containsObject:batchId]) {
            [self initCellWithMyPopcast:cell withMessageObjects:[self.additionalInformationForBatchId objectForKey:batchId] andPopcast:object];
        }
        
    } else {
        // text label for friends' casts
        NSString *detailTextMessage;
        
        if ([object objectForKey:@"latestStatus"]) {
            NSString *status = [object objectForKey:@"latestStatus"];
            if (status.length > 19) {
                status = [[object objectForKey:@"latestStatus"] substringToIndex:19];
                status = [NSString stringWithFormat:@"%@...", status];
            }

            detailTextMessage = [NSString stringWithFormat:@"%@ - %@ ago",status,
                                 [self dateDiff:[dateFormat stringFromDate:created]]];
        } else {
            detailTextMessage = [NSString stringWithFormat:@"%@ ago - Tap to load",
                                         [self dateDiff:[dateFormat stringFromDate:created]]];
        }
        cell.detailTextLabel.text = detailTextMessage;
        NSString *senderId = [cell.sendingUser objectId];
        NSString *friendPhoneNumber = [[object objectForKey:@"owner"] objectForKey:@"phoneNumber"];
        NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber] ;
        NSString *username = [[object objectForKey:@"owner"] objectForKey:@"username"];
        cell.textLabel.text = (friendNameInMyContacts) ? friendNameInMyContacts : username;
        
        if ([self.additionalInformationForSenderId objectForKey:senderId]/* && [cell.hasNewTaps boolValue]*/) {
            [self initCellWithTaps:cell withMessageObjects:[self.additionalInformationForSenderId objectForKey:senderId]];
        } else {
            
            
            
            [self cellHasNoTaps:cell withObject:object];
        }
    }

    return cell;
}

-(void)initCellWithMyPopcast:(TPViewCell *)cell withMessageObjects:(PFObject *)message andPopcast:(PFObject *)popcast {
    
    if (DEBUG) NSLog(@"initCellWithMyPopcast");
    if (DEBUG) NSLog(@"loadedTapsByBatchId %@", self.loadedTapsByBatchId);
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:FONTSIZE];
    
    long viewsCount = [[popcast objectForKey:@"read"] count];
    
    NSDate *created = [message updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    
    if ([popcast objectForKey:@"firstCaption"]) {
        NSString *status =[popcast objectForKey:@"firstCaption"];
        if (status.length > 25) {
            status = [[popcast objectForKey:@"firstCaption"] substringToIndex:25];
            status = [NSString stringWithFormat:@"%@...", status];
        }
        if (DEBUG) NSLog(@"There is first caption %@", status);
        cell.textLabel.text = status;
    } else {
            cell.textLabel.text = @"Sent";
    }
    
    UILabel *viewsLabel = (UILabel *)[cell viewWithTag:555];
    viewsLabel.layer.cornerRadius = 20.0f;
    viewsLabel.layer.masksToBounds = YES;
    
    if (viewsCount > 0) {
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - %ld Views",[self dateDiff:[dateFormat stringFromDate:created]], viewsCount];

        [viewsLabel setHidden:NO];
        [[cell viewWithTag:234]setHidden:NO];
        viewsLabel.text = [NSString stringWithFormat:@"%ld",viewsCount];
        
    } else {
        [viewsLabel setHidden:YES];
        [[cell viewWithTag:234]setHidden:YES];
    }

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to view",[self dateDiff:[dateFormat stringFromDate:created]]];
    
    if ([self.loadedTapsByBatchId containsObject:[message objectForKey:@"batchId" ]]) {
        if (DEBUG) NSLog(@"Already loaded this batch!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to open",
//                                     [self dateDiff:[dateFormat stringFromDate:created]]];
        
        return;
    }
    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Loading...",
//                                 [self dateDiff:[dateFormat stringFromDate:created]]];
    
    UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
    thumb.layer.cornerRadius = 5;
    thumb.layer.masksToBounds = YES;
    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    
    PFFile *image = [message objectForKey:@"img"];
    NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   //                                   [self.thumbnailForIndexPaths setObject:data forKey:indexPath];
                                   
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   
                                   thumb.image = image;
                                   [thumb setHidden:NO];
//                                   
//                                   cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to load",
//                                                                [self dateDiff:[dateFormat stringFromDate:created]]];
                                   //                                   cell.detailTextLabel.text = @"Loading...";
                                   //                                   [self.preLoadedTapsByIndexPaths addObject:indexPath];
                                   //                                   //                                               if (indexPath.section == 0)
                                   //                                   cell.detailTextLabel.text = @"Tap to Open";//[NSString stringWithFormat:@"Tap to Open - %d taps", numOfTaps];
                                   
                                   cell.hasNewTaps = @(YES);
//                                   [ind stopAnimating];
                                   [ind setHidden:YES];
                               } else {
                                   if (DEBUG) NSLog(@"Error gettings image");
                               }
                           }];
}

-(void)initCellWithTaps:(TPViewCell *)cell withMessageObjects:(PFObject *)message {
    if (DEBUG) NSLog(@"This cell has message %@", cell);
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONTSIZE];
    NSDate *created = [message updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Loading...",
//                                 [self dateDiff:[dateFormat stringFromDate:created]]];
    NSString *detailTextMessage = nil;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFObject *broadcast = [self.objects objectAtIndex:indexPath.row];
    
    if ([message objectForKey:@"caption"]) {
        NSString *status = [message objectForKey:@"caption"];
        if (status.length > 22) {
            status = [[message objectForKey:@"caption"] substringToIndex:22];
            status = [NSString stringWithFormat:@"%@...", status];
        }
        
        detailTextMessage = [NSString stringWithFormat:@"%@ - %@ ago",status,
                             [self dateDiff:[dateFormat stringFromDate:created]]];
    } else {
        detailTextMessage = [NSString stringWithFormat:@"%@ ago - Tap to load",
                             [self dateDiff:[dateFormat stringFromDate:created]]];
    }

    
    cell.detailTextLabel.text = detailTextMessage;
    UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
    thumb.layer.cornerRadius = 5;
    thumb.layer.masksToBounds = YES;
    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    
    

    
    PFFile *image = [message objectForKey:@"img"];
    NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
//                                   [self.thumbnailForIndexPaths setObject:data forKey:indexPath];
                                   
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   
                                   thumb.image = image;

                                   [thumb setHidden:NO];

//                                   cell.detailTextLabel.text = @"Loading...";
//                                   [self.preLoadedTapsByIndexPaths addObject:indexPath];
//                                   //                                               if (indexPath.section == 0)
//                                   cell.detailTextLabel.text = @"Tap to Open";//[NSString stringWithFormat:@"Tap to Open - %d taps", numOfTaps];
                                   
                                   cell.hasNewTaps = @(YES);
//                                   [ind stopAnimating];
                                   [ind setHidden:YES];
                               } else {
                                   if (DEBUG) NSLog(@"Error gettings image");
                               }
                           }];
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
                                                      message:@"Choose action"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Edit title", @"Delete", nil];
    [message setTag:1];
    [message show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Delete"])
        {
            if (DEBUG) NSLog(@"Delete %@", self.flipcastToEdit);
            [self deleteFlipCast:self.flipcastToEdit];
        } else if ([title isEqualToString:@"Edit title"]) {
            [self editCastTitle:self.flipcastToEdit];
        }
    } else if (alertView.tag == 200) {
        // check not empty
        NSString *title =[alertView textFieldAtIndex:0].text;
        [self saveNewCastTitle:title forCast:self.flipcastToEdit];
    }
}

-(void)editCastTitle:(PFObject *)cast {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Change title"
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Save", nil];
    
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtF = [message textFieldAtIndex:0];
    txtF.placeholder = @"Type title here...";
    txtF.text = [cast objectForKey:@"firstCaption"];
    //    [txtF setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    [txtF setClearButtonMode:UITextFieldViewModeAlways];
    [message setTag:200];
    [message show];
}

-(void)saveNewCastTitle:(NSString *)title forCast:(PFObject *)cast {
    if (DEBUG) NSLog(@"This is the new title %@ for this cast %@", title, cast);
    if (title) {
        [cast setObject:title forKey:@"firstCaption"];
        [cast saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if (DEBUG) NSLog(@"Succesfully changed title");
                [self.tableView reloadData];
            }
        }];
    }
    
    
    // show hud
}



-(void)deleteFlipCast:(PFObject *)flipcast {
    NSString *batchId = [flipcast objectForKey:@"batchId"];
    PFQuery *mybroadcast = [PFQuery queryWithClassName:@"Broadcast"];
    [mybroadcast whereKey:@"owner" equalTo:[PFUser currentUser]];
    [mybroadcast getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSMutableArray *batchIds = [object objectForKey:@"batchIds"];
            if ([batchIds containsObject:batchId]) {
                if (DEBUG) NSLog(@"found batchId %@ in batchIds", batchId);
                [batchIds removeObject:batchId];
                [object setObject:batchIds forKey:@"batchIds"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        
//                        [self.cellToRemove removeFromSuperview];
                        [self.myFlipcasts removeObject:flipcast];
                        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:self.cellToRemove]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                        [self.tableView reloadData];
                        
                        if (DEBUG) NSLog(@"Successfuly removed batchId");
                    } else {
                        if (DEBUG) NSLog(@"Error removing batchId: %@", error);
                    }
                }];
            }
        } else {
            if (DEBUG) NSLog(@"Error getting broadcast: %@", error);
        }
    }];
    [flipcast deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (DEBUG) NSLog(@"Removed this cast");
        } else {
            if (DEBUG) NSLog(@"Error deleting cast: %@", error);
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
    if (![PFUser currentUser].isAuthenticated) {
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"targetUser" equalTo:[PFUser currentUser] ];
    
//    if (DEBUG) NSLog(@"Friends phone numbers array %@", self.appDelegate.friendsPhoneNumbersArray);
    [query whereKey:@"requestingUserPhoneNumber" notContainedIn:self.appDelegate.friendsPhoneNumbersArray];
    [query whereKey:@"status" equalTo:@"pending"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (DEBUG) NSLog(@"counted friend requests %d", number);
        self.appDelegate.pendingFriendRequests = @(number);
        [self initFriendRequestsBadge];
    }];
}

-(void)initFriendRequestsBadge {
    if (DEBUG) NSLog(@"initFriendRequestsBadge");
    
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
        if (DEBUG) NSLog(@"No user on inbox");
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)showFriends:(id)sender {
    [self.customBadge removeFromSuperview];
    [self performSegueWithIdentifier:@"showFriends" sender:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TPViewCell *cell = (TPViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    
    if (DEBUG) NSLog(@"Cell.hasNewTaps %x", [cell.hasNewTaps boolValue]);
    
    if (![cell.hasNewTaps boolValue]) {
        if (DEBUG) NSLog(@"Doesn't have new taps");
        return;
    }
    
    if (![self.loadedTapsByIndexPaths containsObject:indexPath]) {
        if (DEBUG) NSLog(@"Loaded taps doesn't contain this one: %@", indexPath);
//        cell.detailTextLabel.text = @"Loading...";
//        UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
//        [ind startAnimating];
//        [ind setHidden:NO];
        
        [self loadImagesForIndexPath:indexPath];
        return;
    } else {
        if (DEBUG) NSLog(@"[self.loadedTapsByIndexPaths containsObject:indexPath]");
    }
    
    BOOL isMyFlipcast;
    
    if (indexPath.section == 0) {
        [TPAppDelegate sendMixpanelEvent:@"Opened own popcast"];
        self.selectedBroadcast =[self.myFlipcasts objectAtIndex:indexPath.row];
        isMyFlipcast = YES;
    } else {
        [TPAppDelegate sendMixpanelEvent:@"Opened popcast"];
        self.selectedBroadcast =[self.objects objectAtIndex:indexPath.row];
        isMyFlipcast = NO;
    }
    
    NSMutableArray *batchTaps = [self.allTaps objectForKey:[self.selectedBroadcast objectId]];
//    NSMutableArray *batchTapsImages = [self.allTapsImages objectForKey:[self.selectedInteraction objectId]];
    NSMutableDictionary *allInteractionTaps =[self.allTapsImages objectForKey:[self.selectedBroadcast objectId]];
    

    
//    if (DEBUG) NSLog(@"self.allTapsImages %@", self.allTapsImages);
    if (DEBUG) NSLog(@"[self.selectedBroadcast objectId] %@", [self.selectedBroadcast objectId]);
    
    UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
    [tapsCounter setHidden:YES];
    

    if (([batchTaps count] == 0 || !allInteractionTaps) && !isMyFlipcast) {
        if (DEBUG) NSLog(@"Batch taps is 0 or no interactionsTaps");
        if (DEBUG) NSLog(@"BatchTaps %@", batchTaps);
        if (DEBUG) NSLog(@"allInteractionTaps %@", allInteractionTaps);

//        PFUser *userToReply = cell.sendingUser;
//        [self performSegueWithIdentifier:@"showCamera" sender:userToReply];
////        [self goToCamera:self];
        
    } else {
        NSSortDescriptor *imageIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageId" ascending:YES];
        NSArray *sortDescriptors = @[imageIdDescriptor];
        
//        NSArray *sortedImagesArray = [batchTapsImages sortedArrayUsingDescriptors:sortDescriptors];
        NSArray *sortedTapsArray = [batchTaps sortedArrayUsingDescriptors:sortDescriptors];
        
//        if (DEBUG) NSLog(@"batch images array %@", batchTapsImages);
//        if (DEBUG) NSLog(@"sorted batch images array %@", sortedImagesArray);
//        if (DEBUG) NSLog(@"batch taps %@", batchTaps);
        
//        if (cell.justVisited) {
//            if (DEBUG) NSLog(@"tapped on the one visited");
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
                    if (DEBUG) NSLog(@"First tap %@", [tap objectForKey:@"imageId"]);
                    [allTapsDict setObject:[[NSMutableArray alloc] initWithObjects:tap, nil] forKey:tapBatchId];
                } else {
                    if (![[allTapsDict objectForKey:tapBatchId] containsObject:tap]) {
                        if (DEBUG) NSLog(@"adding this %@", [tap objectForKey:@"imageId"]);
                        [[allTapsDict objectForKey:tapBatchId] addObject:tap];
                    } else {
                        if (DEBUG) NSLog(@"aleady contains this tap %@", [tap objectForKey:@"imageId"]);
                    }
                }
            }
        }

        if (isMyFlipcast) {
         if (DEBUG) NSLog(@"It is my flipcast");
        } else {
            [[cell viewWithTag:516] setHidden:YES];
            [self cellHasNoTaps:cell withObject:self.selectedBroadcast];
//            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:FONTSIZE];

        }
        
        if (allTapsDict == nil) allTapsDict = [[NSMutableDictionary alloc] init];
        if (sortedTapsArray == nil) sortedTapsArray = [[NSMutableArray alloc] init];
        if (allFlipcastsArray == nil) allFlipcastsArray = [[NSMutableArray alloc] init];
        if (indexPath == nil) indexPath = [[NSIndexPath alloc] init];
        
        NSDictionary *senderObject = @{@"allInteractionTaps" :allTapsDict, @"allTapObjects": sortedTapsArray, @"isMyFlipcast":@(isMyFlipcast), @"allFlipcastsArray": allFlipcastsArray, @"indexPath":indexPath};
        
        cell.backgroundColor = [UIColor whiteColor];
//        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:FONTSIZE];
//       cell.hasNewTaps = @(NO);
        [self performSegueWithIdentifier:@"showTap" sender:senderObject];
        
    }
}

-(void)loadImagesForIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) NSLog(@"loadImagesForIndexPath %@", indexPath);
    
    TPViewCell *cell = (TPViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    [ind startAnimating];
    [ind setHidden:NO];
    
    cell.userInteractionEnabled = NO;
    
    if (indexPath.section == 0) {
//        static NSString *CellIdentifier = @"sentTap";
        
        if (DEBUG) NSLog(@"Section is 0: My Taps");
        
        PFObject *flipcast = [self.myFlipcasts objectAtIndex:indexPath.row];
        
        NSString *batchId = [flipcast objectForKey:@"batchId"];
        
        NSDate *created = [flipcast updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Loading...",
                                     [self dateDiff:[dateFormat stringFromDate:created]]];
        cell.userInteractionEnabled = NO;
//        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:FONTSIZE];
//        cell.textLabel.text = [NSString stringWithFormat:@"%@ ago",
//                               [self dateDiff:[dateFormat stringFromDate:created]]];
        
        cell.sendingUser = [flipcast objectForKey:@"owner"];
        
        cell.myFlipcast = [NSNumber numberWithBool:YES];
        
        PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
        
        if ([self.myFlipcasts count] == 0)
            tapsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        
        NSString *broadcastId = [flipcast objectId];
        
        UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
        UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];
        if (DEBUG) NSLog(@"My Flipcasts count %ld", (unsigned long)[self.myFlipcasts count]);
        
        [tapsQuery whereKey:@"batchId" equalTo:[flipcast objectForKey:@"batchId"]];
        [tapsQuery orderByAscending:@"batchId"];
        [tapsQuery whereKey:@"privacy" equalTo:@"public"];
        [tapsQuery whereKey:@"sender" equalTo:cell.sendingUser];
        [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
        [tapsQuery whereKey:@"objectId" notContainedIn:self.appDelegate.allReadTaps];
        [tapsQuery setLimit:1000];
        [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([objects count] > 0) {
//                    cell.detailTextLabel.text = @"Loading...";
//                    
//                    if (DEBUG) NSLog(@"Number of objects %ld", (unsigned long)[objects count]);
//                    cell.userInteractionEnabled = NO;
//                    [tapsCounter setHidden: YES];
//                    [ind startAnimating];
//                    [ind setHidden:NO];
                } else {
                    if (DEBUG) NSLog(@"No Objects");
                }
                
                [self.allTaps setObject:objects forKey:broadcastId];
                
                NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];
                NSMutableDictionary *allPhotosInBatchDict = [[NSMutableDictionary alloc] init];
                
                __block int iterations = 0;
                
                for (PFObject *tap in objects) {
                    PFFile *image = [tap objectForKey:@"img"];
                    NSString *imageId = [tap objectForKey:@"imageId"];
                    NSString *batchId = [tap objectForKey:@"batchId"];
                    NSString *caption = [tap objectForKey:@"caption"];
                    if (caption == nil) caption = @"";
                    
                    
                    NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                    [NSURLConnection sendAsynchronousRequest:request
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               if ( !error )
                                               {
                                                   //                                                    if (DEBUG) NSLog(@"Start fetching photos");
                                                   //                                                    if (DEBUG) NSLog(@"read array %@", [tap objectForKey:@"readArray"]);
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
                                                   
                                                   [allPhotosInBatch addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId, @"caption": caption }];
                                                   id objectToAdd = @{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId, @"caption": caption};
                                                   
                                                   if (![self.allTapsArray containsObject:objectToAdd]){
                                                       [self.allTapsArray addObject:objectToAdd];
                                                   }
                                                   
                                                   
                                                   if (DEBUG) NSLog(@"%d iterations out of %ld objects", iterations, (unsigned long)[objects count]);
                                                   
                                                   iterations++;
                                                   if (iterations == [objects count]) {
                                                       
                                                       // setting the thumbnail
                                                       [thumb setAlpha:0.9];
                                                       long viewsCount = [[flipcast objectForKey:@"read"] count];
                                                       
//                                                       cell.detailTextLabel.text = @"Tap to view";
//                                                       if (viewsCount > 0) {
//                                                           
//                                                           cell.detailTextLabel.text = (viewsCount == 1) ? [NSString stringWithFormat:@"Tap to View - %ld view", viewsCount] : [NSString stringWithFormat:@"Tap to Open - %ld views", viewsCount];
//                                                           
//                                                       } else {
                                                           cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to view",[self dateDiff:[dateFormat stringFromDate:created]]];
//                                                       }

//                                                       thumb.layer.cornerRadius = 5;
                                                       //                                                        [self.allTapsImages setObject:allPhotosInBatchDict forKey:batchId];
                                                       
                                                       [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                      
                                                       if (DEBUG) NSLog(@"All taps images set object %@", broadcastId);
                                                       
                                                       [allPhotosInBatchDict setObject: allPhotosInBatch forKey:batchId];
                                                       //                                                        if (DEBUG) NSLog(@"all photos in batch %@", allPhotosInBatch);
                                                       //  [self.allTapsImages setValue:allPhotosInBatch forKey:batchId];
                                                       //   if (DEBUG) NSLog(@"All taps images %@", self.allTapsImages);
//                                                       [ind stopAnimating];
                                                       [ind setHidden:YES];
                                                       
                                                       cell.userInteractionEnabled = YES;
                                                       
                                                       if (DEBUG) NSLog(@"loadedTapsByIndexPaths add object %@", indexPath);
                                                       if (![self.loadedTapsByIndexPaths containsObject:indexPath])
                                                           [self.loadedTapsByIndexPaths addObject:indexPath];
                                                       
                                                       if (![self.loadedTapsByBatchId containsObject:batchId]) {
                                                           [self.loadedTapsByBatchId addObject:batchId];
                                                       }
                                                       
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
//                    [ind stopAnimating];
                    [ind setHidden:YES];
                    [tapsCounter setHidden:YES];
                    [thumb setHidden:YES];
                }
                
                
            } else {
                if (DEBUG) NSLog(@"Error: %@", error);
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
        
        if (DEBUG) NSLog(@"username %@", username);
        if (DEBUG) NSLog(@"name %@", friendNameInMyContacts);
        
        cell.sendingUser = [object objectForKey:@"owner"];
        
        cell.textLabel.text = (friendNameInMyContacts) ? friendNameInMyContacts : username  ;
        

        
        NSDate *created = [object updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Loading...",
                                     [self dateDiff:[dateFormat stringFromDate:created]]];

        if (!cell.hasNewTaps || ![self.loadedTapsByIndexPaths containsObject:indexPath])
            cell.backgroundColor = [UIColor whiteColor];
        
        @try {
            if ([self.selectedBroadcast isKindOfClass:[PFObject class]]) {
                if ([[object updatedAt] isEqual:[self.selectedBroadcast updatedAt]]) {
                    if (DEBUG) NSLog(@"not reloading the one just watched");
                    //                 cell.justVisited = [NSNumber numberWithBool:YES];
                    //                 return cell;
                } else {
                    //                 cell.justVisited = [NSNumber numberWithBool:NO];
                }
            }
        }
        @catch (NSException *exception) {
            if (DEBUG) NSLog(@"Exception: %@", exception);
        }
        
        
        
        NSString *broadcastId = [object objectId];
        
        UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
        UIImageView *thumb = (UIImageView *)[cell viewWithTag:516];

        
        thumb.layer.cornerRadius = 5;
        thumb.layer.masksToBounds = YES;
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
                    if (DEBUG) NSLog(@"Number of objects %ld", (unsigned long)[objects count]);

//                    [tapsCounter setHidden: YES];
//                    [ind setHidden:NO];
//                    [ind startAnimating];
                } else {
//                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:FONTSIZE];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - no new taps",
                                                 [self dateDiff:[dateFormat stringFromDate:created]]];/*, (unsigned long)[objects count]*/
                }
                
                //            if (DEBUG) NSLog(@"Found %ld objects", [objects count]);
                [self.allTaps setObject:objects forKey:broadcastId];
                
                NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];
                NSMutableDictionary *allPhotosInBatchDict = [[NSMutableDictionary alloc] init];
                
                __block int iterations = 0;
                
                if (DEBUG) NSLog(@"Gonna load taps");
                for (PFObject *tap in objects) {
                    
                    PFFile *image = [tap objectForKey:@"img"];
                    NSString *imageId = [tap objectForKey:@"imageId"];
                    NSString *batchId = [tap objectForKey:@"batchId"];
                    NSString *caption = @"";
                    @try {
                        if ([tap objectForKey:@"caption"])
                            caption = [tap objectForKey:@"caption"];
                    }
                    @catch (NSException *exception) {
                        if (DEBUG) NSLog(@"Coundlt get caption for this message exception: %@", exception);
                    }


                    NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                    [NSURLConnection sendAsynchronousRequest:request
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               if ( !error )
                                               {
                                                   //                                                   if (DEBUG) NSLog(@"Start fetching photos");
//                                                   cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:FONTSIZE];
                                                   
                                                   [ind setHidden:NO];
                                                   [ind startAnimating];
                                                   
                                                   [ind hidesWhenStopped];
//                                                   UIImage *image = [[UIImage alloc] initWithData:data];
//                                                   if (iterations == 0) {
//                                                       thumb.image = image;
//                                                   }
                                                   
                                                   if (DEBUG) NSLog(@"This is the caption %@", caption);
                                                   
                                                   [allPhotosInBatch addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId, @"caption":caption}];
                                                   
                                                   [self.allTapsArray addObject:@{@"imageData": data, @"imageId": imageId, @"batchId": batchId , @"broadcastId":broadcastId, @"caption":caption}];
                                                   
//                                                   id objectToAdd = @{@"imageData": data, @"imageId": imageId, @"batchId": batchId, @"broadcastId":broadcastId, @"caption": caption};
//                                                   
//                                                   [allPhotosInBatch addObject:objectToAdd];
//                                                   [self.allTapsArray addObject:objectToAdd];
                                                   
                                                if (DEBUG) NSLog(@"%d iterations out of %ld objects", iterations, (unsigned long)[objects count]);
                                                   
                                                   iterations++;
                                                   
                                                   if (iterations == [objects count]) {
                                                       
                                                       // setting the thumbnail
                                                       
                                                       [thumb setAlpha:0.9];
                                                       if (DEBUG) NSLog(@"All taps images set object %@", broadcastId);
                                                       [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                       [allPhotosInBatchDict setObject: allPhotosInBatch forKey:[tap objectForKey:@"batchId"]];
                                                       cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to view",
                                                                                    [self dateDiff:[dateFormat stringFromDate:created]]];
                                                       [ind setHidden:YES];
                                                       cell.userInteractionEnabled = YES;

                                                       [self.loadedTapsByIndexPaths addObject:indexPath];
                                                       
                                                       
                                                       tapsCounter.text = [NSString stringWithFormat:@"%ld",(unsigned long)[objects count] ];
                                                       
                                                       [thumb setHidden:NO];
                                                   }
                                                   //
                                               } else{
                                                   //
                                                   if (DEBUG) NSLog(@"There was an error getting photo: %@", error);
                                                   //                                                   completionBlock(NO,nil);
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
//                    [ind stopAnimating];
                    [ind setHidden:YES];
                    [tapsCounter setHidden:YES];
                    [thumb setHidden:YES];
                }
                
            } else {
                if (DEBUG) NSLog(@"Error: %@", error);
            }
        }];
        cell.userInteractionEnabled = YES;
        return;
    }

}

- (IBAction)goToCamera:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.customBadge removeFromSuperview];
    if ([segue.identifier isEqual:@"showTap"]) {
        if (DEBUG) NSLog(@"Performing segue show tap");
        
        TPSingleTapViewController *vc = (TPSingleTapViewController *)segue.destinationViewController;
//        vc.spray = self.selectedBroadcast;
        @try {
            vc.objects = [sender objectForKey:@"allTapObjects"];
            vc.allBatchImages = [sender objectForKey:@"batchImages"];
            
            vc.allFlipCasts = [sender objectForKey:@"allFlipcastsArray"];
            
            vc.allInteractionTaps = [sender objectForKey:@"allInteractionTaps"];
            
            vc.indexPath = [sender objectForKey:@"indexPath"];
            
            vc.sendingUser = [self.selectedBroadcast objectForKey:@"owner"];
            
//            vc.indexPath = i
            
            if (DEBUG) NSLog(@"sender is my flip %@", [sender objectForKey:@"isMyFlipcast"]);
            vc.isMyFlipcast = [sender objectForKey:@"isMyFlipcast"];

        }
        @catch (NSException *exception) {
            if (DEBUG) NSLog(@"Exception getting all tap properties: %@", exception);
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
