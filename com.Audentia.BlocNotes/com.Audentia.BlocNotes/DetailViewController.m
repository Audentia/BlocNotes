//
//  DetailViewController.m
//  com.Audentia.BlocNotes
//
//  Created by Douglas Hewitt on 6/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteText;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}
- (IBAction)shareNote:(id)sender {
    
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (_noteTitle.text.length > 0) {
        [itemsToShare addObject:_noteTitle.text];
    }
    
    if (_noteText.text.length > 0) {
        [itemsToShare addObject:_noteText.text];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *shareNoteVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:shareNoteVC animated:YES completion:nil];
    }
    
}

-(void)saveData {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (self.detailItem) {
        if ((![[self.detailItem valueForKey:@"title"] isEqualToString:_noteTitle.text]) || ![[self.detailItem valueForKey:@"text"] isEqualToString:_noteText.text]) {
            [self.detailItem setValue:_noteTitle.text forKey:@"title"];
            [self.detailItem setValue:_noteText.text forKey:@"text"];
            [self.detailItem setValue:[NSDate date] forKey:@"timeStamp"];
            
            NSError *error;
            [context save:&error];
        } else {
            // do nothing
            NSLog(@"No changes to existing note, will not save");
        }
        
        
        
        
    } else if (_noteText.text.length == 0 && _noteTitle.text.length == 0) {
        //do nothing
        NSLog(@"blank note, will not save");
    } else {
        NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        [newNote setValue: _noteTitle.text forKey:@"title"];
        [newNote setValue: _noteText.text forKey:@"text"];
        [newNote setValue: [NSDate date] forKey:@"timeStamp"];
        
        NSError *error;
        [context save:&error];
    }
    
    self.navigationTitle.title = _noteTitle.text;
    
 
}

- (void)viewDidDisappear:(BOOL)animated {
    [self saveData];

}

- (void)configureView {
    // Update the user interface for the detail item.

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
        self.navigationTitle.title = [[self.detailItem valueForKey:@"title"] description];
        self.noteTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.noteText.text = [[self.detailItem valueForKey:@"text"] description];
    }
}
- (IBAction)doneEditingTitle:(id)sender {
    [self resignFirstResponder];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
