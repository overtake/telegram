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

@property (nonatomic, strong) NSCache *cacheDictionary;
@property (nonatomic, strong) NSCache *smallCacheDictionary;

@property (nonatomic, strong) TGFileLocation *fileLocationBig;
@property (nonatomic, strong) TGFileLocation *fileLocationSmall;


@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGChat *chat;
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
