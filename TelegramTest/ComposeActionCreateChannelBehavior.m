//
//  ComposeActionCreateChannelBehavior.m
//  Telegram
//
//  Created by keepcoder on 19.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeActionCreateChannelBehavior.h"
#import "SelectUserItem.h"
#import "ComposeActionAddGroupMembersBehavior.h"
@interface ComposeActionCreateChannelBehavior ()
@property (nonatomic,strong) RPCRequest *request;
@end

@implementation ComposeActionCreateChannelBehavior

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
    
    if([self.action.currentViewController isKindOfClass:[ComposeCreateChannelUserNameStepViewController class]])
        title = NSLocalizedString(@"Channel.Link", nil);
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]])
        title = NSLocalizedString(@"Compose.Members", nil);
    else
        title = NSLocalizedString(@"Compose.NewChannel", nil);

    
    [attr appendString:title withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    if([self.action.currentViewController isKindOfClass:[ComposeCreateChannelViewController class]]) {
        
        [self createChannel];
        
    } else if([self.action.currentViewController isKindOfClass:[ComposeSettingupNewChannelViewController class]]) {
        
        
        [self updateChannel];
        
    }
}

-(void)updateChannel {
    
    
    BOOL isPublic = [self.action.result.singleObject boolValue];
    
    if(isPublic) {
        
        if([self.action.reservedObject2 length] >= 5) {
            [TMViewController showModalProgress];
            
            [[ChatsManager sharedManager] updateChannelUserName:self.action.reservedObject2 channel:self.action.object completeHandler:^(TL_channel *channel) {
                
                [TMViewController hideModalProgressWithSuccess];
                
                [self showAddingCompose];
                
            } errorHandler:^(NSString *result) {
                
                [TMViewController hideModalProgress];
                
            }];

        } else {
             alert(appName(), NSLocalizedString(@"Channel.SetPublicUsernameDescription", nil));
        }
        
    } else {
        [self showAddingCompose];
    }
    
}

-(void)showAddingCompose {
    [[Telegram rightViewController] clearStack];
    
    [[Telegram rightViewController] showByDialog:[self.action.object dialog] sender:self];
    
    [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:@[[UsersManager currentUser]] object:[[FullChatManager sharedManager] find:[(TLChat *)self.action.object n_id]]]];
}


-(void)createChannel {
    
   [self.delegate behaviorDidStartRequest];
    
    if(self.action.result.stepResult.count < 2)
        return;
    
    BOOL discussion = [self.action.result.stepResult[1] intValue];
   
    self.request = [RPCRequest sendRequest:[TLAPI_channels_createChannel createWithFlags:discussion ? 0 : 1 << 0 title:self.action.result.stepResult.firstObject[0] about:[self.action.result.stepResult.firstObject count] > 1 ? self.action.result.stepResult.firstObject[1] : nil users:nil] successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        
        if(response.chats.count > 0) {
            
            TL_channel *channel = [[ChatsManager sharedManager] find:[(TL_channel *)response.chats[0] n_id]];
            
            [[FullChatManager sharedManager] performLoad:channel.n_id callback:^(TLChatFull *fullChat) {
                
                TL_conversation *conversation = channel.dialog;
                
                conversation.read_inbox_max_id = fullChat.read_inbox_max_id;
                conversation.unread_count = fullChat.unread_count;
                conversation.unread_important_count = fullChat.unread_important_count;
                
                [conversation save];
                
                
                self.action.object = channel;
                
                dispatch_block_t block = ^{
                    [self.delegate behaviorDidEndRequest:response];
                    
                    [[Telegram rightViewController] clearStack];
                    
                    [[Telegram rightViewController] showByDialog:channel.dialog sender:self];
                    
                    [[Telegram rightViewController] showComposeSettingsupNewChannel:self.action];
                    
                    [self.delegate behaviorDidEndRequest:self];
                };
                
                [RPCRequest sendRequest:[TLAPI_channels_exportInvite createWithChannel:channel.inputPeer] successHandler:^(id request, id response) {
                    
                    self.action.reservedObject1 = response;
                    
                    fullChat.exported_invite = response;
                    
                    [[Storage manager] insertFullChat:fullChat completeHandler:nil];
                    
                    block();
                    
                } errorHandler:^(id request, RpcError *error) {
                    block();
                }];
                

                
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
