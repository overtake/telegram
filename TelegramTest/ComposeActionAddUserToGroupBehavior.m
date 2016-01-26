//
//  ComposeActionAddUserToGroupBehavior.m
//  Telegram
//
//  Created by keepcoder on 19.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeActionAddUserToGroupBehavior.h"
#import "SelectChatItem.h"
@implementation ComposeActionAddUserToGroupBehavior


-(TLUser *)user {
    return self.action.object;
}

-(NSUInteger)limit {
    return 0;
}


-(NSString *)doneTitle {
    return NSLocalizedString(@"Compose.AddMembers", nil);
}

-(NSAttributedString *)centerTitle {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Compose.ChooseGroup", nil) withColor:NSColorFromRGB(0x333333)];
    
    [attr setFont:TGSystemFont(13) forRange:attr.range];
    
    [attr setAlignment:NSCenterTextAlignment range:attr.range];
    
    return attr;
}

-(void)composeDidDone {
    
    [self.delegate behaviorDidStartRequest];
    
    [self addMemberToChat:self.action.result.multiObjects user:self.user];
    
}

-(void)addMemberToChat:(NSArray *)members user:(TLUser *)user {
    
    TLChat *chat = members[0];
    
    id request = [TLAPI_messages_addChatUser createWithChat_id:chat.n_id user_id:user.inputUser fwd_limit:100];
    
    if(chat.isChannel) {
        request = [TLAPI_channels_inviteToChannel createWithChannel:chat.inputPeer users:[@[user.inputUser] mutableCopy]];
    }
    
    
    dispatch_block_t addblock = ^{
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            
            [self.delegate behaviorDidEndRequest:response];
            
            dispatch_after_seconds(0.2, ^{
                
                [self.action.currentViewController.navigationViewController showMessagesViewController:chat.dialog];
                
                if(self.action.reservedObject1) {
                    [self.action.currentViewController.messagesViewController showBotStartButton:self.action.reservedObject1[@"startgroup"] bot:user];
                }
                
            });
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            [self.delegate behaviorDidEndRequest:request.response];
            
            alert(appName(), NSLocalizedString([error.error_msg isEqualToString:@"USER_ALREADY_PARTICIPANT"] ? @"Bot.AlreadyInGroup" : error.error_msg, nil));
        }];
    };
    
    
    addblock();
    
//    if(chat.isChannel) {
//        [RPCRequest sendRequest:[TLAPI_channels_getParticipant createWithChannel:chat.inputPeer user_id:user.inputUser] successHandler:^(id request, TL_channels_channelParticipant *participant) {
//            
//            
//          //  TL_channelParticipant
//            [self.delegate behaviorDidEndRequest:participant];
//            
//            alert(appName(), NSLocalizedString(@"Bot.AlreadyInGroup", nil));
//            
//        } errorHandler:^(id request, RpcError *error) {
//            if([error.error_msg isEqualToString:@"USER_NOT_PARTICIPANT"])  {
//                addblock();
//            } else {
//                [self.delegate behaviorDidEndRequest:nil];
//                alert(appName(), NSLocalizedString(error.error_msg, nil));
//            }
//        }];
//    } else {
//        addblock();
//    }
}


@end
