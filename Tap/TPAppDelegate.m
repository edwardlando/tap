//
//  TPAppDelegate.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#define MIXPANEL_TOKEN @"98677c640dfade631369fad2cc78bb66"

#import "TPAppDelegate.h"
#import <Parse/Parse.h>
#import <Mixpanel/Mixpanel.h>

@implementation TPAppDelegate


- (void)loadFriends{
    if([PFUser currentUser].isAuthenticated){
        NSLog(@"Loading friends");
//        [[[PFUser currentUser] objectForKey:@"friendsArray"] fetchIfNeeded];
        NSArray *friendsArray = [[PFUser currentUser] objectForKey:@"friendsArray"];
        
        self.friendsPhoneNumbersArray = [[NSMutableArray alloc] init];
        self.friendsArray = [[NSMutableArray alloc] init];
        
        self.numbersToUsernamesDict = [[NSMutableDictionary alloc] init];

        self.friendsObjectsDict = [[NSMutableDictionary alloc] init];
        
        if ([friendsArray count] > 0) {
            NSLog(@"Friends array count > 0");
//            NSLog(@"Friends array %@", friendsArray);
            for (PFUser *friend in friendsArray) {
                [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    [self.friendsObjectsDict setObject:object forKey:[object objectForKey:@"phoneNumber"]];

                    if (![self.friendsArray containsObject:friend]) {
                        [self.friendsArray addObject:friend];
//                        NSLog(@"Adding friend to friendsArray appDelegate %ld", [self.friendsArray count]);                        
                    }
                    if (![self.friendsPhoneNumbersArray containsObject:[object objectForKey:@"phoneNumber"]]) {
                        [self.friendsPhoneNumbersArray addObject:[object objectForKey:@"phoneNumber"]];
//                        NSLog(@"added this friend's phone nubmer %@", [object objectForKey:@"phoneNumber"]);
                    }
                
                    if (![self.numbersToUsernamesDict objectForKey:[object objectForKey:@"username"]]) {
                        [self.numbersToUsernamesDict setObject:[object objectForKey:@"username"] forKey:[object objectForKey:@"phoneNumber"]];                        
                    }
                    

                }];

            }
        }
    }
}


-(void)checkIfActive {
    PFQuery *query = [PFQuery queryWithClassName:@"Settings"];
    [query whereKey:@"Number" equalTo:@"2"];
    [query whereKey:@"Type" equalTo:@"active"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"object %d", [[object objectForKey:@"boolValue"] boolValue]);
        if (!error) {
            if ([[object objectForKey:@"boolValue"]boolValue]) {
                NSLog(@"App is active");
            } else {
                exit(0);
            }
            
        }
    }];
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
                    NSLog(@"Version is up to date");
                }
            } else {
                NSLog(@"Error finding version settings: %@", error);
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
                NSLog(@"Error finding invite message settings: %@", error);
            }
        }];
        
//    }

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
////    pageControl.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
//    [pageControl setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
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
            NSLog(@"Sent mixpanel");
            

        }
        @catch (NSException *exception) {
            NSLog(@"Mixpanel exception %@", exception);
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
            NSLog(@"Refreshed user");
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
        NSLog(@"load friends exception %@", exception);
    }

    
    NSLog(@"friends array %@", self.friendsPhoneNumbersArray);


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
                NSLog(@"Sent mixpanel");

            }
            @catch (NSException *exception) {
                NSLog(@"Mixpanel excpetion %@", exception);
            }
        }
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
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
    NSLog(@"handle push");
    NSLog(@"userInfo %@", userInfo);
    
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"newtap"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newTaps"
                                                            object:nil
                                                          userInfo:nil];
        NSLog(@"sent new taps notifications");
    }
    
    
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
        NSLog(@"incrementing badge");
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
    
    if ([PFUser currentUser].isAuthenticated){
            [self loadFriends];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
