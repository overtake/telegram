//
//  TMTypingManager.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTypingManager.h"
#import "TLEncryptedChat+Extensions.h"

@interface TMTypingManager()
@property (nonatomic, strong) NSMutableDictionary *objects;
@end

@implementation TMTypingManager

+ (TMTypingManager *) sharedManager {
    static TMTypingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if(self) {
        [self drop];
    }
    return self;
}

- (void) drop {
    [Notification removeObserver:self];
    self.objects = [NSMutableDictionary dictionary];
    [Notification addObserver:self selector:@selector(userTypingNotification:) name:USER_TYPING];
    [Notification addObserver:self selector:@selector(newMessageNotification:) name:MESSAGE_RECEIVE_EVENT];
}

- (void) newMessageNotification:(NSNotification *)notify {
    TL_localMessage *message = [notify.userInfo objectForKey:KEY_MESSAGE];
    [ASQueue dispatchOnStageQueue:^{
        if(!message)
            return ELog(@"Message is nil");
        
        TL_conversation *dialog = message.conversation;
        if(!dialog)
            return ELog(@"Dialog is nil");
        
        TMTypingObject *object = [self typeObjectForDialog:dialog];
        [object removeMember:message.from_id];
    }];
    
}

- (void) userTypingNotification:(NSNotification *)notify {
    
    
    
    [[(DialogsManager *)[DialogsManager sharedManager] queue] dispatchOnQueue:^{
        TL_conversation *dialog = nil;
        NSUInteger user_id = 0;
        
        id object = [notify.userInfo objectForKey:KEY_SHORT_UPDATE];
        
        //    DLog(@"typing object %@", object);
        
        if([object isKindOfClass:[TL_updateChatUserTyping class]]) {
            TL_updateChatUserTyping *update = (TL_updateChatUserTyping *)object;
            dialog = [[DialogsManager sharedManager] findByChatId:update.chat_id];
            user_id = update.user_id;
        } else if([object isKindOfClass:[TL_updateUserTyping class]]) {
            TL_updateUserTyping *update = (TL_updateUserTyping *)object;
            dialog = [[DialogsManager sharedManager] findByUserId:update.user_id];
            user_id = update.user_id;
        } else if([object isKindOfClass:[TL_updateEncryptedChatTyping class]]) {
            TL_updateEncryptedChatTyping *update = (TL_updateEncryptedChatTyping *)object;
            dialog = [[DialogsManager sharedManager] findBySecretId:update.chat_id];
            update.chat = dialog.encryptedChat;
            user_id = [UsersManager currentUserId] == update.chat.participant_id ? update.chat.admin_id : update.chat.participant_id;
            
        }
        
        if(dialog) {
            //        DLog(@"typing object2 %@", object);
            
            TMTypingObject *object = [self typeObjectForDialog:dialog];
            [object addMember:user_id];
        }
    }];
}

- (TMTypingObject *) typeObjectForDialog:(TL_conversation *)dialog {
    
    NSString *key = [Notification notificationNameByDialog:dialog action:@"objects"];
    
    
    
    __block TMTypingObject *object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self.objects objectForKey:key];
        
        if(!object) {
            object = [[TMTypingObject alloc] initWithDialog:dialog];
            [self.objects setObject:object forKey:key];
        }
        
    } synchronous:YES];
    
  
    
    return object;
}

- (void) dealloc {
    [Notification removeObserver:self];
}

@end
