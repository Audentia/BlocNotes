//
//  CoreDataiCloud.m
//  com.Audentia.BlocNotes
//
//  Created by Douglas Hewitt on 7/9/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "CoreDataiCloud.h"

@implementation CoreDataiCloud

#pragma mark - iCloud Setup
- (void) icloud {
//Check for iCloud Availability
NSFileManager* fileManager = [NSFileManager defaultManager];
id currentiCloudToken = fileManager.ubiquityIdentityToken;

//archive current icloud token to compare later if user switches accounts
if (currentiCloudToken) {
    NSData *newTokenData =
    [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
    [[NSUserDefaults standardUserDefaults]
     setObject: newTokenData
     forKey: @"com.Audentia.BlocNotes.UbiquityIdentityToken"];
} else {
    [[NSUserDefaults standardUserDefaults]
     removeObjectForKey: @"com.Audentia.BlocNotes.UbiquityIdentityToken"];
}

//Check if user signs out of iCloud
[[NSNotificationCenter defaultCenter]
 addObserver: self
 selector: @selector (iCloudAccountAvailabilityChanged:)
 name: NSUbiquityIdentityDidChangeNotification
 object: nil];

//Invite user to use iCloud
//    firstLaunchWithiCloudAvailable
//    NSUserDefaults
BOOL firstLaunchWithiCloudAvailable = ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunched"];


if (currentiCloudToken && firstLaunchWithiCloudAvailable) {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle: @"Choose Storage Option"
                                message: @"Should documents be stored in iCloud and available on all your devices?"
                                preferredStyle:
                                UIAlertControllerStyleActionSheet];
    UIAlertAction* localStorage = [UIAlertAction actionWithTitle:@"Local" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    UIAlertAction* iCloudStorage = [UIAlertAction actionWithTitle:@"iCloud" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:localStorage];
    [alert addAction:iCloudStorage];
    
    //        [self presentViewController:alert animated:YES completion:nil];
    [[CoreDataManager sharedInstance] migrateLocalStoreToiCloudStore];
}

//first just put the core data store in icloud ubiquity container


//getting url to your iCloud containter
__block NSURL *myContainer = [[NSURL alloc] init];
dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
    myContainer = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier: nil];
    if (myContainer != nil) {
        // Your app can write to the iCloud container
        
        dispatch_async (dispatch_get_main_queue (), ^(void) {
            // On the main thread, update UI and state as appropriate
        });
    }
});

//handle different icloud scenarios
//    NSUbiquityIdentityDidChangeNotification setup using notification center
//    retrieve new value of ubiquityIdentityToken
//    compare new value to previous value
//    If the values are different, the previously used account is now unavailable. Discard any changes, empty your iCloud-related data caches, and refresh all iCloud-related user interface elements
//    decide if user can keep using content locally, and if reenables icloud, be sure to have a way to migrate data to and form local store

//decide whats in document storage and whats in key value storage

#pragma mark - iCloud Key Value Store

// register to observe notifications from the store
[[NSNotificationCenter defaultCenter]
 addObserver: self
 selector: @selector (storeDidChange:)
 name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
 object: [NSUbiquitousKeyValueStore defaultStore]];

// get changes that might have happened while this
// instance of your app wasn't running
[[NSUbiquitousKeyValueStore defaultStore] synchronize];


}


- (void)alertView:(nonnull UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}



#pragma mark - iCloud Support

//if i need to start over
//+removeUbiquitousContentAndPersistentStoreAtURL:options:error

//move store location to icloud ubiquity container
- (void)migrateLocalStoreToiCloudStore {
    NSPersistentStore *store = [[_persistentStoreCoordinator persistentStores] firstObject];
    
    NSURL *newStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"group.com.Audentia.BlocNotes.sqlite"];
    
    
    //    NSMutableDictionary *localStoreOptions = [[self iCloudPersistentStoreOptions] mutableCopy];
    //    [localStoreOptions setObject:@YES forKey:NSPersistentStoreRemoveUbiquitousMetadataOption];
    
    NSPersistentStore *newStore = [_persistentStoreCoordinator migratePersistentStore:store
                                                                                toURL:newStoreURL
                                                                              options:[self iCloudPersistentStoreOptions]
                                                                             withType:NSSQLiteStoreType
                                                                                error:nil];
    [self reloadStore:newStore];
    NSLog(newStoreURL.absoluteString);
}


- (void)migrateiCloudStoreToLocalStore {
    // assuming you only have one store.
    NSPersistentStore *store = [[_persistentStoreCoordinator persistentStores] firstObject];
    
    NSURL *newStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"group.com.Audentia.BlocNotes.sqlite"];
    
    
    NSMutableDictionary *localStoreOptions = [[self iCloudPersistentStoreOptions] mutableCopy];
    [localStoreOptions setObject:@YES forKey:NSPersistentStoreRemoveUbiquitousMetadataOption];
    
    NSPersistentStore *newStore =  [_persistentStoreCoordinator migratePersistentStore:store
                                                                                 toURL:newStoreURL
                                                                               options:localStoreOptions
                                                                              withType:NSSQLiteStoreType
                                                                                 error:nil];
    
    [self reloadStore:newStore];
}

- (void)reloadStore:(NSPersistentStore *)store {
    if (store) {
        [_persistentStoreCoordinator removePersistentStore:store error:nil];
    }
    NSURL *newStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"group.com.Audentia.BlocNotes.sqlite"];
    
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:newStoreURL
                                                    options:[self iCloudPersistentStoreOptions]
                                                      error:nil];
}

/// Use these options in your call to -addPersistentStore:
- (NSDictionary *)iCloudPersistentStoreOptions {
    return @{NSPersistentStoreUbiquitousContentNameKey: @"BlocNotesiCloudStore"};
}

- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)changeNotification {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:changeNotification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context performBlockAndWait:^{
        NSError *error;
        
        if ([context hasChanges]) {
            BOOL success = [context save:&error];
            
            if (!success && error) {
                // perform error handling
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        
        [context reset];
    }];
    
    // Refresh your User Interface.
}

- (void)storesDidChange:(NSNotification *)notification {
    // Refresh your User Interface.
}





@end
