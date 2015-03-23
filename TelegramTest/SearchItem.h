//
//  SearchItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMElements.h"

typedef enum {
    SearchItemChat,
    SearchItemConversation,
    SearchItemUser,
    SearchItemMessage,
    SearchItemGlobalUser,
    SearchHashtag
} SearchItemType;

@interface SearchItem : TMRowItem

@property (nonatomic, strong) TL_conversation *conversation;

@property (nonatomic) SearchItemType type;

@property (nonatomic, strong) NSMutableAttributedString *date;
@property (nonatomic) NSSize dateSize;
@property (nonatomic, strong) TL_localMessage *message;
@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) TLChat *chat;
@property (nonatomic, strong) TLEncryptedChat *encryptedChat;

@property (nonatomic, strong) NSMutableAttributedString *title;
@property (nonatomic, strong) NSMutableAttributedString *status;


- (id)initWithUserItem:(TLUser *)user searchString:(NSString *)searchString;
- (id)initWithGlobalItem:(TLUser*)user searchString:(NSString *)searchString;
- (id)initWithChatItem:(TLChat *)chat searchString:(NSString *)searchString;
- (id)initWithMessageItem:(TLMessage *)message searchString:(NSString *)searchString;
- (id)initWithDialogItem:(TL_conversation *)dialog searchString:(NSString *)searchString;
@end
