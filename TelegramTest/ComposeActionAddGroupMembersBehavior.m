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
    
    [self addMembersToChat:[self.action.result.multiObjects mutableCopy] toChatId:self.chat.n_id];
    
}

-(void)addMembersToChat:(NSMutableArray *)members toChatId:(int)chatId {
    
    SelectUserItem *item = members[0];
    
    [members removeObjectAtIndex:0];
    
    [MessageSender sendStatedMessage:[TLAPI_messages_addChatUser createWithChat_id:chatId user_id:item.contact.user.inputUser fwd_limit:50] successHandler:^(RPCRequest *request, id response) {
        
        
        if(self.chat) {
            [self.chat.participants.participants addObject:[TL_chatParticipant createWithUser_id:item.contact.user.n_id inviter_id:[UsersManager currentUserId] date:[[MTNetwork instance] getTime]]];
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
    }];
}



@end
