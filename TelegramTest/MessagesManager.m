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
@interface NSUserNotification(Extensions)

@property (nonatomic)  BOOL hasReplyButton;

@end

@interface MessagesManager ()
@property (nonatomic,strong) NSMutableDictionary *messages;
@property (nonatomic,strong) NSMutableDictionary *messages_with_random_ids;

@property (nonatomic,strong) NSMutableDictionary *supportMessages;
@end

@implementation MessagesManager

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        self.messages = [[NSMutableDictionary alloc] init];
        self.messages_with_random_ids = [[NSMutableDictionary alloc] init];
        self.supportMessages = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)addSupportMessages:(NSArray *)supportMessages {
    
    [self.queue dispatchOnQueue:^{
        
        [supportMessages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            _supportMessages[@(obj.n_id)] = obj;
            
        }];
        
    }];
    
   
}

-(TL_localMessage *)supportMessage:(int)n_id {
    
    __block TL_localMessage *message;
    
    [self.queue dispatchOnQueue:^{
        
        message = _supportMessages[@(n_id)];
        
    } synchronous:YES];
    
    return message;
}


-(void)dealloc {
    [Notification removeObserver:self];
}



+(void)addAndUpdateMessage:(TL_localMessage *)message {
    [self addAndUpdateMessage:message notify:YES];
}

+(void)addAndUpdateMessage:(TL_localMessage *)message notify:(BOOL)notify {
    [self notifyMessage:message update_real_date:NO notify:notify];
}


-(void)notifyMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date notify:(BOOL)notify {
    [self.queue dispatchOnQueue:^{
      
        if(!message || [self find:message.n_id])
            return;
        
        
        [self addMessage:message];
         
        TL_conversation *conversation = message.conversation;
        
        [Notification perform:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
        [Notification perform:MESSAGE_UPDATE_TOP_MESSAGE data:@{KEY_MESSAGE:message,@"update_real_date":@(update_real_date)}];
        
        
        if(message.from_id == [UsersManager currentUserId]) {
            return;
        }
        
        if( conversation.isMute )
            if((message.flags & TGMENTIONMESSAGE) == 0)
                return;
        
        
        TLUser *fromUser = [[UsersManager sharedManager] find:message.from_id];
        
        TLChat *chat = [[ChatsManager sharedManager] find:message.to_id.chat_id];
        
        
        NSString *title = [message.to_id isSecret] || [TGPasslock isVisibility] ? appName() : [fromUser fullName];
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
            
            if(message.to_id.chat_id != 0) {
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
                    
                    image = [TMAvatarImageView generateTextAvatar:colorMask size:NSMakeSize(100, 100) text:text type:chat ? TMAvatarTypeChat : TMAvatarTypeUser font:[NSFont fontWithName:@"HelveticaNeue" size:30] offsetY:0];
                    
                    [TGCache cacheImage:image forKey:p groups:@[AVACACHE]];
                }
                
            }
            
        }
        
        
        
        
        if(message.to_id.chat_id != 0) {
            if(![message.to_id isSecret]) {
                subTitle = title;
                title = [chat title];
            } 
        }
        
        
        
        
        if ([NSUserNotification class] && [NSUserNotificationCenter class] && [SettingsArchiver checkMaskedSetting:PushNotifications]) {
            
            if([TGPasslock isVisibility] || [message.to_id isSecret])
            {
                title = appName();
                subTitle = nil;
                msg = NSLocalizedString(@"Notification.SecretMessage", nil);
            }
            
            
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
                notification.contentImage = image;
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
    _unread_count = 0;
}

-(void)add:(NSArray *)all {
    [self.queue dispatchOnQueue:^{
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
    
    [self.queue dispatchOnQueue:^{
        if(!message || message.n_id == 0) return;
        
        
       [self.messages setObject:message forKey:@(message.n_id)];
        
        [self.messages_with_random_ids setObject:message forKey:@(((TL_destructMessage *)message).randomId)];
    }];
}


-(id)find:(NSInteger)_id {
    
    __block id object;
    
    [self.queue dispatchOnQueue:^{
        object = [self.messages objectForKey:@(_id)];
    } synchronous:YES];
    
    return object;
}


-(NSArray *)markAllInDialog:(TL_conversation *)dialog {
    return [self markAllInConversation:dialog max_id:dialog.top_message];
}


-(NSArray *)markAllInConversation:(TL_conversation *)conversation max_id:(int)max_id {
    
    
    [self.queue dispatchOnQueue:^{
        NSArray *copy = [[self.messages allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"peer_id == %d AND self.n_id <= %d AND self.unread == YES",conversation.peer.peer_id,max_id]];
        
        
        for (TL_localMessage *msg in copy) {
            msg.flags&=~TGUNREADMESSAGE;
        }
        
    } synchronous:YES];
    
    
    return [[Storage manager] markAllInConversation:conversation max_id:max_id];
}


-(void)setUnread_count:(int)unread_count {
     self->_unread_count = unread_count < 0 ? 0 : unread_count;
    [LoopingUtils runOnMainQueueAsync:^{
        NSString *str = unread_count > 0 ? [NSString stringWithFormat:@"%d",unread_count] : nil;
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:str];
        [Notification perform:UNREAD_COUNT_CHANGED data:@{@"count":@(unread_count)}];

    }];
   
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
