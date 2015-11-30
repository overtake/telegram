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
#import "TGCache.h"
#import "TLFileLocation+Extensions.h"
#import "TGPasslock.h"
#import "NSString+Extended.h"
@interface NSUserNotification(Extensions)

@property (nonatomic)  BOOL hasReplyButton;

@end

@interface MessagesManager ()
@property (nonatomic,strong) NSMutableDictionary *messages;
@property (nonatomic,strong) NSMutableDictionary *messages_with_random_ids;
@property (nonatomic,strong) NSMutableOrderedSet *orderedMessages;
@property (nonatomic,strong) NSMutableDictionary *supportMessages;

@property (nonatomic,strong) NSMutableDictionary *lastNotificationTimes;

@property (nonatomic,assign) int unread_count;

@end

@implementation MessagesManager

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        self.messages = [[NSMutableDictionary alloc] init];
        self.messages_with_random_ids = [[NSMutableDictionary alloc] init];
        self.supportMessages = [[NSMutableDictionary alloc] init];
        self.lastNotificationTimes = [[NSMutableDictionary alloc] init];
        self.orderedMessages = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}


-(void)addSupportMessages:(NSArray *)supportMessages {
    
    [self.queue dispatchOnQueue:^{
        
        [supportMessages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            if(!_supportMessages[@(obj.peer_id)]) {
                _supportMessages[@(obj.peer_id)] = [[NSMutableDictionary alloc] init];
            }
            
            _supportMessages[@(obj.peer_id)][@(obj.n_id)] = obj;
            
        }];
        
    }];
    
   
}

-(TL_localMessage *)supportMessage:(int)n_id peer_id:(int)peer_id {
    
    __block TL_localMessage *message;
    
    [self.queue dispatchOnQueue:^{
        
        message = _supportMessages[@(peer_id)][@(n_id)];
        
    } synchronous:YES];
    
    return message;
}


+(void)addSupportMessages:(NSArray *)supportMessages {
    [[self sharedManager] addSupportMessages:supportMessages];
}

+(TL_localMessage *)supportMessage:(int)n_id peer_id:(int)peer_id {
    return [[self sharedManager] supportMessage:n_id peer_id:peer_id];
}

-(void)dealloc {
    [Notification removeObserver:self];
}



+(void)addAndUpdateMessage:(TL_localMessage *)message {
    [[Storage manager] insertMessages:@[message]];
    [self addAndUpdateMessage:message notify:YES];
}

+(void)addAndUpdateMessage:(TL_localMessage *)message notify:(BOOL)notify {
    [self notifyMessage:message update_real_date:NO notify:notify];
}


static const int seconds_to_notify = 120;

-(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date notify:(BOOL)notify {
    [self.queue dispatchOnQueue:^{
      
        if(!message)
            return;
        
        TL_conversation *conversation = message.conversation;
        
        [Notification performOnStageQueue:MESSAGE_UPDATE_TOP_MESSAGE data:@{KEY_MESSAGE:message,@"update_real_date":@(update_real_date)}];
        
        
        if(message.n_out || (message.isChannelMessage && (!message.isImportantMessage && !message.chat.isMegagroup))) {
            return;
        }
        
        if( conversation.isMute )
            if((message.flags & TGMENTIONMESSAGE) == 0)
                return;
        
        
        
        TLUser *fromUser = [[UsersManager sharedManager] find:message.from_id];
        
        TLChat *chat = [[ChatsManager sharedManager] find:message.chat.n_id];
        
        
        NSString *title = message.isChannelMessage && !message.chat.isMegagroup ? (chat.title) : ( [message.to_id isSecret] || [TGPasslock isVisibility] ? appName() : [fromUser fullName] );
        NSString *msg = message.message;
        if(message.action) {
            msg = [MessagesUtils serviceMessage:message forAction:message.action];
        } else if(![message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            msg = [MessagesUtils mediaMessage:message];
        }
        

        NSString *subTitle;
        
        
        NSImage *image;
        
        if(![message.to_id isSecret] && ![TGPasslock isVisibility]) {
            NSString *cacheKey = [fromUser.photo.photo_small cacheKey];
            
            if(chat != nil) {
                cacheKey = [chat.photo.photo_small cacheKey];
            }
            
            NSString *p = [NSString stringWithFormat:@"%@/%@.jpg", path(), cacheKey];
            
            
            image = [TGCache cachedImage:p group:@[AVACACHE]];
            
            
            
            if(!image) {
                
                NSData *data = [[NSFileManager defaultManager] fileExistsAtPath:p] ? [NSData dataWithContentsOfFile:p] : nil;
                
                
                if(data.length > 0) {
                    image = [[NSImage alloc] initWithData:data];
                    
                    image = [ImageUtils roundCorners:image size:NSMakeSize(image.size.width/2, image.size.height/2)];
                    
                    [TGCache cacheImage:image forKey:p groups:@[AVACACHE]];
                }
                
            }
            
            
            if(!image) {
                
                p = [NSString stringWithFormat:@"notification_%d",chat ? chat.n_id : fromUser.n_id];
                
                image = [TGCache cachedImage:p];
                
                if(!image) {
                    int colorMask = [TMAvatarImageView colorMask:chat ? chat : fromUser];
                    
                    NSString *text = [TMAvatarImageView text:chat ? chat : fromUser];
                    
                    image = [TMAvatarImageView generateTextAvatar:colorMask size:NSMakeSize(100, 100) text:text type:chat ? TMAvatarTypeChat : TMAvatarTypeUser font:TGSystemFont(30) offsetY:0];
                    
                    [TGCache cacheImage:image forKey:p groups:@[AVACACHE]];
                }
                
            }
            
        }
        
        
        
        
        if(message.peer_id < 0 && message.from_id != 0) {
            subTitle = title;
            title = [chat title];
        }
        
        
        
        if ([NSUserNotification class] && [NSUserNotificationCenter class] && [SettingsArchiver checkMaskedSetting:PushNotifications]) {
            
            if([TGPasslock isVisibility] || [message.to_id isSecret] || ![SettingsArchiver checkMaskedSetting:MessagesNotificationPreview])
            {
                title = appName();
                subTitle = nil;
                msg = NSLocalizedString(@"Notification.SecretMessage", nil);
            }
            
          
            
            
            
            
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = title;
            notification.informativeText = [msg fixEmoji];
            notification.subtitle = subTitle ? subTitle : @"";
            if(![[SettingsArchiver soundNotification] isEqualToString:@"None"])
                notification.soundName = [SettingsArchiver soundNotification];
            if (floor(NSAppKitVersionNumber) > 1187)
            {
                if(![message.to_id isSecret] && (!message.isChannelMessage || message.chat.dialog.canSendMessage))
                    notification.hasReplyButton = YES;
                notification.contentImage = image;
            }
            
            
            if(conversation.type == DialogTypeChat) {
                NSUInteger time = [_lastNotificationTimes[@(conversation.peer_id)] integerValue];
                
                
                if([[NSDate date] timeIntervalSince1970] - seconds_to_notify <= time) {
                    notification.soundName = nil;
                }
                _lastNotificationTimes[@(conversation.peer_id)] = @([[NSDate date] timeIntervalSince1970]);
                
            }
            
            [notification setUserInfo:@{@"peer_id":@(message.peer_id),@"msg_id":@(message.n_id)}];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            
            //[NSApp requestUserAttention:NSInformationalRequest];
        }
        
        
        
    }];
}


+(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date {
     [self notifyMessage:message update_real_date:update_real_date notify:YES];
}

+(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date notify:(BOOL)notify {
    
    [[MessagesManager sharedManager] notifyMessage:message update_real_date:update_real_date notify:notify];
}

+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text {
    if ([NSUserNotification class] && [NSUserNotificationCenter class] && [SettingsArchiver checkMaskedSetting:PushNotifications] && ![TGPasslock isVisibility]) {
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

-(TL_localMessage *)findWithRandomId:(long)random_id {
    __block TL_localMessage *object;
    
    [self.queue dispatchOnQueue:^{
        object = [self.messages_with_random_ids objectForKey:@(random_id)];
    } synchronous:YES];
    
    return object;
}


-(NSArray *)findWithWebPageId:(long)webpage_id {
   
    
    NSMutableArray *msgs = [[NSMutableArray alloc] init];
    
    [self.queue dispatchOnQueue:^{
        
        [self.messages enumerateKeysAndObjectsUsingBlock:^(id key, TL_localMessage *obj, BOOL *stop) {
            
            if(obj.media.webpage.n_id == webpage_id && [msgs indexOfObject:obj] == NSNotFound)
            {
                [msgs addObject:obj];
            }
            
        }];
        
    } synchronous:YES];
    
    return msgs;
}


-(void)drop {
    self->keys = [[NSMutableDictionary alloc] init];
    self->list = [[NSMutableArray alloc] init];
    self.messages = [[NSMutableDictionary alloc] init];
    self.orderedMessages = [[NSMutableOrderedSet alloc] init];
    self.messages_with_random_ids = [[NSMutableDictionary alloc] init];
    _unread_count = 0;
}

-(void)add:(NSArray *)all {
    [self.queue dispatchOnQueue:^{
        for (TLMessage *message in all) {
            assert([message isKindOfClass:[TL_localMessage class]]);
        }
    }];

}


-(TLMessage *)localMessageForId:(int)n_id {
    return [self.messages objectForKey:[NSNumber numberWithInt:n_id]];
}




-(id)find:(NSInteger)_id {
    
    __block id object;
    
    [self.queue dispatchOnQueue:^{
        object = [self.messages objectForKey:@(_id)];
    } synchronous:YES];
    
    return object;
}




-(void)readMessagesContent:(NSArray *)msg_ids {
    
    if(msg_ids.count == 0)
        return;
    
    [self.queue dispatchOnQueue:^{
        
        [msg_ids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            TL_localMessage *message = self.messages[obj];
            message.flags&=~TGREADEDCONTENT;
            
        }];
        
        [[Storage manager] readMessagesContent:msg_ids];
        
        [Notification perform:UPDATE_READ_CONTENTS data:@{KEY_MESSAGE_ID_LIST:msg_ids}];
        
    }];
    
    
    
}

-(void)setUnread_count:(int)unread_count {
    _unread_count = MAX(0,unread_count);
}

+(void)updateUnreadBadge {
    
    [[Storage manager] unreadCount:^(int count) {
        
        [[self sharedManager] setUnread_count:count];
        
        NSString *str = [[self sharedManager] unread_count] > 0 ? [NSString stringWithFormat:@"%d",count] : nil;
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:str];
        [Notification perform:UNREAD_COUNT_CHANGED data:@{@"count":@(count)}];
    } includeMuted:[SettingsArchiver checkMaskedSetting:IncludeMutedUnreadCount]];
    
}

+(int)unreadBadgeCount {
    return [[self sharedManager] unread_count];
}

+(MessagesManager *)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}
@end
