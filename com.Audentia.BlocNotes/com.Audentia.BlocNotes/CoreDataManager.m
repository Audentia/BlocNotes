//
//  CoreDataManager.m
//  
//
//  Created by Douglas Hewitt on 6/15/15.
//
//

#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (nonatomic, strong) NSURL* storeURL;
@property (nonatomic, strong) NSDictionary *iCloudStore;

@end

@implementation CoreDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Bloc.com_Audentia_BlocNotes" in the application's documents directory.
    //    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.Audentia.BlocNotes"];
    
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"com_Audentia_BlocNotes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    self.storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"com_Audentia_BlocNotes.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - iCloud
- (void)registerForiCloudNotifications {
    self.iCloudStore = @{ NSPersistentStoreUbiquitousContentNameKey : @"iCloudStore" };
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(storesWillChange:)
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                             object:self.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(storesDidChange:)
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                             object:self.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:self.persistentStoreCoordinator];
    
    NSError *error;
    
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:self.storeURL
                                                                             options:self.iCloudStore
                                                                               error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
}

// Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
// most likely to be called if the user enables / disables iCloud
// (either globally, or just for your app) or if the user changes
// iCloud accounts.
- (void)storesWillChange:(NSNotification *)note {
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if ([moc hasChanges]) {
            [moc save:&error];
        }
        
        [moc reset];
    }];
    
    // now reset your UI to be prepared USER for a totally different
    // set of data (eg, popToRootViewControllerAnimated:)
    // but don't load any new data yet.
}

- (void)storesDidChange:(NSNotification *)note {
//    [self migrateLocalStoreToiCloudStore]; //an attempt to alliviate issues
    [[NSNotificationCenter defaultCenter] postNotificationName:@"storesDidChangeNotification" object:nil];
}

// Subscribe to NSPersistentStoreDidImportUbiquitousContentChangesNotification
- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification*)note
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", note.userInfo.description);
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:note];
        
        // you may want to post a notification here so that which ever part of your app
        // needs to can react appropriately to what was merged.
        // An exmaple of how to iterate over what was merged follows, although I wouldn't
        // recommend doing it here. Better handle it in a delegate or use notifications.
        // Note that the notification contains NSManagedObjectIDs
        // and not NSManagedObjects.
        NSDictionary *changes = note.userInfo;
        NSMutableSet *allChanges = [NSMutableSet new];
        [allChanges unionSet:changes[NSInsertedObjectsKey]];
        [allChanges unionSet:changes[NSUpdatedObjectsKey]];
        [allChanges unionSet:changes[NSDeletedObjectsKey]];
        
        for (NSManagedObjectID *objID in allChanges) {
            // do whatever you need to with the NSManagedObjectID
            // you can retrieve the object from with [moc objectWithID:objID]
        }
        
    }];
}

- (void)migrateLocalStoreToiCloudStore {
    NSPersistentStore *store = [[_persistentStoreCoordinator persistentStores] firstObject];
    //    NSPersistentStore *currentStore = self.persistentStoreCoordinator.persistentStores.lastObject;
    
    
    NSURL *newStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"group.com.Audentia.BlocNotes.sqlite"];
    
    
    NSPersistentStore *newStore = [_persistentStoreCoordinator migratePersistentStore:store
                                                                                toURL:newStoreURL
                                                                              options:self.iCloudStore
                                                                             withType:NSSQLiteStoreType
                                                                                error:nil];
    [self reloadStore:newStore];
    NSLog(@"%@", newStoreURL.absoluteString);
}

- (void)migrateiCloudStoreToLocalStore {
    // assuming you only have one store.
    NSPersistentStore *store = [[_persistentStoreCoordinator persistentStores] firstObject];
    
    NSURL *newStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"group.com.Audentia.BlocNotes.sqlite"];
    
    
    NSMutableDictionary *localStoreOptions = [self.iCloudStore mutableCopy];
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
                                                    options:self.iCloudStore
                                                      error:nil];
}

#pragma mark - Core Data Migration

- (void)migrateStore {
    
    // grab the current store
    NSPersistentStore *currentStore = self.persistentStoreCoordinator.persistentStores.lastObject;
    
    // create a new URL
    NSURL *newStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"group.com.Audentia.BlocNotes.sqlite"];
    
    // migrate current store to new URL
    [self.persistentStoreCoordinator migratePersistentStore:currentStore toURL:newStoreURL options:nil withType:NSSQLiteStoreType error:nil];
}



#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)saveDataForItem:(id)detailItem WithTitle:(NSString *)noteTitle AndText:(NSString *)noteText {
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (detailItem) {
        if ((![[detailItem valueForKey:@"title"] isEqualToString:noteTitle]) || ![[detailItem valueForKey:@"text"] isEqualToString:noteText]) {
            [detailItem setValue:noteTitle forKey:@"title"];
            [detailItem setValue:noteText forKey:@"text"];
            [detailItem setValue:[NSDate date] forKey:@"timeStamp"];
            
            NSError *error;
            [context save:&error];
        } else {
            // do nothing
            NSLog(@"No changes to existing note, will not save");
        }
        
        
        
        
    } else if (noteText.length == 0 && noteTitle.length == 0) {
        //do nothing
        NSLog(@"blank note, will not save");
    } else {
        NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        [newNote setValue: noteTitle forKey:@"title"];
        [newNote setValue: noteText forKey:@"text"];
        [newNote setValue: [NSDate date] forKey:@"timeStamp"];
        
        NSError *error;
        [context save:&error];
    }

}

@end
