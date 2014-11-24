//
//  MessagesManager.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SecretLayer1.h"
#import "SecretLayer17.h"

#import "MessagesManager.h"
#import "TLPeer+Extensions.h"
#import "Crypto.h"
#import "SelfDestructionController.h"
#import "MessagesUtils.h"
@interface NSUserNotification(Extensions)

@property (nonatomic)  BOOL hasReplyButton;

@end

@interface MessagesManager ()
@property (nonatomic,strong) NSMutableDictionary *messages;
@property (nonatomic,strong) NSMutableDictionary *messages_with_random_ids;
@end

@implementation MessagesManager

-(id)init {
    if(self = [super init]) {
        self.messages = [[NSMutableDictionary alloc] init];
        self.messages_with_random_ids = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)dealloc {
    [Notification removeObserver:self];
}

+ (void)statedMessage:(TL_messages_statedMessage*)response {
    
    if(response == nil)
        return;
    
    response.message = [TL_localMessage convertReceivedMessage:[response message]];
    
    
    [SharedManager proccessGlobalResponse:response];
    
    
    
    [MessagesManager addAndUpdateMessage:[response message]];
}


+(void)addAndUpdateMessage:(TLMessage *)message {
    [self notifyMessage:message update_real_date:NO];
}

+(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date {
    
    [ASQueue dispatchOnStageQueue:^{
        if(!message)
            return;
        
        
        [[MessagesManager sharedManager] addMessage:message];
        
        [Notification perform:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
        [Notification perform:MESSAGE_UPDATE_TOP_MESSAGE data:@{KEY_MESSAGE:message,@"update_real_date":@(update_real_date)}];
        
        
        if(message.from_id == [UsersManager currentUserId]) {
            return;
        }
        

        TL_conversation *dialog = message.conversation;
        
        
        BOOL result = dialog.isMute;
        if(result)
            return;
        
        NSString *title = [[[UsersManager sharedManager] find:message.from_id] fullName];
        NSString *msg = message.message;
        if(message.action) {
            msg = [MessagesUtils serviceMessage:message forAction:message.action];
        } else if(![message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            msg = [MessagesUtils mediaMessage:message];
        }
        
        if([message.to_id isSecret] && !message.action)
            msg = NSLocalizedString(@"Notification.SecretMessage", nil);
        
        NSString *subTitle;
        
        if(message.to_id.chat_id != 0) {
            if(![message.to_id isSecret]) {
                subTitle = title;
                title = [[[ChatsManager sharedManager] find:message.to_id.chat_id] title];
            } else {
                title = message.conversation.encryptedChat.peerUser.fullName;
            }
        }
        
        
        if ([NSUserNotification class] && [NSUserNotificationCenter class] && [SettingsArchiver checkMaskedSetting:PushNotifications]) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = title;
            notification.informativeText = msg;
            notification.subtitle = subTitle ? subTitle : @"";
            if(![[SettingsArchiver soundNotification] isEqualToString:@"None"])
                notification.soundName = [SettingsArchiver soundNotification];
            if (floor(NSAppKitVersionNumber) > 1187)
            {
                if(![message.to_id isSecret])
                    notification.hasReplyButton = YES;
            }
            
            [notification setUserInfo:@{@"peer_id":[NSNumber numberWithInt:[message peer_id]]}];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }

    }];
    
}

+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text {
    if ([NSUserNotification class] && [NSUserNotificationCenter class] && [SettingsArchiver checkMaskedSetting:PushNotifications]) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.informativeText = text;
        if(![[SettingsArchiver soundNotification] isEqualToString:@"None"])
            notification.soundName = [SettingsArchiver soundNotification];
        
        [notification setUserInfo:@{@"peer_id":@(peer_id)}];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

+ (void) getUserFromMessageId:(int)message_id completeHandler:(void (^)())completeHandler {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:message_id]];
    [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:array] successHandler:^(RPCRequest *request, id response) {
        
        if([response isKindOfClass:[TL_messages_messages class]]) {
            [SharedManager proccessGlobalResponse:response];
        }
        
        if(completeHandler)completeHandler();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
}

-(TL_destructMessage *)findWithRandomId:(long)random_id {
    __block TL_destructMessage *object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self.messages_with_random_ids objectForKey:@(random_id)];
    } synchronous:YES];
    
    return object;
}


-(void)drop {
    self->keys = [[NSMutableDictionary alloc] init];
    self->list = [[NSMutableArray alloc] init];
    self.messages = [[NSMutableDictionary alloc] init];
    _unread_count = 0;
}

-(void)add:(NSArray *)all {
    [ASQueue dispatchOnStageQueue:^{
        for (TLMessage *message in all) {
            assert([message isKindOfClass:[TL_localMessage class]]);
            [self TGsetMessage:message];
        }
    }];

}


-(TLMessage *)localMessageForId:(int)n_id {
    return [self.messages objectForKey:[NSNumber numberWithInt:n_id]];
}



-(void)addMessage:(TLMessage *)message  {
    [self TGsetMessage:message];
    [[Storage manager] insertMessage:message  completeHandler:nil];
}

-(void)TGsetMessage:(TLMessage *)message {
    
    [ASQueue dispatchOnStageQueue:^{
        if(!message || message.n_id == 0) return;
        
        [self.messages setObject:message forKey:@(message.n_id)];
        
        if([message isKindOfClass:[TL_destructMessage class]])
            [self.messages_with_random_ids setObject:message forKey:@(((TL_destructMessage *)message).randomId)];
    }];
}


-(id)find:(NSInteger)_id {
    
    __block id object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self.messages objectForKey:@(_id)];
    } synchronous:YES];
    
    return object;
}


-(NSArray *)markAllInDialog:(TL_conversation *)dialog {
    
    __block NSMutableArray *marked = [[NSMutableArray alloc] init];
    
    [ASQueue dispatchOnStageQueue:^{
        NSArray *copy = [[self.messages allValues] copy];
        copy = [copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"peer_id == %d",dialog.peer.peer_id]];
        for (TL_localMessage *msg in copy) {
            
            
            if(msg.unread == YES)
                [marked addObject:@([msg n_id])];
            msg.flags&=~TGUNREADMESSAGE;
        }
        [[Storage manager] markAllInDialog:dialog];
    } synchronous:YES];
    
   
    return marked;
}



-(void)setUnread_count:(int)unread_count {
     self->_unread_count = unread_count < 0 ? 0 : unread_count;
    [LoopingUtils runOnMainQueueAsync:^{
        NSString *str = unread_count > 0 ? [NSString stringWithFormat:@"%d",unread_count] : nil;
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:str];
        [[Telegram leftViewController] setUnreadCount:unread_count];

    }];
   
   }

+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}
@end
