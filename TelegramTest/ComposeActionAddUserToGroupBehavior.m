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
    
    [RPCRequest sendRequest:[TLAPI_messages_addChatUser createWithChat_id:chat.n_id user_id:user.inputUser fwd_limit:100] successHandler:^(RPCRequest *request, id response) {
        
        [chat.chatFull.participants.participants addObject:[TL_chatParticipant createWithUser_id:user.n_id inviter_id:[UsersManager currentUserId] date:[[MTNetwork instance] getTime]]];
            [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID:@(chat.n_id)}];
        
        [self.delegate behaviorDidEndRequest:response];
            
        dispatch_after_seconds(0.2, ^{
            
            
         
            [self.action.currentViewController.navigationViewController gotoViewController:self.action.currentViewController.messagesViewController];
            
            
            if(self.action.reservedObject1) {
                [self.action.currentViewController.messagesViewController showBotStartButton:self.action.reservedObject1[@"startgroup"] bot:user];
            }
            
        });

        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:request.response];
        
        alert(appName(), NSLocalizedString([error.error_msg isEqualToString:@"USER_ALREADY_PARTICIPANT"] ? @"Bot.AlreadyInGroup" : error.error_msg, nil));
    }];
}


@end
