//
//  TMAvatarImageView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CAAvatarLayer.h"

@interface TMAvatarImageView : BTRImageView

@property (nonatomic,strong) TLFileLocation *fileLocation;

@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) TLChat *chat;
@property (nonatomic, strong) TL_broadcast *broadcast;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSFont *font;

@property (nonatomic) int offsetTextY;

typedef void (^TapTMAvatarImageView)(void);
@property (nonatomic, strong) TapTMAvatarImageView tapBlock;

+ (instancetype)standartTableAvatar;
+ (instancetype)standartUserInfoAvatar;
+ (instancetype)standartMessageTableAvatar;
+ (instancetype)standartNewConversationTableAvatar;

@end
