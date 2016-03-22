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
#import "TGChannelTypeSettingViewController.h"
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
        
    } else if([self.action.currentViewController isKindOfClass:[TGChannelTypeSettingViewController class]]) {
        
        
        [self updateChannel];
        
    }
}

-(void)updateChannel {
    
    
    BOOL isPublic = [self.action.result.singleObject boolValue];
    
    if(isPublic) {
        
        if([self.action.reservedObject2 length] >= 5) {
            [self.action.currentViewController showModalProgress];
            
            [[ChatsManager sharedManager] updateChannelUserName:self.action.reservedObject2 channel:self.action.object completeHandler:^(TL_channel *channel) {
                
                [TMViewController hideModalProgressWithSuccess];
                
                [self showAddingCompose];
                
            } errorHandler:^(NSString *result) {
                
                [self.action.currentViewController hideModalProgress];
                
            }];

        } else {
             alert(appName(), NSLocalizedString(@"Channel.SetPublicUsernameDescription", nil));
        }
        
    } else {
        [self showAddingCompose];
    }
    
}

-(void)showAddingCompose {
    
    int chatId = [(TLChat *)self.action.object n_id];
    
    __block TLChatFull *chatFull = [[ChatFullManager sharedManager] find:chatId];
    
    
    dispatch_block_t block = ^{
        [self.action.currentViewController.navigationViewController gotoViewController:self.action.currentViewController.messagesViewController animated:NO];
        
        ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:self.action.currentViewController.view.bounds];
        
        [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:@[@([UsersManager currentUserId])] object:chatFull]];
        
        [self.action.currentViewController.navigationViewController pushViewController:viewController animated:YES];
    };
    
    
    if(!chatFull) {
        
        [self.action.currentViewController showModalProgress];
        
        [[ChatFullManager sharedManager] requestChatFull:chatId force:YES withCallback:^(TLChatFull *fullChat) {
            
            chatFull = fullChat;
            
            [self.action.currentViewController hideModalProgressWithSuccess];
            
            block();
            
        }];
    } else {
        block();
    }
    
    
}


-(void)createChannel {
    
   [self.delegate behaviorDidStartRequest];
    
    if(self.action.result.stepResult.count < 2)
        return;
    
    BOOL discussion = [self.action.result.stepResult[1] intValue];
    
    weak();
   
    self.request = [RPCRequest sendRequest:[TLAPI_channels_createChannel createWithFlags:discussion ? 0 : 1 << 0 title:self.action.result.stepResult.firstObject[0] about:[self.action.result.stepResult.firstObject count] > 1 ? self.action.result.stepResult.firstObject[1] : nil] successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        
        if(response.chats.count > 0) {
            
            TL_channel *channel = [[ChatsManager sharedManager] find:[(TL_channel *)response.chats[0] n_id]];
            
            weakSelf.action.object = channel;
                
            dispatch_block_t block = ^{
                [weakSelf.delegate behaviorDidEndRequest:response];
                
                [[ChatFullManager sharedManager] requestChatFull:channel.n_id force:YES];
                
                
                [weakSelf.action.currentViewController.messagesViewController setCurrentConversation:channel.dialog];
                
                [weakSelf.action.currentViewController.navigationViewController gotoViewController:weakSelf.action.currentViewController.messagesViewController animated:NO];
                
                TGChannelTypeSettingViewController *viewController = [[TGChannelTypeSettingViewController alloc] initWithFrame:weakSelf.action.currentViewController.view.bounds];;
                
                [viewController setAction:weakSelf.action];
                
                [weakSelf.action.currentViewController.navigationViewController pushViewController:viewController animated:YES];
                
                [weakSelf.delegate behaviorDidEndRequest:weakSelf];
            };
            
            block();
            
            [RPCRequest sendRequest:[TLAPI_channels_exportInvite createWithChannel:channel.inputPeer] successHandler:^(id request, id response) {
                
                
                weakSelf.action.reservedObject1 = response;
                
                [weakSelf.action.currentViewController setAction:self.action];
                
                
            } errorHandler:^(id request, RpcError *error) {
                block();
            }];
            
        
        }
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [weakSelf.delegate behaviorDidEndRequest:nil];
    }];
    
    
}


-(void)composeDidCancel {
    
    [self.request cancelRequest];
    
    [self.delegate behaviorDidEndRequest:nil];
}

@end
