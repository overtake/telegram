//
//  TGMessagesHintView.h
//  Telegram
//
//  Created by keepcoder on 29.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGView.h"

@interface TGMessagesHintView : TGView


typedef enum {
    TGHintViewShowTypeNone = 0,
    TGHintViewShowMentionType =1,
    TGHintViewShowHashtagType = 2,
    TGHintViewShowBotCommandType = 3
} TGHintViewShowType;

@property (nonatomic,weak) MessagesViewController *messagesViewController;


-(void)showCommandsHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation botInfo:(NSArray *)botInfo choiceHandler:(void (^)(NSString *result,id object))choiceHandler;
-(void)showHashtagHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation peer_id:(int)peer_id choiceHandler:(void (^)(NSString *result,id object))choiceHandler;
-(void)showMentionPopupWithQuery:(NSString *)query conversation:(TL_conversation *)conversation chat:(TLChat *)chat allowInlineBot:(BOOL)allowInlineBot choiceHandler:(void (^)(NSString *result,id object))choiceHandler;
-(void)showMentionPopupWithQuery:(NSString *)query conversation:(TL_conversation *)conversation chat:(TLChat *)chat allowInlineBot:(BOOL)allowInlineBot allowUsernameless:(BOOL)allowUsernameless choiceHandler:(void (^)(NSString *result,id object))choiceHandler;

-(void)showContextPopupWithQuery:(NSString *)bot query:(NSString *)query conversation:(TL_conversation *)conversation acceptHandler:(void (^)(TLUser *user))acceptHandler;

-(void)cancel;

-(void)selectNext;
-(void)selectPrev;

-(void)hide;

-(void)performSelected;

+(TGHintViewShowType)needShowHint:(NSString *)string selectedRange:(NSRange)selectedRange completeString:(NSString **)completeString searchString:(NSString **)searchString;

@end
