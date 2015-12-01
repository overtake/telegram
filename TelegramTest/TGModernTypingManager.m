//
//  TGModernTypingManager.m
//  Telegram
//
//  Created by keepcoder on 03.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGModernTypingManager.h"


@interface TGModernTypingManager ()
@property (nonatomic,strong) NSMutableDictionary *objects;
@end

@implementation TGModernTypingManager


-(id)init {
    if(self = [super init]) {
        self.objects = [[NSMutableDictionary alloc] init];
        [Notification addObserver:self selector:@selector(userTypingNotification:) name:USER_TYPING];
        [Notification addObserver:self selector:@selector(newMessageNotification:) name:MESSAGE_RECEIVE_EVENT];
    }
    
    return self;
}

- (void) newMessageNotification:(NSNotification *)notify {
    TL_localMessage *message = [notify.userInfo objectForKey:KEY_MESSAGE];
    [ASQueue dispatchOnStageQueue:^{
        
        if(!message)
            return;
        
        TL_conversation *conversation = message.conversation;
        if(!conversation)
            return;
        
        TMTypingObject *object = [self typingForConversation:conversation];
        [object removeMember:message.from_id];
        
        
    }];
    
}

- (void) userTypingNotification:(NSNotification *)notify {
    [ASQueue dispatchOnStageQueue:^{
        
        TL_conversation *conversation = nil;
        TLUser *user = nil;
        
        TLUpdate *update = [notify.userInfo objectForKey:KEY_SHORT_UPDATE];
        
        if([update isKindOfClass:[TL_updateChatUserTyping class]]) {
            conversation = [[DialogsManager sharedManager] findByChatId:update.chat_id];
            user = [[UsersManager sharedManager] find:update.user_id];
        } else if([update isKindOfClass:[TL_updateUserTyping class]]) {
            conversation = [[DialogsManager sharedManager] findByUserId:update.user_id];
           user = [[UsersManager sharedManager] find:update.user_id];
        } else if([update isKindOfClass:[TL_updateEncryptedChatTyping class]]) {
            conversation = [[DialogsManager sharedManager] findBySecretId:update.chat_id];
           
            user = [[UsersManager sharedManager] find:[UsersManager currentUserId] == conversation.encryptedChat.participant_id ? conversation.encryptedChat.admin_id : conversation.encryptedChat.participant_id];
            
        }
        
        if(conversation && user) {
            TMTypingObject *object = [self typingForConversation:conversation];
            
            if(![update action])
                update.action = [TL_sendMessageTypingAction create];
            
            [object addMember:user withAction:[update action]];
            
        }
    }];
}




+ (TMTypingObject *) typingWithConversation:(TL_conversation *)conversation {
    
    __block TMTypingObject *obj;
    
    [ASQueue dispatchOnStageQueue:^{
        obj = [[self manager] typingForConversation:conversation];
    } synchronous:YES];
    
    return obj;
    
}

+ (void) asyncTypingWithConversation:(TL_conversation *)conversation handler:(void (^)(TMTypingObject *typing))handler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [ASQueue dispatchOnStageQueue:^{
        
        dispatch_async(dqueue, ^{
            handler([[self manager] typingForConversation:conversation]);
        });
        
    }];
    
}


- (TMTypingObject *) typingForConversation:(TL_conversation *)conversation {
    
    NSString *key = [NSString stringWithFormat:@"t:%d",conversation.peer_id];
    
    __block TMTypingObject *object;
    
    object = [self.objects objectForKey:key];
        
    if(!object) {
        object = [[TMTypingObject alloc] initWithDialog:conversation];
        [self.objects setObject:object forKey:key];
    }
    
    return object;
    
}

+(void)initialize {
    [self manager];
}

+(TGModernTypingManager *)manager {
    static TGModernTypingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGModernTypingManager alloc] init];
    });
    
    return instance;
}

+(void)drop {
    
    [ASQueue dispatchOnStageQueue:^{
    
        [[self manager] drop];
        
    }];
    
}


-(void)drop {
    [self.objects removeAllObjects];
}

@end
