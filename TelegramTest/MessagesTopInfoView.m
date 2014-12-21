//
//  MessagesTopInfoView.m
//  Telegram
//
//  Created by keepcoder on 02.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessagesTopInfoView.h"
#import "TLPeer+Extensions.h"
@interface MessagesTopInfoView () <TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) TMHyperlinkTextField *field;
@property (nonatomic,strong) NSProgressIndicator *progress;

@property (nonatomic,assign) BOOL locked;
@end

@implementation MessagesTopInfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        self.field = [TMHyperlinkTextField defaultTextField];
        
        
        
       
        
        self.progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        [self.progress setAutoresizingMask:NSViewMaxXMargin | NSViewMinXMargin];
        
       
        
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        
        
        [self addSubview:self.progress];
        
        [self addSubview:self.field];
        
        self.locked = NO;
        
        self.backgroundColor = NSColorFromRGB(0xffffff);

        
        self.action = MessagesTopInfoActionShareContact;
        
        self.field.url_delegate = self;
        
    }
    return self;
}

static NSMutableDictionary *cache;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
        
        cache[@(MessagesTopInfoActionShareContact)] = [[NSMutableDictionary alloc] init];
        cache[@(MessagesTopInfoActionAddContact)] = [[NSMutableDictionary alloc] init];
    });
}


-(void)setLocked:(BOOL)locked {
    self->_locked = locked;
    
    [self.progress setHidden:!locked];
    [self.field setHidden:locked];
    
    if(self.progress.isHidden)
        [self.progress stopAnimation:self];
    else [self.progress startAnimation:self];
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self.progress setCenterByView:self];
    [self.field setCenterByView:self];
}


- (void)didChangeUserBlock:(NSNotification *)notification {
    TL_contactBlocked *contact = notification.userInfo[KEY_USER];
    
    if(_conversation.user.n_id != contact.user_id)
        return;
    
    if(_conversation.user.isBlocked) {
        self.action = MessagesTopInfoActionUnblockUser;
        [self show:YES];
    } else {
        [self hide:YES];
    }
}

- (void)didChangeUserType:(NSNotification *)notification {
    TLUser *user = notification.userInfo[KEY_USER];
    
     MessagesTopInfoAction newAction = MessagesTopInfoActionNone;
    
    if(user.type == TLUserTypeRequest)
        newAction = MessagesTopInfoActionAddContact;
    
    if(user.type == TLUserTypeForeign) {
        newAction = MessagesTopInfoActionShareContact;
    }
    
    [cache[@(newAction)] removeObjectForKey:@(user.n_id)];
    
    if(newAction != MessagesTopInfoActionNone) {
        self.action = newAction;
        [self show:YES];
    } else {
        [self hide:YES];
    }
    
    
}

-(void)show:(BOOL)animated {
    if(!self.isShown) {
        [self.controller showTopInfoView:animated];
        _isShown = YES;
    }
}

-(void)hide:(BOOL)animated {
    if(self.isShown) {
        [self.controller hideTopInfoView:animated];
        _isShown = NO;
    }
}

-(void)dealloc {
    [Notification removeObserver:self];
}


-(void)setConversation:(TL_conversation *)conversation {
    self->_conversation = conversation;
    
    
    self.locked = NO;
    
    [Notification removeObserver:self];
    
    [Notification addObserver:self selector:@selector(didChangeUserBlock:) name:USER_BLOCK];
    
    [Notification addObserver:self selector:@selector(didChangeUserType:) name:[Notification notificationForUser:conversation.user action:USER_CHANGE_TYPE]];
    
    
    
    
    TLUser *user = conversation.user;
    
    MessagesTopInfoAction newAction = MessagesTopInfoActionNone;
    
    if(user.type == TLUserTypeRequest)
        newAction = MessagesTopInfoActionAddContact;
    
    if(user.type == TLUserTypeForeign) {
        newAction = MessagesTopInfoActionShareContact;
    }
    
    if(user.isBlocked) {
         newAction = MessagesTopInfoActionUnblockUser;
    }
    
    
    if(cache[@(newAction)] && cache[@(newAction)][@(conversation.peer.peer_id)]) {
        [self hide:NO];
        return;
    }

    
    
    if(newAction == MessagesTopInfoActionNone) {
        [self hide:NO];
    } else {
        [self show:NO];
        self.action = newAction;
    }
    
    
}


-(void)setAction:(MessagesTopInfoAction)action {
    self->_action = action;
    
    if(action == MessagesTopInfoActionNone) {
        return;
    }
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    static NSString * const localizations[] = {
        [MessagesTopInfoActionAddContact] = @"Messages.MessagesTopInfoActionAddContact",
        [MessagesTopInfoActionShareContact] = @"Messages.MessagesTopInfoActionShareContact",
        [MessagesTopInfoActionUnblockUser] = @"Messages.MessagesTopInfoActionUnblockUser"
    };
    
    static NSString * const buttonLocalization[] = {
        [MessagesTopInfoActionAddContact] = @"Messages.MessagesTopInfoActionAddContact.Button",
        [MessagesTopInfoActionShareContact] = @"Messages.MessagesTopInfoActionShareContact.Button",
        [MessagesTopInfoActionUnblockUser] = @"Messages.MessagesTopInfoActionUnblockUser.Button"
    };
    
    [string appendString:NSLocalizedString(localizations[action], nil) withColor:NSColorFromRGB(0xa9a9a9)];
    
    NSRange range = [string appendString:NSLocalizedString(buttonLocalization[action], nil) withColor:BLUE_UI_COLOR];
    
    [string addAttributes:@{NSLinkAttributeName:@""} range:range];
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:NSMakeRange(0, string.length)];
    
    [self.field setAttributedStringValue:string];
    
    [self.field sizeToFit];
    
    [self.field setCenterByView:self];
    
    [self.progress setCenterByView:self];
    
}

-(void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];
    
    self.action = self.action;
}

- (void)textField:(id)textField handleURLClick:(NSString *)url {
   
    if(self.locked)
        return;
    
    
    if(self.action == MessagesTopInfoActionShareContact) {
        [self.controller shareContact:[UsersManager currentUser] conversation:self.conversation callback:nil];
        cache[@(self.action)][@(self.conversation.peer.peer_id)] = @(self.conversation.peer.peer_id);
        [self hide:YES];
    }
    
    if(self.action == MessagesTopInfoActionUnblockUser) {
        self.locked = YES;
        [[BlockedUsersManager sharedManager] unblock:self.controller.conversation.user.n_id completeHandler:^(BOOL response) {
            [self hide:YES];
            self.locked = NO;
        }];
    }
    
    if(self.action == MessagesTopInfoActionAddContact) {
        self.locked = YES;
        [[NewContactsManager sharedManager] importContact:[TL_inputPhoneContact createWithClient_id:0 phone:self.controller.conversation.user.phone first_name:self.controller.conversation.user.first_name last_name:self.controller.conversation.user.last_name] callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
            cache[@(self.action)][@(self.conversation.peer.peer_id)] = @(self.conversation.peer.peer_id);
            [self hide:YES];
            self.locked = NO;
        }];
    }
    
}


-(void)mouseUp:(NSEvent *)theEvent
{
   // [self.controller hideTopInfoView];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
    
    // Drawing code here.
}

@end
