//
//  TPAppDelegate.m
//  Tap
//
//  Created by Yagil Burowski on 7/4/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPAppDelegate.h"
#import <Parse/Parse.h>

@implementation TPAppDelegate


- (void)loadFriends{
    if([PFUser currentUser].isAuthenticated){
        NSLog(@"Here");
//        [[[PFUser currentUser] objectForKey:@"friendsArray"] fetchIfNeeded];
        NSArray *friendsArray = [[PFUser currentUser] objectForKey:@"friendsArray"];
        
        if ([friendsArray count] > 0) {
            for (PFUser *friend in friendsArray) {
                [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [self.friendsPhoneNumbersArray addObject:[object objectForKey:@"phoneNumber"]];
                }];

            }
        }
    }
}


-(void) tempLoadFriends {
    if([PFUser currentUser].isAuthenticated){
        NSLog(@"Here");
        NSArray *friendsArray = [[PFUser currentUser] objectForKey:@"friendRequestsArray"];
        self.myGroup = [friendsArray mutableCopy];
    }
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"oa9f1pYhUoLldBojIPFVwPDpcsaMjuhfkSi1bb8a"
                  clientKey:@"HojAK6PbBNgnHwF4Se5RV2X9fFVnqAhb2yLSo7ad"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    self.contactsDict = [[NSMutableDictionary alloc] init];
    
    [self loadFriends];
//    [self tempLoadFriends];
    //Temp
    
//    if ([PFUser currentUser]) {
//        self.myGroup = [@[[PFUser currentUser]] mutableCopy];        
//    }

    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    
    return YES;
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
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
