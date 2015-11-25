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

@property (nonatomic,strong) BTRButton *cancel;
@end

@implementation MessagesTopInfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        self.field = [TMHyperlinkTextField defaultTextField];
        
        
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
       
        
        self.progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        [self.progress setAutoresizingMask:NSViewMaxXMargin | NSViewMinXMargin];
        
       
        
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        
        
        [self addSubview:self.progress];
        
        [self addSubview:self.field];
        
        self.locked = NO;
        
        self.backgroundColor = NSColorFromRGB(0xffffff);

        
        self.action = MessagesTopInfoActionShareContact;
        
        self.field.url_delegate = self;
        
        
        _cancel = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 72, NSHeight(frame))];
        [_cancel setTitle:NSLocalizedString(@"Messages.MessagesTopInfoActionReportSpam.ButtonCancel", nil) forControlState:BTRControlStateNormal];
        [_cancel setTitleFont:TGSystemMediumFont(13) forControlState:BTRControlStateNormal];
        [_cancel setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        weak();
        
        [_cancel addBlock:^(BTRControlEvents events) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"showreport_%d",weakSelf.conversation.user.n_id]];
            
            [weakSelf setConversation:weakSelf.conversation];
            
        } forControlEvents:BTRControlEventClick];
        
        
        [_cancel setHidden:YES];
        
        [self addSubview:_cancel];
        
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
    [super setFrame:NSMakeRect(0, NSMinY(frameRect), NSWidth([Telegram rightViewController].view.frame), frameRect.size.height)];
    
    [self.progress setCenterByView:self];
    [self.field setCenterByView:self];
}


- (void)didChangeUserBlock:(NSNotification *)notification {
    
    return;
    
    
    TL_contactBlocked *contact = notification.userInfo[KEY_USER];
    
    if(_conversation.user.n_id != contact.user_id || _conversation.user.isBot)
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
        newAction = MessagesTopInfoActionNone;//MessagesTopInfoActionShareContact;
    }
    
   // if(user.isBlocked) {
     //    newAction = MessagesTopInfoActionUnblockUser;
   // }
    
    if(user.isBot) {
        newAction = MessagesTopInfoActionNone;
    }
    
    BOOL showReport = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"showreport_%d",self.conversation.user.n_id]];
        
    if(showReport && newAction == MessagesTopInfoActionAddContact) {
        newAction = MessagesTopInfoActionReportSpam;
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
        [MessagesTopInfoActionUnblockUser] = @"Messages.MessagesTopInfoActionUnblockUser",
        [MessagesTopInfoActionReportSpam] = @""
    };
    
    static NSString * const buttonLocalization[] = {
        [MessagesTopInfoActionAddContact] = @"Messages.MessagesTopInfoActionAddContact.Button",
        [MessagesTopInfoActionShareContact] = @"Messages.MessagesTopInfoActionShareContact.Button",
        [MessagesTopInfoActionUnblockUser] = @"Messages.MessagesTopInfoActionUnblockUser.Button",
        [MessagesTopInfoActionReportSpam] = @"Messages.MessagesTopInfoActionReportSpam.Button"
    };
    
    [string appendString:NSLocalizedString(localizations[action], nil) withColor:NSColorFromRGB(0xa9a9a9)];
    
    NSRange range = [string appendString:NSLocalizedString(buttonLocalization[action], nil) withColor:BLUE_UI_COLOR];
    
    [string addAttributes:@{NSLinkAttributeName:@"first"} range:range];
    
    [_cancel setHidden:action != MessagesTopInfoActionReportSpam];
    
    
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
        [self.controller shareContact:[UsersManager currentUser] forConversation:self.conversation callback:nil];
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
    
    if(self.action == MessagesTopInfoActionReportSpam) {
        
        confirm(appName(), NSLocalizedString(@"ReportSpam.ConfirmDescription", nil), ^{
            
            self.locked = YES;
            
            [RPCRequest sendRequest:[TLAPI_messages_reportSpam createWithPeer:self.conversation.user.inputPeer] successHandler:^(id request, id response) {
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"always_showreport1_%d",self.conversation.user.n_id]];
                
                self.locked = NO;
                self.conversation = self.conversation;
                
                
                
            } errorHandler:^(id request, RpcError *error) {
                self.locked = NO;
                self.conversation = self.conversation;
            }];
            
        }, ^{
            
        });
        
        
        
    }
    
}


-(void)mouseUp:(NSEvent *)theEvent
{
   // [self.controller hideTopInfoView];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_cancel setFrameOrigin:NSMakePoint(newSize.width - NSWidth(_cancel.frame), 2)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
    
    // Drawing code here.
}

@end
