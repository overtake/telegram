//
//  TMStatusTextField.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMStatusTextField.h"
#import "TGTimer.h"

@interface TMStatusOnlineChecker : NSObject

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) TGTimer *timer;
+ (TMStatusOnlineChecker *)sharedInstance;
- (void)addTextField:(TMStatusTextField *)statusTextField;
- (void)removeTextField:(TMStatusTextField *)statusTextField;

@end

@interface TMStatusTextField()
@property (nonatomic, strong) NSAttributedString *currentAttributedString;
@end

@implementation TMStatusTextField

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [Notification addObserver:self selector:@selector(userUpdateStatusNotification:) name:USER_STATUS];
    [Notification addObserver:self selector:@selector(chatUpdateStatusNotification:) name:CHAT_STATUS];
    [Notification addObserver:self selector:@selector(broadcastUpdateStatusNotification:) name:BROADCAST_STATUS];
    [Notification addObserver:self selector:@selector(chatUpdateTypeNotification:) name:CHAT_UPDATE_TYPE];
    
    [self setBordered:NO];
    [self setEditable:NO];
    [self setSelectable:NO];
    [[self cell] setTruncatesLastVisibleLine:YES];
    [[self cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    
    self.selector = @selector(statusAttributedString);
}

- (void)chatUpdateTypeNotification:(NSNotification *)notify {
    TGChat *chat = [notify.userInfo objectForKey:KEY_CHAT];
    if(chat.n_id == self.chat.n_id) {
        self->_chat = nil;
        [self setChat:chat];
    }
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];

    if(self.window) {
        [[TMStatusOnlineChecker sharedInstance] addTextField:self];
    } else {
        [[TMStatusOnlineChecker sharedInstance] removeTextField:self];
    }
}

- (void)dealloc {
    [Notification removeObserver:self];
    [[TMStatusOnlineChecker sharedInstance] removeTextField:self];
}

- (void) setSelected:(BOOL)selected {
    self->_selected = selected;
    self.attributedStringValue = self.currentAttributedString;
}

- (void)broadcastUpdateStatusNotification:(NSNotification *)notify {
    int chat_id = [[notify.userInfo objectForKey:KEY_CHAT_ID] intValue];
    if(chat_id == self.broadcast.n_id) {
        TL_broadcast *broadcast = self.broadcast;
        self->_broadcast = nil;
        [self setBroadcast:broadcast];
    }

}

- (void) chatUpdateStatusNotification:(NSNotification *)notify {
    int chat_id = [[notify.userInfo objectForKey:KEY_CHAT_ID] intValue];
    if(chat_id == self.chat.n_id) {
        TGChat *chat = self.chat;
        self->_chat = nil;
        [self setChat:chat];
    }
}

- (void) userUpdateStatusNotification:(NSNotification *)notify {
    int user_id = [[notify.userInfo objectForKey:KEY_USER_ID] intValue];
    if(user_id == self.user.n_id) {
        TGUser *user = self.user;
        self->_user = nil;
        [self setUser:user];
    }
}

- (void)setUser:(TGUser *)user {
    if(self->_user.n_id == user.n_id)
        return;
        
    self->_chat = nil;
    self->_user = user;
    self->_broadcast = nil;
    if(user == nil || self.lock)
        return;
    
    self.attributedStringValue = [user performSelector:self.selector withObject:nil];
    
}

- (void)setBroadcast:(TL_broadcast *)broadcast {
    if(self->_broadcast.n_id == broadcast.n_id)
        return;
    
    self->_chat = nil;
    self->_user = nil;
    self->_broadcast = broadcast;
    
    if(broadcast == nil || self.lock)
        return;
    
    self.attributedStringValue = [broadcast performSelector:self.selector withObject:nil];
    
}

- (void)update {
    TGChat *chat = self.chat;
    TGUser *user = self.user;
    TL_broadcast *broadcast = self.broadcast;
    
    self.chat = nil;
    self.user = nil;
    self->_broadcast = nil;
    
    if(user)
        self.user = user;
    else if(chat)
        self.chat = chat;
    else if(broadcast)
        self.broadcast = broadcast;
}

- (void)setChat:(TGChat *)chat {
    if(self->_chat.n_id == chat.n_id)
        return;
    
    self->_user = nil;
    self->_chat = chat;
    self->_broadcast = nil;
    
    if(chat == nil || self.lock)
        return;
    
    if(self.chat.type == TGChatTypeNormal && !self.chat.left) {
        self.attributedStringValue = [chat performSelector:self.selector withObject:nil];
    } else {
        self.attributedStringValue = [[NSAttributedString alloc] init];
    }
}

- (void)setAttributedStringValue:(NSMutableAttributedString *)obj {
    if([obj isKindOfClass:[NSMutableAttributedString class]]) {
        [obj setSelected:self.selected];
    }
    
    self.currentAttributedString = obj;
    
    [super setAttributedStringValue:obj];
    
    if(self.statusDelegate) {
        [self.statusDelegate TMStatusTextFieldDidChanged:self];
    }
}

@end



@implementation TMStatusOnlineChecker

+ (TMStatusOnlineChecker *)sharedInstance {
    static TMStatusOnlineChecker *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMStatusOnlineChecker alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.list = [NSMutableArray array];
        [Notification addObserver:self selector:@selector(protocolChanged:) name:PROTOCOL_UPDATED];
        [Notification addObserver:self selector:@selector(logoutNotification:) name:LOGOUT_EVENT];
        
        if([[MTNetwork instance] isAuth]) {
            [self protocolChanged:nil];
        }
    }
    return self;
}

- (void)protocolChanged:(NSNotification *)notify {
    [self.timer invalidate];
    self.timer = [[TGTimer alloc] initWithTimeout:30 repeat:YES completion:^{
        [self notifyAll];
    } queue:dispatch_get_main_queue()];
    [self.timer start];
}

- (void)notifyAll {
    for(NSValue *value in self.list) {
        TMStatusTextField *statusTextField = [value nonretainedObjectValue];
        if(statusTextField.chat) {
            [statusTextField chatUpdateStatusNotification:[NSNotification notificationWithName:@"" object:self userInfo:@{KEY_CHAT_ID: @(statusTextField.chat.n_id)}]];
        } else {
            [statusTextField userUpdateStatusNotification:[NSNotification notificationWithName:@"" object:self userInfo:@{KEY_USER_ID: @(statusTextField.user.n_id)}]];
        }
    }
}

- (void)logoutNotification:(NSNotification *)notify {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)addTextField:(TMStatusTextField *)statusTextField {
    NSValue *value = [NSValue valueWithNonretainedObject:statusTextField];
    [self.list addObject:value];
}

- (void)removeTextField:(TMStatusTextField *)statusTextField {
    NSValue *value = [NSValue valueWithNonretainedObject:statusTextField];
    [self.list removeObject:value];
}

@end
