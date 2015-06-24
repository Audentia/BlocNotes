//
//  ResultsTableViewController.m
//  
//
//  Created by Douglas Hewitt on 6/22/15.
//
//

#import "ResultsTableViewController.h"
#import "DetailViewController.h"

@interface ResultsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.delegate = self;
    [self.tableView setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        NSLog(@"returning search list");
//    tableView.delegate = self;
        return self.filteredList.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSManagedObject *object = [self.filteredList objectAtIndex:indexPath.row];
//    cell.textLabel.text = [[object valueForKey:@"title"] description];
    
    [ResultsTableViewController configureCell:cell forObject:object];
    return cell;
}

+ (void)configureCell:(UITableViewCell *)cell forObject:(NSManagedObject *)object {

    cell.textLabel.text = [[object valueForKey:@"title"] description];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.filteredList objectAtIndex:indexPath.row];
    [self sendNotificationWithObject:object];
    NSLog(@"resultsDidSelectSomething");

}

- (void)sendNotificationWithObject:(NSManagedObject *)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsTableViewControllerDidTapSearchItemNotification"
                                                        object:object];
    NSLog(@"resultsDidSendNotification");
}
    
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
