//
//  ComposeActionMultiObserver.m
//  Telegram
//
//  Created by keepcoder on 28.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionGroupBehavior.h"
#import "ComposeChatCreateViewController.h"
#import "ComposePickerViewController.h"
#import "SelectUserItem.h"
@interface ComposeActionGroupBehavior ()
@property (nonatomic,strong) RPCRequest *request;
@end

@implementation ComposeActionGroupBehavior

-(NSUInteger)limit {
    return maxChatUsers()-1;
}

-(NSString *)doneTitle {
    return [self.action.currentViewController isKindOfClass:[ComposePickerViewController class]] ? NSLocalizedString(@"Compose.Next", nil) : NSLocalizedString(@"Compose.Create", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        [attr appendString:NSLocalizedString(@"Compose.GroupTitle", nil) withColor:NSColorFromRGB(0x333333)];
        
        NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%d",(self.action.result.multiObjects.count + 1),megagroupSizeMax()] withColor:DARK_GRAY];
        
        [attr setFont:TGSystemFont(12) forRange:range];
        

        
    } else {
        [attr appendString:NSLocalizedString(@"Compose.GroupTitle", nil) withColor:NSColorFromRGB(0x333333)];
    }
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        ComposeChatCreateViewController *viewController = [[ComposeChatCreateViewController alloc] initWithFrame:NSZeroRect];
        
        [viewController setAction:self.action];
        
        [self.action.currentViewController.navigationViewController pushViewController:viewController animated:YES];
                
    } else {
        
        [self.delegate behaviorDidStartRequest];
        
        [self createGroupChat];
        
    }
}

-(void)composeDidChangeSelected {
    
    static NSUInteger prev = 0;
    
    
    if(self.action.result.multiObjects.count == self.limit && prev == self.action.result.multiObjects.count) {
        alert(appName(), NSLocalizedString(@"Compose.MaxSelectChatUsers", nil));
    }
    
    prev = self.action.result.multiObjects.count;
}

-(void)createGroupChat {
    NSArray *selected = self.action.result.multiObjects;
    

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(TLUser* item in selected) {
        if(item.type != TLUserTypeSelf) {
            [array addObject:[item inputUser]];
        }
        
    }
    
    weak();
    
    id request = [TLAPI_messages_createChat createWithUsers:array title:self.action.result.singleObject];
    
    
    __block TLUpdates *reqResponse;
    __block RpcError *rpcError;
    dispatch_block_t process_error = ^{
        [weakSelf.delegate behaviorDidEndRequest:nil];
        
        if(rpcError.error_code == 400) {
            alert(appName(), NSLocalizedString(rpcError.error_msg, nil));
        } else if(rpcError.error_code == 420) {
            alert(appName(), [NSString stringWithFormat:NSLocalizedString(@"FLOOD_WAIT", nil),MAX(1,roundf((float)rpcError.resultId/60.0f))]);
        }
    };
    
    dispatch_block_t group_block = ^{
        if(reqResponse.updates.count > 1) {
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:(TLMessage *) ( [reqResponse.updates[2] message])];
            
            [[FullChatManager sharedManager] performLoad:msg.chat.n_id callback:^(TLChatFull *fullChat) {
                [weakSelf.delegate behaviorDidEndRequest:reqResponse];
                
                [weakSelf.action.currentViewController.navigationViewController showMessagesViewController:msg.conversation];
            }];
        }
    };
    
    
    
    dispatch_block_t supergroup_block = ^{
        if(reqResponse.chats.count > 0) {
            
             TL_channel *channel = [[ChatsManager sharedManager] find:[(TL_channel *)reqResponse.chats[0] n_id]];
            
            [RPCRequest sendRequest:[TLAPI_channels_inviteToChannel createWithChannel:channel.inputPeer users:array] successHandler:^(id request, id response) {
                
                weakSelf.action.object = channel;
                [weakSelf.delegate behaviorDidEndRequest:reqResponse];
                [[FullChatManager sharedManager] loadIfNeed:channel.n_id force:YES];
                [weakSelf.action.currentViewController.messagesViewController setCurrentConversation:channel.dialog];
                [weakSelf.action.currentViewController.navigationViewController gotoViewController:weakSelf.action.currentViewController.messagesViewController animated:NO];
                
                [weakSelf.delegate behaviorDidEndRequest:weakSelf];
                
            } errorHandler:^(id request, RpcError *error) {
                rpcError = error;
                
                process_error();
            }];
               
        }

    };
    
    
    self.request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        reqResponse = response;
        
        group_block();
   
        
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        rpcError = error;
        
        [ASQueue dispatchOnMainQueue:process_error];
     } timeout:10 queue:[ASQueue globalQueue].nativeQueue alwayContinueWithErrorContext:YES];
    
    
    
}



-(void)composeDidCancel {
    
    
    [self.request cancelRequest];
    
    [self.delegate behaviorDidEndRequest:nil];
}



@end
