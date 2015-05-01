//
//  ShareViewController.m
//  TGShare
//
//  Created by keepcoder on 01.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ShareViewController.h"
#import "Storage.h"
@interface ShareViewController ()

@end

@implementation ShareViewController

- (NSString *)nibName {
    return @"ShareViewController";
}

- (void)loadView {
    [super loadView];
    
    // Insert code here to customize the view
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSLog(@"Attachments = %@", item.attachments);

}

- (IBAction)send:(id)sender {
    NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
    // Complete implementation by setting the appropriate value on the output item
    
    NSArray *outputItems = @[outputItem];
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
}

- (IBAction)cancel:(id)sender {
    NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
    [self.extensionContext cancelRequestWithError:cancelError];
}

@end

