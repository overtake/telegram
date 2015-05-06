//
//  ShareViewController.m
//  TGShare
//
//  Created by keepcoder on 01.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ShareViewController.h"
#import "TGS_RPCRequest.h"
#import "TGS_MTNetwork.h"
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
    
    [[TGS_MTNetwork instance] startNetwork];
    
    [TGS_RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithOffset:0 max_id:0 limit:100] successHandler:^(TGS_RPCRequest *request, id response) {
        
        int i = 0;
        
    } errorHandler:^(TGS_RPCRequest *request, RpcError *error) {
        
    }];

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

