//
//  ComposeActionCreateMegaGroupBehavior.m
//  Telegram
//
//  Created by keepcoder on 02/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ComposeActionCreateMegaGroupBehavior.h"

@interface ComposeActionCreateMegaGroupBehavior ()
@property (nonatomic,weak) RPCRequest *request;
@end

@implementation ComposeActionCreateMegaGroupBehavior


-(NSUInteger)limit {
    return -1;
}

-(NSString *)doneTitle {
    if([self.action.currentViewController isKindOfClass:[ComposeCreateChannelUserNameStepViewController class]])
        return NSLocalizedString(@"Compose.Save", nil);
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]])
        return NSLocalizedString(@"Compose.Create", nil);
    else
        return NSLocalizedString(@"Compose.Next", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    NSString *title;
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]])
        title = NSLocalizedString(@"Compose.Members", nil);
    else
        title = NSLocalizedString(@"Compose.NewMegaGroup", nil);
    
    
    [attr appendString:title withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    if([self.action.currentViewController isKindOfClass:[ComposeCreateChannelViewController class]]) {
        
        [self createMegagroup];
        
    }
}


-(void)createMegagroup {
    
    [self.delegate behaviorDidStartRequest];
    
    if(self.action.result.stepResult.count < 1)
        return;
    
    self.request = [RPCRequest sendRequest:[TLAPI_channels_createChannel createWithFlags:1 << 1 title:self.action.result.stepResult.firstObject[0] about:[self.action.result.stepResult.firstObject count] > 1 ? self.action.result.stepResult.firstObject[1] : nil] successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        
        
        if(response.chats.count > 0) {
            
            TLChat *chat = response.chats[0];
            
            [self.delegate behaviorDidEndRequest:response];
            
            [self.action.currentViewController.messagesViewController setCurrentConversation:chat.dialog];
            
            [self.action.currentViewController.navigationViewController gotoViewController:self.action.currentViewController.messagesViewController animated:NO];
            
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:nil];
    }];
    
}


-(void)composeDidCancel {

    if(self.request)
        [self.request cancelRequest];
    
    [self.delegate behaviorDidEndRequest:nil];
}



@end
