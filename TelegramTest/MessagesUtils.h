//
//  MessagesUtils.h
//  TelegramTest
//
//  Created by keepcoder on 04.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagesUtils : NSObject
+(NSString *)serviceMessage:(TLMessage *)message forAction:(TLMessageAction *)action;
+(NSAttributedString *)serviceAttributedMessage:(TLMessage *)message forAction:(TLMessageAction *)action;
+(NSString *)mediaMessage:(TLMessage *)message;
+(NSColor *)colorForUserId:(int)uid;
+(NSImage *)dialogPhotoForUid:(int)uid;
+(NSImage *)messagePhotoForUid:(int)uid;
+(NSString *)selfDestructTimer:(int)ttl;
+(NSString *)shortTTL:(int)ttl;
+(NSMutableAttributedString *)conversationLastText:(TLMessage *)message conversation:(TL_conversation *)conversation;

+(NSString *)muteUntil:(int)mute_until;

+(NSDictionary *)conversationLastData:(TL_conversation *)conversation;


@end
