//
//  TMTypingObject.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLSendMessageAction (Extension)
-(NSComparisonResult)compare:(TLSendMessageAction *)anotherObject;
@end

@interface TGActionTyping : NSObject
@property (nonatomic,strong,readonly) TLSendMessageAction *action;
@property (nonatomic,assign,readonly) NSUInteger time;
@property (nonatomic,strong,readonly) TLUser *user;
-(id)initWithAction:(TLSendMessageAction *)action time:(int)time user:(TLUser *)user;

@end


@interface TMTypingObject : NSObject

- (id) initWithDialog:(TL_conversation *)dialog;
- (NSArray *) writeArray;

- (void) addMember:(TLUser *)user withAction:(TLSendMessageAction *)action;
- (void) removeMember:(NSUInteger)uid;
- (NSArray *)currentActions;
@end
