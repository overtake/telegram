//
//  TMTypingObject.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGActionTyping : NSObject
@property (nonatomic,strong,readonly) TLSendMessageAction *action;
@property (nonatomic,assign,readonly) NSUInteger time;
@property (nonatomic,assign,readonly) NSUInteger user_id;
-(id)initWithAction:(TLSendMessageAction *)action time:(int)time user_id:(NSUInteger)user_id;

@end


@interface TMTypingObject : NSObject

- (id) initWithDialog:(TL_conversation *)dialog;
- (NSArray *) writeArray;

- (void) addMember:(NSUInteger)uid withAction:(TLSendMessageAction *)action;
- (void) removeMember:(NSUInteger)uid;
- (NSArray *)currentActions;
@end
