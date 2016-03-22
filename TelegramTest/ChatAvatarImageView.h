//
//  ChatAvatarImageView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAvatarImageView.h"
@class ChatInfoViewController;

@interface ChatAvatarImageView : TMAvatarImageView

typedef enum {
    ChatAvatarSourceUser,
    ChatAvatarSourceGroup,
    ChatAvatarSourceBroadcast,
    ChatAvatarSourceChannel
} ChatAvatarSourceType;


@property (nonatomic,assign) ChatAvatarSourceType sourceType;


@property (nonatomic,assign,getter=isEditable) BOOL editable;

- (void)rebuild;
- (void)showUpdateChatPhotoBox;
@end
