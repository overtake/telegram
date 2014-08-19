//
//  SearchItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMElements.h"
#import "TGDialog+Extensions.h"

typedef enum {
    SearchItemChat,
    SearchItemUser,
    SearchItemMessage
} SearchItemType;

@interface SearchItem : TMRowItem

@property (nonatomic, strong) TL_conversation *dialog;

@property (nonatomic) SearchItemType type;

@property (nonatomic, strong) NSMutableAttributedString *date;
@property (nonatomic) NSSize dateSize;
@property (nonatomic, strong) TGMessage *message;
@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGChat *chat;
@property (nonatomic, strong) TGEncryptedChat *encryptedChat;

@property (nonatomic, strong) NSMutableAttributedString *title;
@property (nonatomic, strong) NSMutableAttributedString *status;

- (id)initWithUserItem:(TGUser *)user searchString:(NSString *)searchString;
- (id)initWithChatItem:(TGChat *)chat searchString:(NSString *)searchString;
- (id)initWithMessageItem:(TGMessage *)message searchString:(NSString *)searchString;
- (id)initWithDialogItem:(TL_conversation *)dialog searchString:(NSString *)searchString;
@end
