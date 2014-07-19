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

@interface TPInboxViewController ()
- (IBAction)goToCamera:(id)sender;
@property (strong, nonatomic) NSMutableDictionary *allTaps;
@property (strong, nonatomic) PFObject *selectedInteraction;
@property (strong, nonatomic) PFObject *selectedBroadcast;

@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary *allTapsImages;
@property (strong, nonatomic) NSMutableArray *allTapsArray;

@end

@implementation TPInboxViewController
- (TPAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self countFriendRequests];
//    countFriendRequests
//    self.tapsCounterOutlet.frame = CGRectMake(self.tapsCounterOutlet.frame.origin.x, self.tapsCounterOutlet.frame.origin.y, 40, 40);
//    [self.tapsCounterOutlet setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]]];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSingleTapView)
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

-(void)didDismissSingleTapView {
    NSLog(@"Dismissed single tap view");
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.objects count];
}


- (PFQuery *)queryForTable {

    if (![PFUser currentUser] || ![PFUser currentUser].isAuthenticated) {
        return nil;
    }
    
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    PFQuery *friendsBroadcasts = [PFQuery queryWithClassName:self.parseClassName];

    [friendsBroadcasts whereKey:@"owner" containedIn:self.appDelegate.friendsArray];
    
//    NSLog(@"This is appdelegate friends array %@", self.appDelegate.friendsArray);
    
    PFQuery *all = [PFQuery orQueryWithSubqueries:@[/*query, */friendsBroadcasts]];
    [all orderByDescending:@"updatedAt"];
    [all includeKey:@"owner"];

    if ([self.objects count] == 0 ) {
        all.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    
    return all;
    
}

 - (TPViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
     static NSString *CellIdentifier = @"recievedTap";

     TPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];

   [ind setHidden:YES];
    
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
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - Tap to reply directy",
                                  [self dateDiff:[dateFormat stringFromDate:created]]];/*, (unsigned long)[objects count]*/
//     cell.userInteractionEnabled = YES;
     @try {
         if ([self.selectedBroadcast isKindOfClass:[PFObject class]]) {
//             NSLog(@"Selected interactions %@", self.selectedInteraction);

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
     @finally {
         
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
            }

//            NSLog(@"Found %ld objects", [objects count]);
            [self.allTaps setObject:objects forKey:broadcastId];
            
            NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];
            NSMutableDictionary *allPhotosInBatchDict = [[NSMutableDictionary alloc] init];
            
            __block int iterations = 0;
            
            for (PFObject *tap in objects) {
                PFFile *image = [tap objectForKey:@"img"];
                
                NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           if ( !error )
                                           {
                                               NSLog(@"Start fetching photos");
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
                                               [allPhotosInBatch addObject:@{@"image": image, @"imageId": [tap objectForKey:@"imageId"], @"batchId": [tap objectForKey:@"batchId"], @"broadcastId":broadcastId}];
                                               
                                               [self.allTapsArray addObject:@{@"image": image, @"imageId": [tap objectForKey:@"imageId"], @"batchId": [tap objectForKey:@"batchId"], @"broadcastId":broadcastId}];

                                                   NSLog(@"%d iterations out of %ld objects", iterations, (unsigned long)[objects count]);
                                               
                                             
                                              iterations++;
                                               if (iterations == [objects count]) {
                                                   
                                                   // setting the thumbnail

                                                   thumb.layer.cornerRadius = 5;
                                                   [self.allTapsImages setObject:allPhotosInBatchDict forKey:broadcastId];
                                                  [allPhotosInBatchDict setObject: allPhotosInBatch forKey:[tap objectForKey:@"batchId"]];
                                                   NSLog(@"all photos in batch %@", allPhotosInBatch);
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

    self.selectedBroadcast =[self.objects objectAtIndex:indexPath.row];
    
    NSMutableArray *batchTaps = [self.allTaps objectForKey:[self.selectedBroadcast objectId]];
//    NSMutableArray *batchTapsImages = [self.allTapsImages objectForKey:[self.selectedInteraction objectId]];
    
    NSMutableDictionary *allInteractionTaps =[self.allTapsImages objectForKey:[self.selectedBroadcast objectId]];
    
    
//    NSLog(@"batch taps %@", batchTaps);
    
    TPViewCell *cell = (TPViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
    [tapsCounter setHidden:YES];
    

    if ([batchTaps count] == 0 || !allInteractionTaps) {
        PFUser *userToReply = cell.sendingUser;
        [self performSegueWithIdentifier:@"showCamera" sender:userToReply];
//        [self goToCamera:self];
        
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
                    NSLog(@"First tap %@", tap);
                    [allTapsDict setObject:[[NSMutableArray alloc] initWithObjects:tap, nil] forKey:tapBatchId];
                } else {
                    if (![[allTapsDict objectForKey:tapBatchId] containsObject:tap]) {
                        NSLog(@"adding this %@", tap);
                        [[allTapsDict objectForKey:tapBatchId] addObject:tap];
                    } else {
                        NSLog(@"aleady contains this tap %@", tap);
                    }

                }
            }
        }

        
        
        NSDictionary *senderObject = @{@"allInteractionTaps" :allTapsDict, @"allTapObjects": sortedTapsArray};
        
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
        
        
    } else if ([segue.identifier isEqual:@"showCamera"]) {
        TPCameraViewController *vc = (TPCameraViewController *)segue.destinationViewController;
        vc.isReply = [NSNumber numberWithBool:YES];
        vc.directRecipient = sender;
    }
}
@end
