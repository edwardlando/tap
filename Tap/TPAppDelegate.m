//
//  TPAppDelegate.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#define MIXPANEL_TOKEN @"98677c640dfade631369fad2cc78bb66"
//#define DEBUG @(NO)

#import "TPAppDelegate.h"
#import <Parse/Parse.h>
#import <Mixpanel/Mixpanel.h>
#import "TPFriend.h"
#import "TPFriendObject.h"

@implementation TPAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


-(NSMutableArray *)friendsArray {
    if (!_friendsArray) {
        if (DEBUG) NSLog(@"No _friendsArray array");
        _friendsArray = [[NSMutableArray alloc] init];
        NSArray *allFriends = [self getAllFriendsFromCoreData];
//        if (DEBUG) NSLog(@"These are the friends from coredata %@", allFriends);
        for (TPFriend *friend in allFriends) {
            PFUser *newFriendObject = [PFUser objectWithoutDataWithObjectId:friend.parseUserId];
            newFriendObject[@"username"] = friend.username;
            newFriendObject[@"phoneNumber"] = friend.phoneNumber;
//            if (DEBUG) NSLog(@"Adding this guy to friendsArray %@", newFriendObject);
            [_friendsArray addObject:newFriendObject];
        }
    }
    return _friendsArray;
}

-(NSMutableArray *)friendsPhoneNumbersArray {
    if (!_friendsPhoneNumbersArray) {
        _friendsPhoneNumbersArray = [[NSMutableArray alloc] init];
        if (DEBUG) NSLog(@"No _friendsPhoneNumbersArray array");
        NSArray *allFriends = [self getAllFriendsFromCoreData];
//        if (DEBUG) NSLog(@"These are the friends from coredata friendsPhoneNumbersArray %@", allFriends);
        for (TPFriend *friend in allFriends) {
            NSString *phoneNumber = friend.phoneNumber;
            [_friendsPhoneNumbersArray addObject:phoneNumber];
        }
    }
    return _friendsPhoneNumbersArray;
}

- (void)loadFriends{
    if([PFUser currentUser].isAuthenticated){
        if (DEBUG) NSLog(@"Loading friends");
        NSArray *friendsArray = [[PFUser currentUser] objectForKey:@"friendsArray"];
        self.numbersToUsernamesDict = [[NSMutableDictionary alloc] init];
        self.friendsObjectsDict = [[NSMutableDictionary alloc] init];
        
        if ([friendsArray count] > 0) {
            if (DEBUG) NSLog(@"Friends array count > 0");
            for (PFUser *friend in friendsArray) {
                [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    [self.friendsObjectsDict setObject:object forKey:[object objectForKey:@"phoneNumber"]];

                    PFUser *newFriendObject = [PFUser objectWithoutDataWithObjectId:[friend objectId]];
                    newFriendObject[@"username"] = [friend objectForKey:@"username"];
                    newFriendObject[@"phoneNumber"] = [friend objectForKey:@"phoneNumber"];
                    
                    BOOL contained = NO;
                    
                    for (PFObject *fr in self.friendsArray) {
                        if ([[fr objectId] isEqualToString:[friend objectId]]) {
                            contained = YES;
                            break;
                        }
                    }
                    
                    if (![self.friendsArray containsObject:newFriendObject] && ![self.friendsArray containsObject:friend] && !contained) {
                        
                        if (DEBUG) NSLog(@"Adding friend to friendsArray appDelegate %@", [friend objectId]);
                        [self.friendsArray addObject:newFriendObject];
                        
                        if (DEBUG) NSLog(@"This is friendsArray now %ld", [self.friendsArray count]);
                        
                        
                        
                        if (![self checkIfFriendIsInDatabase:[self convertToTPFriendObject:friend]]) {
                            if (DEBUG) NSLog(@"Adding friend to coredata %@", [friend objectId]);
                            [self addFriendWithData:[self convertToTPFriendObject:friend]];
                        }
                    }
                    
                    if (![self.friendsPhoneNumbersArray containsObject:[object objectForKey:@"phoneNumber"]]) {
                        [self.friendsPhoneNumbersArray addObject:[object objectForKey:@"phoneNumber"]];
                        if (DEBUG) NSLog(@"added this friend's phone nubmer %@", [object objectForKey:@"phoneNumber"]);
                    }
                
                    if (![self.numbersToUsernamesDict objectForKey:[object objectForKey:@"username"]]) {
                        [self.numbersToUsernamesDict setObject:[object objectForKey:@"username"] forKey:[object objectForKey:@"phoneNumber"]];                        
                    }
                }];
            }
        }
    }
}

- (NSArray *)getAllFriendsFromCoreData
{
    if (DEBUG) NSLog(@"Getting all friends from core data");
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                              inManagedObjectContext:context];
    fetchRequest.entity = entity;
    
    NSError *error;
    NSArray *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    
    if (DEBUG) NSLog(@"This is how many friends in core data %ld", [fetchResults count]);
    return fetchResults;
}



-(void)checkIfActive {
//    PFQuery *query = [PFQuery queryWithClassName:@"Settings"];
//    [query whereKey:@"Number" equalTo:@"2"];
//    [query whereKey:@"Type" equalTo:@"active"];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (DEBUG) NSLog(@"object %d", [[object objectForKey:@"boolValue"] boolValue]);
//        if (!error) {
//            if ([[object objectForKey:@"boolValue"]boolValue]) {
//                if (DEBUG) NSLog(@"App is active");
//            } else {
//                if (DEBUG) NSLog(@"App not active");
//            }
//        }
//    }];
}

-(void)checkForUpdates {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

    if ([PFUser currentUser].isAuthenticated) {
        PFQuery *query = [PFQuery queryWithClassName:@"Settings"];
        [query whereKey:@"Type" equalTo:@"version"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSString *uptodateVersion = [object objectForKey:@"Number"];
                NSString *content = [object objectForKey:@"content"];
                if (![version isEqual:uptodateVersion]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"needsUpdate"
                                                                        object:content
                                                                      userInfo:nil];
                } else {
                    if (DEBUG) NSLog(@"Version is up to date");
                }
            } else {
                if (DEBUG) NSLog(@"Error finding version settings: %@", error);
            }
        }];
        
    }
}

-(void)queryInviteMessage {
//    if ([PFUser currentUser].isAuthenticated) {
        PFQuery *query = [PFQuery queryWithClassName:@"Settings"];
        [query whereKey:@"Type" equalTo:@"inviteText"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
//                NSString *uptodateVersion = [object objectForKey:@"Number"];
                NSString *content = [object objectForKey:@"content"];
                if (content) {
                    self.inviteMessageText = content;
                }

            } else {
                if (DEBUG) NSLog(@"Error finding invite message settings: %@", error);
            }
        }];
        
//    }

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
////    pageControl.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
//    [pageControl setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
//    UIImage * backButtonImage = [UIImage imageNamed: @"backArrowWhite2"];
////    backButtonImage = [backButtonImage stretchableImageWithLeftCapWidth: 15.0 topCapHeight: 30.0];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage: backButtonImage forState: UIControlStateNormal barMetrics: UIBarMetricsDefault];
    
    // Tap Parse Production
    [Parse setApplicationId:@"oa9f1pYhUoLldBojIPFVwPDpcsaMjuhfkSi1bb8a"
                clientKey:@"HojAK6PbBNgnHwF4Se5RV2X9fFVnqAhb2yLSo7ad"];
    
    //Tap Parse Dev
//    [Parse setApplicationId:@"IS47HJgxN8vMhUoJOBjvnU6HVJzgLFODFSJqbLEf"
//                  clientKey:@"ueUDdVpQkoytRo95nFGcJKsKi4FZ3cAUJnUakG5o"];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
//    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    if ([PFUser currentUser] && [PFUser currentUser].isAuthenticated) {
        @try {
            [mixpanel track:@"Launched app" properties:@{
                                                         @"User": [[PFUser currentUser] objectForKey:@"username"],
                                                         @"Phone": [[PFUser currentUser] objectForKey:@"phoneNumber"]
                                                         }];
            if (DEBUG) NSLog(@"Sent mixpanel");
            

        }
        @catch (NSException *exception) {
            if (DEBUG) NSLog(@"Mixpanel exception %@", exception);
        }
    } else {
        [mixpanel track:@"Launched app" properties:@{
                                                     @"User": @"Not Logged In"
                                                     }];

    }
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [self checkIfActive];
    [self queryInviteMessage];
//    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    [self checkForUpdates];
    
    self.contactsDict = [[NSMutableDictionary alloc] init];
    self.allReadTaps = [[NSMutableArray alloc] init];
    self.friendRequestsSent = [[NSMutableArray alloc] init];
    self.alphabeticalPhonebook = [[NSMutableArray alloc] init];
    self.numbersToUsernamesDict = [[NSMutableDictionary alloc] init];
    
    if ([PFUser currentUser]) {
        [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (DEBUG) NSLog(@"Refreshed user");
            if ([[object objectForKey:@"blocked"]boolValue]) {
                self.isBlocked = @(YES);
            } else {
                self.isBlocked = @(NO);
            }
        }];
    }
    
    @try {
        [self loadFriends];
    }
    @catch (NSException *exception) {
        if (DEBUG) NSLog(@"load friends exception %@", exception);
    }

    
    if (DEBUG) NSLog(@"friends array %@", self.friendsPhoneNumbersArray);

    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

+(void)sendMixpanelEvent:(NSString *)event {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    if ([PFUser currentUser].isAuthenticated) {
        if ([PFUser currentUser].isAuthenticated) {
            @try {
                [mixpanel track:event properties:@{
                                                   @"User": [[PFUser currentUser] objectForKey:@"username"],
                                                   @"Phone": [[PFUser currentUser] objectForKey:@"phoneNumber"]
                                                   }];
                if (DEBUG) NSLog(@"Sent mixpanel");

            }
            @catch (NSException *exception) {
                if (DEBUG) NSLog(@"Mixpanel excpetion %@", exception);
            }
        }
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    if (DEBUG) NSLog(@"CRASH: %@", exception);
    if (DEBUG) NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handlePush:application andUserInfo:userInfo];
}


-(void)handlePush:(UIApplication *)application andUserInfo:(NSDictionary *)userInfo {
    if (DEBUG) NSLog(@"handle push");
    if (DEBUG) NSLog(@"userInfo %@", userInfo);
    
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"newtap"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newTaps"
                                                            object:nil
                                                          userInfo:nil];
        if (DEBUG) NSLog(@"sent new taps notifications");
    }
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
        if (DEBUG) NSLog(@"incrementing badge");
//        NSInteger badgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        NSInteger badgeNumber = currentInstallation.badge;
        [application setApplicationIconBadgeNumber:badgeNumber];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{


    [[NSNotificationCenter defaultCenter] postNotificationName:@"appEnteredBackground"
                                                        object:nil
                                                      userInfo:nil];

    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"appEnteredForeground"
                                                        object:nil
                                                      userInfo:nil];
    
    
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [self checkIfActive];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            if (DEBUG) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"coredata" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"coredata.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        if (DEBUG) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Custom CoreData

- (BOOL)checkIfFriendIsInDatabase:(TPFriendObject *)friend
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                              inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parseUserId == %@", friend.parseUserId];
    fetchRequest.entity = entity;
    
    NSError *error;
    NSArray *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    
    return [fetchResults count] > 0;
}

-(TPFriendObject *)convertToTPFriendObject:(PFUser *)user {
    TPFriendObject *newUser = [[TPFriendObject alloc] init];
    
    newUser.parseUserId = [user objectId];
    newUser.username = [user objectForKey:@"username"];
    newUser.phoneNumber = [user objectForKey:@"phoneNumber"];
    
    return newUser;
}


- (BOOL)addFriendWithData:(TPFriendObject *)friend
{
    if (![self checkIfFriendIsInDatabase:friend]) {
        NSManagedObjectContext *context = self.managedObjectContext;
        
        TPFriend *friendToStore = [NSEntityDescription insertNewObjectForEntityForName:@"Friend"
                                                              inManagedObjectContext:context];
        friendToStore.parseUserId = friend.parseUserId;
        friendToStore.username = friend.username;
        friendToStore.phoneNumber = friend.phoneNumber;
        
        NSError *error;
        if (![context save:&error]) {
            if (DEBUG) NSLog(@"error adding friend");
            return NO;
        }
        
        return YES;
    }
    
    return YES;
}

@end
