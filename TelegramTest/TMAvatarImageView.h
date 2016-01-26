//
//  TMAvatarImageView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMAvaImageObject.h"
#import "BTRImageView.h"
@interface TMAvatarImageView : BTRImageView

typedef enum {
    TMAvatarTypeUser,
    TMAvatarTypeChat,
    TMAvatarTypeText,
    TMAvatarTypeBroadcast
} TMAvatarType;

@property (nonatomic,strong) TLFileLocation *fileLocation;

@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) TLChat *chat;
@property (nonatomic, strong) TL_broadcast *broadcast;
@property (nonatomic, strong) NSString *text;


@property (nonatomic, strong, readonly) TMAvaImageObject *imageObject;

@property (nonatomic, strong) NSFont *font;

@property (nonatomic) int offsetTextY;

typedef void (^TapTMAvatarImageView)(void);
@property (nonatomic, strong) TapTMAvatarImageView tapBlock;

+ (instancetype)standartTableAvatar;
+ (instancetype)standartHintAvatar;
+ (instancetype)standartUserInfoAvatar;
+ (instancetype)standartMessageTableAvatar;
+ (instancetype)standartNewConversationTableAvatar;
+ (instancetype)standartInfoAvatar;
+ (NSImage *)generateTextAvatar:(int)colorMask size:(NSSize)size text:(NSString *)text type:(TMAvatarType)type font:(NSFont *)font offsetY:(int)offset;

+(int)colorMask:(NSObject *)object;
+(NSString *)text:(NSObject *)object;


-(void)updateWithConversation:(TL_conversation *)conversation;

@end
