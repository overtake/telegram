//
//  UserInfoEditContainerView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoEditContainerView.h"
#import "UserInfoShortTextEditView.h"
#import "UserInfoShortButtonView.h"
#import "Telegram.h"

@interface UserInfoEditContainerView()
@property (nonatomic, strong) UserInfoShortTextEditView *firstNameView;
@property (nonatomic, strong) UserInfoShortTextEditView *lastNameView;
@property (nonatomic, strong) UserInfoShortButtonView *clearChatHistoryButton;
@property (nonatomic, strong) UserInfoShortButtonView *deleteContactButton;
@property (nonatomic, strong) UserInfoShortButtonView *blockContactButton;
@end

@implementation UserInfoEditContainerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float offsetY = self.bounds.size.height - 65;
        float offsetRight = self.bounds.size.width - 200;
        float width = self.bounds.size.width - 285;
        
        self.firstNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
        [self.firstNameView setFrameOrigin:NSMakePoint(185, offsetY)];
        [self.firstNameView setFrameSize:NSMakeSize(width, 35)];
   
        [self addSubview:self.firstNameView];

        self.lastNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
        [self.lastNameView setFrameOrigin:NSMakePoint(185, offsetY - self.firstNameView.bounds.size.height)];
        [self.lastNameView setFrameSize:NSMakeSize(width, 35)];
        [self addSubview:self.lastNameView];
        
        [self.firstNameView.textView setNextKeyView:self.lastNameView.textView];
        [self.firstNameView.textView setTarget:self];
        [self.firstNameView.textView setAction:@selector(enterClick)];
        
        [self.lastNameView.textView setNextKeyView:self.firstNameView.textView];
        [self.lastNameView.textView setTarget:self];
        [self.lastNameView.textView setAction:@selector(enterClick)];
        
        weakify();

        self.clearChatHistoryButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Conversation.Delete", nil) tapBlock:^{
            [[Telegram rightViewController].messagesViewController deleteDialog:strongSelf.user.dialog];
        }];
        self.clearChatHistoryButton.textButton.textColor = NSColorFromRGB(0xe07676);
        [self addSubview:self.clearChatHistoryButton];
        [self.clearChatHistoryButton setFrameSize:NSMakeSize(offsetRight, 42)];


        self.deleteContactButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.DeleteContact", nil) tapBlock:^{
            [[NewContactsManager sharedManager] deleteContact:self.user completeHandler:^(BOOL result) {
                [strongSelf.controller successDeleteContact];
            }];
        }];
        self.deleteContactButton.textButton.textColor = NSColorFromRGB(0xe07676);
        [self addSubview:self.deleteContactButton];
        [self.deleteContactButton setFrameSize:NSMakeSize(offsetRight, 42)];



        [self buildPage];
        
        [Notification addObserver:self selector:@selector(userBlockChanged:) name:USER_BLOCK];
      
      
        [Notification addObserver:self selector:@selector(userNameChangedNotification:) name:USER_UPDATE_NAME];
    }
    return self;
}

- (void)buildPage {
    if(self.type != UserInfoViewControllerAddContact && self.user.type != TLUserTypeSelf) {
        [self.clearChatHistoryButton setHidden:NO];
        [self.deleteContactButton setHidden:NO];

        float offset = self.bounds.size.height - 180;
        [self.clearChatHistoryButton setFrameOrigin:NSMakePoint(100, offset)];
        
        offset -= self.clearChatHistoryButton.bounds.size.height;
        [self.deleteContactButton setFrameOrigin:NSMakePoint(100, offset)];
        

    } else {
        [self.clearChatHistoryButton setHidden:YES];
        [self.deleteContactButton setHidden:YES];
    }
    
    [self.clearChatHistoryButton setNeedsDisplay:YES];
    [self.deleteContactButton setNeedsDisplay:YES];
}

- (void)enterClick {
    TMView *rightView = [Telegram rightViewController].messagesViewController.navigationViewController.nagivationBarView.rightView;
    if(rightView) {
        if(rightView.subviews.count == 2) {
            TMTextButton *button = [rightView.subviews objectAtIndex:0];
            if(button && button.tapBlock)
                button.tapBlock();
        }
    }
}

- (void)userBlockChanged:(NSNotification *)notify {
    TLContact *user = notify.userInfo[KEY_USER];
    
    if(user.user_id == self.user.n_id) {
        [self.blockContactButton.textButton setStringValue:self.user.isBlocked ? NSLocalizedString(@"User.Unlock", nil) : NSLocalizedString(@"User.Block", nil)];
        [self.blockContactButton.textButton sizeToFit];
    }
}

- (void)userNameChangedNotification:(NSNotification *)notify {
    TLUser *user = [notify.userInfo objectForKey:KEY_USER];
    if(user.n_id == self.user.n_id) {
        [self setUser:user];
    }
}

- (TL_inputPhoneContact *)newContact {
    NSString *first_name = self.firstNameView.textView.stringValue;
    NSString *last_name = self.lastNameView.textView.stringValue;
    
    if(self.type == UserInfoViewControllerEdit && [first_name isEqualToString:self.user.first_name] && [last_name isEqualToString:self.user.last_name])
        return nil;
    
    return [TL_inputPhoneContact createWithClient_id:0 phone:self.user.phone first_name:first_name last_name:last_name];
}

- (void)setType:(UserInfoViewControllerType)type {
    self->_type = type;
    
    [self setUser:self->_user];
}

- (void)setUser:(TLUser *)user {
    self->_user = user;
    
    [self.blockContactButton.textButton setStringValue:user.isBlocked ? NSLocalizedString(@"User.Unlock", nil) : NSLocalizedString(@"User.Block", nil)];
    [self.blockContactButton.textButton sizeToFit];
    
    [self.blockContactButton setHidden:user.type == TLUserTypeSelf];
    
    [self.firstNameView.textView setStringValue:user.first_name ? user.first_name : @""];
    [self.lastNameView.textView setStringValue:user.last_name ? user.last_name : @""];
    
}

- (BOOL)becomeFirstResponder {
    [self.window makeFirstResponder:self.firstNameView.textView];
    
    
    NSText *textEditor = [self.window fieldEditor:YES forObject:self.firstNameView.textView];
    NSRange range = NSMakeRange(self.firstNameView.textView.stringValue.length, 0);
    [textEditor setSelectedRange:range];
    
    return YES;
}

@end
