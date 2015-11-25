//
//  TGMessagesHintView.h
//  Telegram
//
//  Created by keepcoder on 29.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGView.h"

@interface TGMessagesHintView : TGView




-(void)showCommandsHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation botInfo:(NSArray *)botInfo choiceHandler:(void (^)(NSString *result))choiceHandler;
-(void)showHashtagHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation peer_id:(int)peer_id choiceHandler:(void (^)(NSString *result))choiceHandler;
-(void)showMentionPopupWithQuery:(NSString *)query conversation:(TL_conversation *)conversation chat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler;

-(void)selectNext;
-(void)selectPrev;

-(void)hide;

-(void)performSelected;

@end
