//
//  MessagesUtils.h
//  TelegramTest
//
//  Created by keepcoder on 04.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagesUtils : NSObject
+(NSString *)serviceMessage:(TGMessage *)message forAction:(TGMessageAction *)action;
+(NSAttributedString *)serviceAttributedMessage:(TGMessage *)message forAction:(TGMessageAction *)action;
+(NSString *)mediaMessage:(TGMessage *)message;
+(NSColor *)colorForUserId:(int)uid;
+(NSImage *)dialogPhotoForUid:(int)uid;
+(NSImage *)messagePhotoForUid:(int)uid;
+(NSString *)selfDestructTimer:(int)ttl;
+(NSString *)shortTTL:(int)ttl;
+(NSMutableAttributedString *)conversationLastText:(TGMessage *)message conversation:(TL_conversation *)conversation;




@end
