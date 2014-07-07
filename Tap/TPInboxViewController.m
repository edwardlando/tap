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

@interface TPInboxViewController ()
- (IBAction)goToCamera:(id)sender;
@property (strong, nonatomic) NSMutableDictionary *allTaps;
@property (strong, nonatomic) PFObject *selectedSpray;
@property (strong, nonatomic) TPAppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary *allTapsImages;

@end

@implementation TPInboxViewController
- (TPAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (TPAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
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

-(PFObject *) selectedSpray {
    if (!_selectedSpray) {
        _selectedSpray = [[PFObject alloc] init];
    }
    return _selectedSpray;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"Spray";
        
        // The key of the PFObject to display in the label of the default cell style
        // self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
    [self setTapLogo];
    [self setupNavBarStyle];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

}

-(void) setupNavBarStyle {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@""];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"white"] forBarMetrics:UIBarMetricsDefault];
}

-(void) setTapLogo {
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabel setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    self.navigationItem.titleView = titleLabel;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.tapsCounterOutlet.frame = CGRectMake(self.tapsCounterOutlet.frame.origin.x, self.tapsCounterOutlet.frame.origin.y, 40, 40);
//    [self.tapsCounterOutlet setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pink"]]];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSingleTapView)
                                                 name:@"singleTapViewDismissed"
                                               object:nil];
}

-(void)didDismissSingleTapView {
    NSLog(@"Dismissed single tap view");
    [self.tableView reloadData];
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

    if (![PFUser currentUser]) {
        return nil;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    PFQuery *mySprays = [PFQuery queryWithClassName:self.parseClassName];
    
    [mySprays whereKey:@"sender" equalTo:[PFUser currentUser]];
    [mySprays whereKey:@"read" notEqualTo:[PFUser currentUser]];

    
    [query whereKey:@"recipients" equalTo:[PFUser currentUser]];
//    [query whereKey:@"read" notEqualTo:[PFUser currentUser]];
    // without user's own taps
    [query whereKey:@"sender" notEqualTo:[PFUser currentUser]];


    PFQuery *all = [PFQuery orQueryWithSubqueries:@[query, mySprays]];
    [all orderByDescending:@"createdAt"];
    [all includeKey:@"sender"];
    
    return all;
    
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
     static NSString *CellIdentifier = @"recievedTap";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIActivityIndicatorView *ind = (UIActivityIndicatorView *)[cell viewWithTag:5];
    [ind startAnimating];
    [ind hidesWhenStopped];
    
    NSString *friendPhoneNumber = [[object objectForKey:@"sender"] objectForKey:@"phoneNumber"];
     
    NSString *friendNameInMyContacts = [self.appDelegate.contactsDict objectForKey:friendPhoneNumber];
     
    NSString *username = [[object objectForKey:@"sender"] objectForKey:@"username"];
     cell.textLabel.text = (![friendNameInMyContacts isEqual:@""]) ? friendNameInMyContacts : username ;
    cell.detailTextLabel.textColor = [UIColor grayColor];


     
     PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
    [tapsQuery whereKey:@"batchId" equalTo:[object objectForKey:@"batchId"]];
    [tapsQuery orderByDescending:@"imageId"];
    [tapsQuery whereKey:@"recipients" equalTo:[PFUser currentUser]];
    [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];
    
    [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSString *batchId = [object objectForKey:@"batchId"];
//            NSLog(@"Found %ld objects", [objects count]);
            [self.allTaps setObject:objects forKey:batchId];
            
            if ([objects count] > 0) {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
                NSDate *created = [object createdAt];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
                

                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - tap to open",
                                             [self dateDiff:[dateFormat stringFromDate:created]]];
                
//                cell.detailTextLabel.text = [NSString stringWithFormat:@"2m ago - tap to open"/*, (unsigned long)[objects count]*/];

            } else {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"tap to reply directly"/*, (unsigned long)[objects count]*/];
            }
            UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];

            NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];

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

                                               UIImage *image = [[UIImage alloc] initWithData:data];
                                               [allPhotosInBatch addObject:@{@"image": image, @"imageId": [tap objectForKey:@"imageId"]}];
//                                               NSLog(@"allPhotosInBatch %@", allPhotosInBatch);
                                               
                                               if (iterations == [objects count] - 1) {
                                                   
                                                   NSLog(@"Done Looping with %d iterations %ld", iterations, (unsigned long)[objects count]);
                                                   
                                                   
                                                   [self.allTapsImages setObject:allPhotosInBatch forKey:batchId];
                                                   //                [self.allTapsImages setValue:allPhotosInBatch forKey:batchId];
//                                                   NSLog(@"All taps images %@", self.allTapsImages);
                                                   [ind stopAnimating];
                                                   [ind setHidden:YES];
                                                   tapsCounter.text = [NSString stringWithFormat:@"%ld",(unsigned long)[objects count] ];
                                                   [tapsCounter setHidden:NO];
                                               }
                                              iterations++;
                                               
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

                
                cell.backgroundColor = [UIColor whiteColor];
                [ind stopAnimating];
                [ind setHidden:YES];
                [tapsCounter setHidden:YES];
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.selectedSpray =[self.objects objectAtIndex:indexPath.row];
    NSMutableArray *batchTaps = [self.allTaps objectForKey:[self.selectedSpray objectForKey:@"batchId" ]];
    NSMutableArray *batchTapsImages = [self.allTapsImages objectForKey:[self.selectedSpray objectForKey:@"batchId"]];
    
//    NSLog(@"batch taps %@", batchTaps);
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
    [tapsCounter setHidden:YES];
    
    if ([batchTaps count] == 0) {
        [self goToCamera:self];
    } else {
        
        NSSortDescriptor *imageIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageId" ascending:NO];
        NSArray *sortDescriptors = @[imageIdDescriptor];
        NSArray *sortedImagesArray = [batchTapsImages sortedArrayUsingDescriptors:sortDescriptors];
        
//        NSLog(@"batch images array %@", batchTapsImages);
//        NSLog(@"sorted batch images array %@", sortedImagesArray);
//        NSLog(@"batch taps %@", batchTaps);
        
        NSDictionary *senderObject = @{@"batchImages" :sortedImagesArray, @"allTapObjects": batchTaps};
        [self performSegueWithIdentifier:@"showTap" sender:senderObject];
    }

}

- (IBAction)goToCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showTap"]) {
        TPSingleTapViewController *vc = (TPSingleTapViewController *)segue.destinationViewController;
        vc.spray = self.selectedSpray;
        vc.objects = [sender objectForKey:@"allTapObjects"];
        vc.allBatchImages = [sender objectForKey:@"batchImages"];
    }
}
@end
