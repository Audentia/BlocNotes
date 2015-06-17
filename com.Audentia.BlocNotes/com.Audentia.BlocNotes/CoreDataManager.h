//
//  CoreDataManager.h
//  
//
//  Created by Douglas Hewitt on 6/15/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)saveDataForItem:(id)detailItem WithTitle:(NSString *)noteTitle AndText:(NSString *)noteText;
+ (instancetype) sharedInstance;



@end
