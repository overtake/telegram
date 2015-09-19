//
//  ComposeActionAddGroupMembersBehavior.m
//  Telegram
//
//  Created by keepcoder on 03.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionAddGroupMembersBehavior.h"
#import "SelectUserItem.h"
@interface ComposeActionAddGroupMembersBehavior ()
@end


@implementation ComposeActionAddGroupMembersBehavior


-(TL_chatFull *)chat {
    return self.action.object;
}

-(NSUInteger)limit {
    return maxChatUsers() - self.chat.participants.participants.count;
}


-(NSString *)doneTitle {
    return NSLocalizedString(@"Compose.AddMembers", nil);
}

-(NSAttributedString *)centerTitle {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Compose.Contacts", nil) withColor:NSColorFromRGB(0x333333)];
        
    NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%lu",self.action.result.multiObjects.count,[self limit]] withColor:DARK_GRAY];
        
    [attr setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:range];
        
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}

-(void)composeDidDone {
    
    [self.delegate behaviorDidStartRequest];
    
    TLChat *chat = [[ChatsManager sharedManager] find:self.chat.n_id];
    
    if([chat isKindOfClass:[TL_channel class]]) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(TLUser* item in self.action.result.multiObjects) {
            if(item.type != TLUserTypeSelf) {
                [array addObject:[item inputUser]];
            }
            
        }
        
        [RPCRequest sendRequest:[TLAPI_channels_inviteToChannel createWithChannel:chat.inputPeer users:array] successHandler:^(id request, id response) {
            
            
            [[Telegram rightViewController] navigationGoBack];
            
            [self.delegate behaviorDidEndRequest:nil];
            
            
        } errorHandler:^(id request, RpcError *error) {
            [self.delegate behaviorDidEndRequest:nil];
            
            alert(appName(), NSLocalizedString(error.error_msg, nil));
        }];
        
        
    } else
        [self addMembersToChat:[self.action.result.multiObjects mutableCopy] toChatId:self.chat.n_id];
    
}

-(void)addMembersToChat:(NSMutableArray *)members toChatId:(int)chatId {
    
    TLUser *user = members[0];
    
    [members removeObjectAtIndex:0];
    
    [RPCRequest sendRequest:[TLAPI_messages_addChatUser createWithChat_id:chatId user_id:user.inputUser fwd_limit:100] successHandler:^(RPCRequest *request, id response) {
        
        
        if(self.chat) {
            [self.chat.participants.participants addObject:[TL_chatParticipant createWithUser_id:user.n_id inviter_id:[UsersManager currentUserId] date:[[MTNetwork instance] getTime]]];
            [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID:@(self.chat.n_id)}];
        }
        
        if(members.count > 0) {
            [self addMembersToChat:members toChatId:chatId];
        } else {
            [self.delegate behaviorDidEndRequest:response];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[Telegram rightViewController] navigationGoBack];
            });
            
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:request.response];
        alert(appName(), NSLocalizedString(error.error_msg, nil));
    }];
}



@end
