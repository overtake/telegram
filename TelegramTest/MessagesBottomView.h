//
//  MessagesBottomView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

typedef enum {
    MessagesBottomViewNormalState,
    MessagesBottomViewActionsState,
    MessagesBottomViewBlockSecretState,
    MessagesBottomViewBlockChat
} MessagesBottomViewState;

@class MessagesViewController;

@interface MessagesBottomView : BTRControl<TMGrowingTextViewDelegate, NSMenuDelegate>


@property (nonatomic) BOOL forwardEnabled;
@property (nonatomic) MessagesBottomViewState stateBottom;
@property (nonatomic, strong) MessagesViewController *messagesViewController;
@property (nonatomic, strong) TL_conversation *dialog;

- (void)setState:(MessagesBottomViewState)state animated:(BOOL)animated;

- (void)setInputMessageString:(NSString *)message disableAnimations:(BOOL)disableAnimations;
- (NSString *)inputMessageString;
- (void)setSectedMessagesCount:(NSUInteger)count;

-(void)closeEmoji;

@end
