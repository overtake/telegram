//
//  TGMentionPopup.h
//  Telegram
//
//  Created by keepcoder on 02.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGMentionPopup : NSObject


+(void)show:(NSString *)string chat:(TLChat *)chat view:(NSView *)view ofRect:(NSRect)rect callback:(void (^)(NSString *userName))callback;

+(BOOL)isVisibility;

+(void)selectNext;
+(void)selectPrev;

+(void)performSelected;

+(void)close;

@end
