//
//  ChatParticipantRowView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatParticipantRowView.h"
#import "TMAvatarImageView.h"
#import "UserInfoContainerView.h"

@interface ChatParticipantRowView()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) TMNameTextField *nameTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;
@property (nonatomic, strong) TMButton *kickButton;
@end

@implementation ChatParticipantRowView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImageView = [TMAvatarImageView standartNewConversationTableAvatar];
        [self.avatarImageView setFrameOrigin:NSMakePoint(180, 3)];
        [self addSubview:self.avatarImageView];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        self.nameTextField.nameDelegate = self;
        [self.nameTextField setSelector:@selector(chatInfoTitle)];
        [self.nameTextField setFrameOrigin:NSMakePoint(236, 26)];
        [self addSubview:self.nameTextField];
        
        self.statusTextField = [[TMStatusTextField alloc] init];
        [self.statusTextField setStatusDelegate:self];
        [self.statusTextField setSelector:@selector(statusForGroupInfo)];
        [self.statusTextField setFrameOrigin:NSMakePoint(236, 7)];
        [self addSubview:self.statusTextField];
        
        self.kickButton = [[TMButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - image_kick().size.width - 34, 10, image_kick().size.width, image_kick().size.height)];
        [self.kickButton setAutoresizingMask:NSViewMinXMargin];
        [self.kickButton setImage:image_kick() forState:TMButtonNormalState];
        [self.kickButton setImage:image_kick() forState:TMButtonPressedState];
        [self.kickButton setTarget:self selector:@selector(kickPressed)];
        [self addSubview:self.kickButton];
        
    }
    return self;
}

- (void)kickPressed {
    ChatParticipantItem *item = (ChatParticipantItem *)self.rowItem;
    [self setBlocked:YES];
    [item.viewController kickParticipantByItem:item];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.row == 1) {
        ChatParticipantItem *item = (ChatParticipantItem *) self.rowItem;
        
        [item.membersCount drawAtPoint:NSMakePoint(160 - item.membersCount.size.width, 28)];
        [item.onlineCount drawAtPoint:NSMakePoint(160 - item.onlineCount.size.width, 10)];
    }
    
}


- (void)setBlocked:(BOOL)isBlocked {
    if(isBlocked) {
        [self.nameTextField setSelected:YES];
        [self.statusTextField setSelected:YES];
        self.avatarImageView.layer.opacity = 0.5;
        [self.kickButton setAlphaValue:0.5];
        [self.kickButton setDisabled:YES];
    } else {
        [self.nameTextField setSelected:NO];
        [self.statusTextField setSelected:NO];
        self.avatarImageView.layer.opacity = 1;
        [self.kickButton setAlphaValue:1];
        [self.kickButton setDisabled:NO];
    }
}



- (void)redrawRow {
    ChatParticipantItem *item = (ChatParticipantItem *)self.rowItem;
    
    [self setBlocked:item.isBlocking];
    if(item.isCanKicked) {
        [self.kickButton setHidden:NO];
    } else {
        [self.kickButton setHidden:YES];
    }
    
    [self.avatarImageView setUser:item.user];
    [self.nameTextField setUser:item.user];
    [self.statusTextField setUser:item.user];
    
    [self setNeedsDisplay:YES];
}

- (void) TMNameTextFieldDidChanged:(TMNameTextField *)textField {
    [self.nameTextField sizeToFit];
}

- (void) TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [self.statusTextField sizeToFit];
}


@end
