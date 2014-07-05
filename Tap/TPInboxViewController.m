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

@end

@implementation TPInboxViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"Message";
        
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



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section >= self.objects.count) {
//        // Load More Section
//        return 44.0f;
//    }
//    
//    return 280.0f;
//}

- (PFQuery *)queryForTable {

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query setLimit:0];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"sender"];
    return query;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
     static NSString *CellIdentifier = @"recievedTap";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
     cell.textLabel.text = [[object objectForKey:@"sender"] objectForKey:@"username"];
     
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self performSegueWithIdentifier:@"showTap" sender:[self.objects objectAtIndex:indexPath.row ]];
    
}

- (IBAction)goToCamera:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showTap"]) {
        TPSingleTapViewController *vc = (TPSingleTapViewController *)segue.destinationViewController;
        vc.objects = [[NSMutableArray alloc] initWithArray:@[sender]];
    }
}
@end
