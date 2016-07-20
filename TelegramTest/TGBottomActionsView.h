//
//  TGBottomActionsView.h
//  Telegram
//
//  Created by keepcoder on 13/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGModernSendControlView.h"

@protocol TGBottomActionDelegate <NSObject>

-(void)_showOrHideBotKeyboardAction:(id)sender;
-(void)_changeSilentMode:(id)sender;
-(void)_insertEmoji:(NSString *)emoji;
@end


@interface TGBottomActionsView : TMView
-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController;

@property (nonatomic,weak) id <TGBottomActionDelegate> delegate;

@property (nonatomic,assign) BOOL animates;


-(SSignal *)resignal:(TGModernSendControlType)actionType;

-(void)setActiveKeyboardButton:(BOOL)active;
-(void)setActiveSilentMode:(BOOL)active;
-(void)setActiveEmoji:(BOOL)active;
-(void)setInlineProgress:(int)progress;

- (instancetype)init __attribute__((unavailable("init not available, call initWithFrame:messagesController:")));
- (instancetype)initWithFrame:(NSRect)frameRect __attribute__((unavailable("initWithFrame: not available, call initWithFrame:messagesController:")));
- (instancetype)initWithCoder:(NSCoder *)coder __attribute__((unavailable("initWithCoder: not available, call initWithFrame:messagesController:")));
@end
