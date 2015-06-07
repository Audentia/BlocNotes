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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
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
- (IBAction)saveNote:(id)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (self.detailItem) {
        [self.detailItem setValue:_noteTitle.text forKey:@"title"];
        [self.detailItem setValue:_noteText.text forKey:@"text"];
        [self.detailItem setValue:[NSDate date] forKey:@"timeStamp"];
    } else {
        NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        [newNote setValue: _noteTitle.text forKey:@"title"];
        [newNote setValue: _noteText.text forKey:@"text"];
        [newNote setValue: [NSDate date] forKey:@"timeStamp"];
    }
    
    self.navigationTitle.title = _noteTitle.text;
    
    NSError *error;
    [context save:&error];
    
    [self resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureView {
    // Update the user interface for the detail item.
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
