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
    
    
    
    if([self.chat isKindOfClass:[TL_channelFull class]]) {
        [attr appendString:NSLocalizedString(@"Compose.Members", nil) withColor:NSColorFromRGB(0x333333)];
        [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
        return attr;
    }
        
    [attr appendString:NSLocalizedString(@"Compose.Contacts", nil) withColor:NSColorFromRGB(0x333333)];
        
    NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%lu",self.action.result.multiObjects.count,[self limit]] withColor:DARK_GRAY];
        
    [attr setFont:TGSystemFont(12) forRange:range];
        
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
            
            
            [self.action.currentViewController.navigationViewController goBackWithAnimation:YES];
            
            [[FullChatManager sharedManager] loadIfNeed:chat.n_id force:YES];
            
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
        
        
        if(members.count > 0) {
            [self addMembersToChat:members toChatId:chatId];
        } else {
            
            [[FullChatManager sharedManager] performLoad:chatId force:YES callback:^(TLChatFull *fullChat) {
                [self.delegate behaviorDidEndRequest:response];
                [self.action.currentViewController.navigationViewController goBackWithAnimation:YES];
            }];
            
            
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self.delegate behaviorDidEndRequest:request.response];
        alert(appName(), NSLocalizedString(error.error_msg, nil));
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}



@end
