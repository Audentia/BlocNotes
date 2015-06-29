//
//  DetailViewController.m
//  com.Audentia.BlocNotes
//
//  Created by Douglas Hewitt on 6/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteText;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

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

    
- (IBAction)didTapEditButton:(id)sender {

    switch (self.noteText.editable) {
        case NO:
            [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
            self.noteText.dataDetectorTypes = UIDataDetectorTypeNone;
            self.noteText.editable = YES;
            break;
            
        case YES:
            [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
            self.noteText.editable = NO;
            self.noteText.dataDetectorTypes = UIDataDetectorTypeAll;
            break;
            default:
            NSLog(@"didtap gesture, unsure what to do");
            break;
    }
}


- (void)viewDidDisappear:(BOOL)animated {

    [[CoreDataManager sharedInstance] saveDataForItem:_detailItem WithTitle:_noteTitle.text AndText:_noteText.text];
    
}

- (void)configureView {
    // Update the user interface for the detail item.

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.noteText.editable = NO;
    //add data detectors
    self.noteText.dataDetectorTypes = UIDataDetectorTypeAll;
    
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
