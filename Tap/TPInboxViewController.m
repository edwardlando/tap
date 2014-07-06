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
//    [query setLimit:0];
    [query whereKey:@"recipients" equalTo:[PFUser currentUser]];
//    [query whereKey:@"read" notEqualTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"sender"];
    return query;
    
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
            [self.allTaps setObject:objects forKey:batchId];
            
            if ([objects count] > 0) {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"2m ago - tap to open"/*, (unsigned long)[objects count]*/];
            } else {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"2m ago - tap to reply"/*, (unsigned long)[objects count]*/];
            }
            UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];

            tapsCounter.frame = CGRectMake(tapsCounter.frame.origin.x, tapsCounter.frame.origin.y, 31 ,21 );
            NSMutableArray *allPhotosInBatch = [[NSMutableArray alloc] init];
            int iterations = 0;
            
            for (PFObject *tap in objects) {
//                self.allTapsImages
                iterations++;
                PFFile *image = [tap objectForKey:@"img"];
                NSLog(@"tap %@", tap);
                
                NSURL *tapImageUrl = [[NSURL alloc] initWithString:image.url];
                
                NSLog(@"tap image url %@", tapImageUrl);
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tapImageUrl];
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           if ( !error )
                                           {
                                               UIImage *image = [[UIImage alloc] initWithData:data];
                                               [allPhotosInBatch addObject:image];
                                               NSLog(@"git this pic %@", image);
//                                              completionBlock(YES,image);
                                           } else{
//                                               completionBlock(NO,nil);
                                           }
                                       }];
                
                if (iterations == [objects count]) {
                    NSLog(@"Done Looping");
                    
                    
                    [self.allTapsImages setObject:allPhotosInBatch forKey:batchId];
                    NSLog(@"All taps images %@", self.allTapsImages);
                    [ind stopAnimating];
                    [ind setHidden:YES];
                    tapsCounter.text = [NSString stringWithFormat:@"%ld",(unsigned long)[objects count]];
                }
            }
            
            

            
            tapsCounter.layer.cornerRadius = 5;
            tapsCounter.clipsToBounds = YES;
            
            if ([objects count] > 0) {
                [tapsCounter setHidden:NO];
            } else {
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

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.selectedSpray =[self.objects objectAtIndex:indexPath.row];
    NSMutableArray *batchTaps = [self.allTaps objectForKey:[self.selectedSpray objectForKey:@"batchId" ]];
    NSMutableArray *batchTapsImages = [self.allTapsImages objectForKey:[self.selectedSpray objectForKey:@"batchId" ]];
//    NSLog(@"batch taps %@", batchTaps);
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *tapsCounter = (UILabel *)[cell viewWithTag:11];
    [tapsCounter setHidden:YES];
    
    if ([batchTaps count] == 0) {
        [self goToCamera:self];
    } else {
        [self performSegueWithIdentifier:@"showTap" sender:@{@"batchImages" :batchTapsImages, @"allTapObjects": batchTaps}];
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
