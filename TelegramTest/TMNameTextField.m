//
//  TMNameTextField.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMNameTextField.h"
#import "TMAttributedString.h"
@interface TMNameTextField()
@property (nonatomic, strong) NSMutableAttributedString *currentAttributedString;
@end

@implementation TMNameTextField

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
    [Notification addObserver:self selector:@selector(userUpdateNameNotification:) name:USER_UPDATE_NAME];
    [Notification addObserver:self selector:@selector(chatUpdateTitleNotification:) name:CHAT_UPDATE_TITLE];
    [Notification addObserver:self selector:@selector(broadcastUpdateTitleNotification:) name:BROADCAST_UPDATE_TITLE];
    
    _searchRange = NSMakeRange(NSNotFound, 0);
    [self setBordered:NO];
    [self setEditable:NO];
    [self setSelectable:NO];
    [self setDrawsBackground:NO];
    [[self cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    
    self.selector = @selector(dialogTitle);
    self.encryptedSelector = @selector(dialogTitleEncrypted);
}



- (void)dealloc {
    [Notification removeObserver:self];
}

- (void)setSelectText:(NSString *)selectText {
    self->_selectText = selectText;
    
//    [NSMutableAttributedString selectText:selectText fromAttributedString:self.currentAttributedString selectionColor:BLUE_UI_COLOR];
    
    self.attributedStringValue = self.currentAttributedString;
}

- (void)setSelected:(BOOL)selected {
    self->_selected = selected;
    self.attributedStringValue = self.currentAttributedString;
}

- (void)chatUpdateTitleNotification:(NSNotification *)notify {
    if(self.type != TMNameTextFieldChat)
        return;

    TLChat *chat = [notify.userInfo objectForKey:KEY_CHAT];
    if(chat.n_id == self.chat.n_id) {
        self->_chat = nil;
        [self setChat:chat];
    }
}

- (void)broadcastUpdateTitleNotification:(NSNotification *)notify {
    if(self.type != TMNameTextFieldBroadcast)
        return;
    
    TL_broadcast *broadcast = [notify.userInfo objectForKey:KEY_BROADCAST];
    if(broadcast.n_id == self.broadcast.n_id) {
        self->_broadcast = nil;
        [self setBroadcast:broadcast];
    }
}

- (void)userUpdateNameNotification:(NSNotification *)notify {
    if(self.type == TMNameTextFieldChat)
        return;
    
    TLUser *user = [notify.userInfo objectForKey:KEY_USER];
    if(self.user.n_id != user.n_id)
        return;
    
    self->_user = nil;
    [self setUser:user isEncrypted:self.type == TMNameTextFieldEncryptedChat];
}

- (void)setUser:(TLUser *)user {
    [self setUser:user isEncrypted:NO];
}

- (void)setUser:(TLUser *)user isEncrypted:(BOOL)isEncrypted {
    TMNameTextFieldType type = isEncrypted ? TMNameTextFieldEncryptedChat : TMNameTextFieldUser;
    
    if(self->_user.n_id == user.n_id && self.type == type)
        return;
    
    self.type = type;
    self->_chat = nil;
    self->_user = user;
    self->_broadcast = nil;
    
    self.attributedStringValue = [user performSelector:isEncrypted ? self.encryptedSelector : self.selector withObject:nil];
}

- (void)setChat:(TLChat *)chat {
    if(self->_chat.n_id == chat.n_id)
        return;
    
    self.type = TMNameTextFieldChat;
    self->_user = nil;
    self->_chat = chat;
    self->_broadcast = nil;
    
    self.attributedStringValue = [chat performSelector:self.selector withObject:nil];
}

-(void)setBroadcast:(TL_broadcast *)broadcast {
    if(self->_broadcast.n_id == broadcast.n_id)
        return;
    
    self.type = TMNameTextFieldBroadcast;
    self->_user = nil;
    self->_chat = nil;
    self->_broadcast = broadcast;
    
    self.attributedStringValue = [broadcast performSelector:self.selector withObject:nil];
    
}


-(void)updateWithConversation:(TL_conversation *)conversation {
    
    switch (conversation.type) {
        
        case DialogTypeBroadcast:
            [self setBroadcast:conversation.broadcast];
            break;
        case DialogTypeChat: case DialogTypeChannel:
            [self setChat:conversation.chat];
            break;
        case DialogTypeSecretChat:
            [self setUser:conversation.user isEncrypted:YES];
            break;
        case DialogTypeUser:
            [self setUser:conversation.user];
        default:
            break;
    }
    
}

- (void)setAttributedStringValue:(NSMutableAttributedString *)obj {
    
    
    if([obj isKindOfClass:[NSMutableAttributedString class]]) {
        [obj setSelected:self.selected];
    }
    self.currentAttributedString = obj;

    if(self.selectText.length) {
        obj = [obj mutableCopy];
        
        [obj setSelected:self.selected];
        [obj setSelectionColor:NSColorFromRGB(0xfffffa) forColor:BLUE_UI_COLOR];
        [NSMutableAttributedString selectText:self.selectText fromAttributedString:obj selectionColor:BLUE_UI_COLOR];
    }
    
    NSMutableAttributedString *copy = obj;
    
    if((self.selected && self.selectedAttach) ||  (!self.selected && self.attach))
    {
        copy = [obj mutableCopy];
        
        [copy appendAttributedString:[NSAttributedString attributedStringWithAttachment:self.selected ? self.selectedAttach : self.attach]];
    }
    
    [super setAttributedStringValue:copy];
    
    if(self.nameDelegate) {
        [self.nameDelegate TMNameTextFieldDidChanged:self];
    }
    
}

- (void)update {
    TLChat *chat = self.chat;
    TLUser *user = self.user;
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

-(void)clear {
    self.chat = nil;
    self.user = nil;
    self->_broadcast = nil;
    
    self.attributedStringValue = nil;
}


@end
