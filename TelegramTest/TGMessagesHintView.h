//
//  TGMessagesHintView.h
//  Telegram
//
//  Created by keepcoder on 29.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGView.h"

@interface TGMessagesHintView : TGView




-(void)showCommandsHintsWithChat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler;
-(void)showHashtagHitsWithQuery:(NSString *)query choiceHandler:(void (^)(NSString *result))choiceHandler;
-(void)showMentionPopupWithChat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler;

+(void)selectNext;
+(void)selectPrev;

@end
