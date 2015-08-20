//
//  ComposeActionCreateChannelBehavior.m
//  Telegram
//
//  Created by keepcoder on 19.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeActionCreateChannelBehavior.h"
#import "SelectUserItem.h"

@interface ComposeActionCreateChannelBehavior ()
@property (nonatomic,strong) RPCRequest *request;
@end

@implementation ComposeActionCreateChannelBehavior

-(NSUInteger)limit {
    return -1;
}

-(NSString *)doneTitle {
    return [self.action.currentViewController isKindOfClass:[ComposePickerViewController class]] ? NSLocalizedString(@"Compose.Next", nil) : NSLocalizedString(@"Compose.Create", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
     [attr appendString:NSLocalizedString(@"Compose.ChannelTitle", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        [[Telegram rightViewController] showComposeCreateChannel:self.action];
        
    } else {
        
        [self.delegate behaviorDidStartRequest];
        
        [self createChannel];
        
    }
}


-(void)createChannel {
    NSArray *selected = self.action.result.multiObjects;
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(SelectUserItem* item in selected) {
        if(item.user.type != TLUserTypeSelf) {
            [array addObject:[item.user inputUser]];
        }
        
    }
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_createChannel  createWithTitle:self.action.result.singleObject] successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        
        return;
        if(response.updates.count > 1) {
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:(TLMessage *) ( [response.updates[2] message])];
            
            [[FullChatManager sharedManager] performLoad:msg.conversation.chat.n_id callback:^(TLChatFull *fullChat) {
                [self.delegate behaviorDidEndRequest:response];
                
                [[Telegram rightViewController] clearStack];
                
                [[Telegram sharedInstance] showMessagesFromDialog:msg.conversation sender:self];
            }];
        }
        
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:nil];
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
    
}



-(void)composeDidCancel {
    
    
    [self.request cancelRequest];
    
    [self.delegate behaviorDidEndRequest:nil];
}

@end
