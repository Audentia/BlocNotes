//
//  ShareViewController.m
//  BlocNotes
//
//  Created by Douglas Hewitt on 6/12/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ShareViewController.h"
#import "CoreDataManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

//@property (strong, nonatomic) NSMutableString *contentWithURLString;
//@property (strong, nonatomic) NSMutableString *titleWithURLString;

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    
    return YES;
    
//    NSInteger messageLength = [[self.contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
//    NSInteger charactersRemaining = 100 - messageLength;
//    self.charactersRemaining = @(charactersRemaining);
//    
//    if (charactersRemaining >= 0) {
//        return YES;
//    }
//    
//    return NO;

}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    
    //send url of the website to first line of the note
    
    //from that url get website name and set it as note title
    
    //take text from user and insert it into the note, essentially run save method, but it needs to be from extension text box
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
//    NSItemProvider *itemProvider = inputItem.attachments.firstObject;
//    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
//        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
//            [self.contentWithURLString appendString:inputItem.attributedContentText.string];
//            [self.contentWithURLString appendString:self.contentText];
//    
//            [self.titleWithURLString appendString:inputItem.attributedContentText.string];
    
            [[CoreDataManager sharedInstance] saveDataForItem:nil WithTitle:inputItem.attributedContentText.string AndText:self.contentText];

//        }];
//    }
    
    
//alternate implementation from apple dev forums
//    for (NSExtensionItem *item in self.extensionContext.inputItems) {
//        for (NSItemProvider *itemProvider in item.attachments) {
//            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
//                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        _label.text = [url absoluteString];
//                    });
//                }];
//            }
//        }
//    }

    
    
    NSExtensionItem *outputItem = [inputItem copy];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:self.contentText attributes:nil];
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    
    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    
    //future: could add ability to modify existing note
    return @[];
}

@end
