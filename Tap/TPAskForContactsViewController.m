//
//  TPAskForContactsViewController.m
//  Tap
//
//  Created by Edward Lando on 7/5/14.
//  Copyright (c) 2014 Yagil Burowski. All rights reserved.
//

#import "TPAskForContactsViewController.h"
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBook.h>


@interface TPAskForContactsViewController ()
@property (nonatomic, strong) NSMutableArray *phonebook;
@property (nonatomic, strong) NSMutableDictionary *alphabeticalPhonebook;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation TPAskForContactsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}

-(void) fetchPhoneContacts {
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    
    if (!accessGranted) {
        //
    } else {
        
        NSArray *allPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        self.phonebook = [[NSMutableArray alloc] initWithCapacity:[allPeople count]]; // capacity is only a rough guess, but better than nothing
        self.alphabeticalPhonebook = [[NSMutableDictionary alloc] initWithCapacity:[self.sections count]];
        for (int i = 0; i < [self.sections count]; i++) {
            [self.alphabeticalPhonebook setObject:[[NSMutableArray alloc] init] forKey:[[self.sections objectAtIndex:i] uppercaseString]];
        }
        for (id record in allPeople) {
            CFTypeRef phoneProperty = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonPhoneProperty);
            NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
            CFRelease(phoneProperty);
            for (NSString *phone in phones) {
                NSString* compositeName = (__bridge NSString *)ABRecordCopyCompositeName((__bridge ABRecordRef)record);
                NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
                if(compositeName == nil)
                {
                    continue;
                }
                if(phone == nil){
                    continue;
                }
                [contact setObject:compositeName forKey:@"name"];
                
                [contact setObject:phone forKey:@"phone"];
                if (![self.phonebook containsObject:contact]) {
                    [self.phonebook addObject:contact];
                    NSString *firstLetter = [[[contact objectForKey:@"name"] substringToIndex:1] uppercaseString];
                    
                    //                    [[self.alphabeticalPhonebook valueForKeyPath:firstLetter] addObject:contact];
                    [[self.alphabeticalPhonebook valueForKey:firstLetter] addObject:contact];
                    
                }
                
            }
        }
        CFRelease(addressBook);
        
        //        NSLog(@"all items %ld", (unsigned long)[self.phonebook count]);
        //        for (int i =0; i< [self.phonebook count]; i++) {
        //            NSLog(@"something %@", [self.phonebook objectAtIndex:i]);
        //        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        for (NSString *key in [self.alphabeticalPhonebook allKeys]) {
            [[self.alphabeticalPhonebook objectForKey:key ] sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        }
        NSLog(@"alphabetical phonebook %@", self.alphabeticalPhonebook);
        //        [self.phonebook sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        allPeople = nil;
        NSArray *temp = [[PFUser currentUser]objectForKey:@"contacts"];
        if(temp == nil || temp == NULL){
            [[PFUser currentUser]setObject:self.phonebook forKey:@"contacts"];
            [[PFUser currentUser]saveInBackground];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Put this somewhere
// [self dismissViewControllerAnimated:YES completion:nil]


- (IBAction)askForContacts:(id)sender {
     [self fetchPhoneContacts];
    
}
@end
