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
    return ![self.action.currentViewController isKindOfClass:[ComposeCreateChannelUserNameStepViewController class]] ? NSLocalizedString(@"Compose.Next", nil) : NSLocalizedString(@"Compose.Create", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
     [attr appendString:NSLocalizedString(@"Compose.ChannelTitle", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    if([self.action.currentViewController isKindOfClass:[ComposeCreateChannelViewController class]]) {
        
        [[Telegram rightViewController] showComposeWithAction:self.action];
        
    } else if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        
        
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
   
    self.request = [RPCRequest sendRequest:[TLAPI_messages_createChannel createWithFlags:1 << 0 title:self.action.result.singleObject users:array] successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        
        if(response.chats.count > 0) {
            
            TL_channel *channel = [[ChatsManager sharedManager] find:[(TL_channel *)response.chats[0] n_id]];
            
            [[FullChatManager sharedManager] performLoad:channel.n_id isChannel:YES callback:^(TLChatFull *fullChat) {
                
                TL_conversation *conversation = channel.dialog;
                
                conversation.read_inbox_max_id = fullChat.read_inbox_max_id;
                conversation.unread_count = fullChat.unread_count;
                conversation.unread_important_count = fullChat.unread_important_count;
                
                [conversation save];
                
                [self.delegate behaviorDidEndRequest:response];
                
                [[Telegram rightViewController] clearStack];
                
                [[Telegram sharedInstance] showMessagesFromDialog:channel.dialog sender:self];
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
