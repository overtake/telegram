//
//  TGModernMessagesBottomView.h
//  Telegram
//
//  Created by keepcoder on 11/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGModernMessagesBottomView : BTRControl


typedef enum {
    TGModernMessagesBottomViewNormalState,
    TGModernMessagesBottomViewActionsState,
    TGModernMessagesBottomViewBlockChat,
    TGModernMessagesBottomViewRecordAudio
} TGModernMessagesBottomViewState;


-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController;

@property (nonatomic,assign,readonly) TGModernMessagesBottomViewState actionState;
@property (nonatomic,strong,readonly) TGInputMessageTemplate *inputTemplate;

-(void)setActionState:(TGModernMessagesBottomViewState)actionState;
-(void)setActionState:(TGModernMessagesBottomViewState)actionState animated:(BOOL)animated;
-(void)setInputTemplate:(TGInputMessageTemplate *)inputTemplate animated:(BOOL)animated;
- (void)setSectedMessagesCount:(NSUInteger)count deleteEnable:(BOOL)deleteEnable forwardEnable:(BOOL)forwardEnable;

@property (nonatomic,assign) BOOL animates;

- (instancetype)init __attribute__((unavailable("init not available, call initWithFrame:messagesController:")));
- (instancetype)initWithFrame:(NSRect)frameRect __attribute__((unavailable("initWithFrame: not available, call initWithFrame:messagesController:")));
- (instancetype)initWithCoder:(NSCoder *)coder __attribute__((unavailable("initWithCoder: not available, call initWithFrame:messagesController:")));


@end
