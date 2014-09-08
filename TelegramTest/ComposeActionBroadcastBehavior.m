//
//  ComposeActionBroadcastBehavior.m
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionBroadcastBehavior.h"
#import "SelectUserItem.h"
#import "ComposeBroadcastListViewController.h"
@interface ComposeActionBroadcastBehavior ()
@end

@implementation ComposeActionBroadcastBehavior


-(NSUInteger)limit {
    return MAX_BROADCAST_USERS;
}

-(NSString *)doneTitle {
    return [self.action.currentViewController isKindOfClass:[ComposePickerViewController class]] ? NSLocalizedString(@"Compose.Create", nil) : NSLocalizedString(@"Compose.NewBroadcastList", nil);
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        
        [attr appendString:NSLocalizedString(@"Compose.BroadcastTitle", nil) withColor:NSColorFromRGB(0x333333)];
        
        NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%lu",self.action.result.multiObjects.count,[self limit]] withColor:DARK_GRAY];
        
        [attr setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:range];
        
        
        
    } else {
        [attr appendString:NSLocalizedString(@"ComposeMenu.Broadcast", nil) withColor:NSColorFromRGB(0x333333)];
    }
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}


-(void)composeDidDone {
    
    if([self.action.currentViewController isKindOfClass:[ComposePickerViewController class]]) {
        [self.delegate behaviorDidStartRequest];
        [self createBroadcast];

    } else {
        [[Telegram rightViewController] showComposeWithAction:self.action];
    }
}


-(void)createBroadcast {
    NSArray *selected = self.action.result.multiObjects;
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(SelectUserItem* item in selected) {
        if(!item.contact.user.type != TGUserTypeSelf) {
            TL_inputUserContact *_contact = [TL_inputUserContact createWithUser_id:item.contact.user.n_id];
            [array addObject:_contact];
        }
        
    }
    
    NSMutableArray *participants = [[NSMutableArray alloc] init];
    
    [selected enumerateObjectsUsingBlock:^( SelectUserItem * obj, NSUInteger idx, BOOL *stop) {
        [participants addObject:@(obj.contact.user_id)];
    }];
    
    TL_broadcast *broadcast = [TL_broadcast createWithN_id:arc4random() participants:participants title:@"" date:[[MTNetwork instance] getTime]];
    
    TL_conversation *conversation = [TL_conversation createWithPeer:[TL_peerBroadcast createWithChat_id:broadcast.n_id] top_message:0 unread_count:0 last_message_date:[[MTNetwork instance] getTime] notify_settings:[TL_peerNotifySettingsEmpty create] last_marked_message:0 top_message_fake:0 last_marked_date:[[MTNetwork instance] getTime]];
    
    [[DialogsManager sharedManager] add:@[conversation]];
    [conversation save];
    
    [[BroadcastManager sharedManager] add:@[broadcast]];
    
    int fakeId = [MessageSender getFakeMessageId];
    
    
    TL_localMessageService *msg = [TL_localMessageService createWithN_id:fakeId from_id:[UsersManager currentUserId] to_id:conversation.peer n_out:YES unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:NSLocalizedString(@"MessageAction.ServiceMessage.CreatedBroadcast", nil)] fakeId:fakeId randomId:rand_long() dstate:DeliveryStateNormal];
    
    [MessagesManager addAndUpdateMessage:msg];
    
     [self.delegate behaviorDidEndRequest:nil];
    
    
    [[Telegram rightViewController] showByDialog:conversation sender:self];
    
}



-(void)composeDidCancel {
    
    [self.delegate behaviorDidEndRequest:nil];
}


@end
