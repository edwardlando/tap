//
//  TPInboxViewController.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPInboxViewController.h"
#import "TPSingleTapViewController.h"

@interface TPInboxViewController ()
- (IBAction)goToCamera:(id)sender;
@property (strong, nonatomic) NSMutableDictionary *allTaps;

@end

@implementation TPInboxViewController


-(NSMutableArray *)allTaps {
    if (!_allTaps) {
        _allTaps = [[NSMutableDictionary alloc] init];
    }
    return _allTaps;
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
        self.objectsPerPage = 40;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [query setLimit:0];
    [query whereKey:@"recipients" equalTo:[PFUser currentUser]];
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
    cell.textLabel.text = [[object objectForKey:@"sender"] objectForKey:@"username"];
     
    PFQuery *tapsQuery = [[PFQuery alloc] initWithClassName:@"Message"];
    [tapsQuery whereKey:@"batchId" equalTo:[object objectForKey:@"batchId"]];
    [tapsQuery orderByDescending:@"imageId"];
    [tapsQuery whereKey:@"recipients" equalTo:[PFUser currentUser]];
    [tapsQuery whereKey:@"readArray" notEqualTo:[[PFUser currentUser] objectId]];

    [tapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.allTaps setObject:objects forKey:[object objectForKey:@"batchId"]];
            
            if ([objects count] > 0) {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu taps • TIMESTAMP", (unsigned long)[objects count]];
            [ind stopAnimating];
            [ind setHidden:YES];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSMutableArray *batchTaps = [self.allTaps objectForKey:[[self.objects objectAtIndex:indexPath.row] objectForKey:@"batchId" ]];
    NSLog(@"batch taps %@", batchTaps);
    if ([batchTaps count] == 0) {
        [self goToCamera:self];
    } else {
        [self performSegueWithIdentifier:@"showTap" sender:batchTaps];
    }

    
}

- (IBAction)goToCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showTap"]) {
        TPSingleTapViewController *vc = (TPSingleTapViewController *)segue.destinationViewController;
        vc.objects = sender;
    }
}
@end
