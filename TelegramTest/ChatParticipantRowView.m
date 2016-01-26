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
@property (nonatomic, strong) TMTextButton *kickButton;
@end

@implementation ChatParticipantRowView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImageView = [TMAvatarImageView standartNewConversationTableAvatar];
        
        [self.avatarImageView setFrameSize:NSMakeSize(36, 36)];
        
        [self.avatarImageView setFrameOrigin:NSMakePoint(100, 7)];
        
        
        [self addSubview:self.avatarImageView];
        
        self.nameTextField = [[TMNameTextField alloc] init];
        self.nameTextField.nameDelegate = self;
        [self.nameTextField setSelector:@selector(chatInfoTitle)];
        [self.nameTextField setFrameOrigin:NSMakePoint(146, 26)];
        [self addSubview:self.nameTextField];
        
        self.statusTextField = [[TMStatusTextField alloc] init];
        [self.statusTextField setStatusDelegate:self];
        [self.statusTextField setSelector:@selector(statusForGroupInfo)];
        [self.statusTextField setFrameOrigin:NSMakePoint(146, 8)];
        [self addSubview:self.statusTextField];
        
        self.kickButton = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Chat.Kick", nil)];
        [self.kickButton setAutoresizingMask:NSViewMinXMargin];
        [self.kickButton setDisableColor:GRAY_TEXT_COLOR];
        
        
        [self.kickButton setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.kickButton.frame), roundf((50 - NSHeight(self.kickButton.frame))/2))];
        
        
        weak();
        
        [self.kickButton setTapBlock:^{
            [weakSelf kickPressed];
        }];
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
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(146, 0, NSWidth(self.frame) - 246, 1));

}


- (void)setBlocked:(BOOL)isBlocked {
    if(isBlocked) {
        [self.nameTextField setSelected:YES];
        [self.statusTextField setSelected:YES];
        self.avatarImageView.layer.opacity = 0.5;
        [self.kickButton setAlphaValue:0.5];
        [self.kickButton setDisable:YES];
    } else {
        [self.nameTextField setSelected:NO];
        [self.statusTextField setSelected:NO];
        self.avatarImageView.layer.opacity = 1;
        [self.kickButton setAlphaValue:1];
        [self.kickButton setDisable:NO];
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
    [self setFrameSize:self.frame.size];
}

- (void) TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [self.statusTextField sizeToFit];
    [self setFrameSize:self.frame.size];
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - (self.kickButton.isHidden ? 238 : 270), NSHeight(self.nameTextField.frame))];
    [self.statusTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - (self.kickButton.isHidden ? 238 : 270), NSHeight(self.nameTextField.frame))];
}

@end
