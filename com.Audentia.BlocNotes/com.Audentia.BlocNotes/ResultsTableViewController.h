//
//  ResultsTableViewController.h
//  
//
//  Created by Douglas Hewitt on 6/22/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface ResultsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *filteredList;

+ (void)configureCell:(UITableViewCell *)cell forObject:(NSManagedObject *)object;

@end
