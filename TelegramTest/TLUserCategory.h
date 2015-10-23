//
//  TLUser.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"

typedef enum {
    TLUserTypeContact,
    TLUserTypeEmpty,
    TLUserTypeDeleted,
    TLUserTypeForeign,
    TLUserTypeSelf,
    TLUserTypeRequest,
    TLUserTypeBot
} TLUserType;

@interface TLUser (Category)

- (TLUserType)type;
- (void)setType:(TLUserType)type;
- (TLUserType)rebuildType;
- (BOOL)isOnline;
- (BOOL)isBlocked;
- (void)rebuildNames;
- (void)rebuidStatuses;


-(BOOL)isBot;

-(BOOL)needFullUpdate;
-(void)fullUpdated;

- (NSString *)fullName;
- (NSString *)phoneWithFormat;

- (NSAttributedString *)dialogTitle;

- (NSSize)dialogTitleSize;
- (NSSize)dialogEncryptedTitleSize;
- (NSAttributedString *)dialogTitleEncrypted;
- (NSAttributedString *)chatInfoTitle;

- (NSAttributedString *)profileTitle;

- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)encryptedTitleForMessage;

//Statuses
- (NSAttributedString *)statusAttributedString;
- (NSAttributedString *)statusForMessagesHeaderView;
- (NSAttributedString *)statusForUserInfoView;
- (NSAttributedString *)statusForGroupInfo;
- (NSAttributedString *)statusForSearchTableView;
- (NSAttributedString *)statusForProfile;


- (NSAttributedString *)userNameTitle;
- (NSAttributedString *)userNameProfileTitle;
- (NSAttributedString *)userNameSearchTitle;
- (int)lastSeenUpdate;
- (void)setLastSeenUpdate:(int)seenUpdate;


- (NSString *)dialogFullName;
- (TLInputPeer *)inputPeer;
- (TLInputUser *)inputUser;
- (NSString *)lastSeen;
- (int)lastSeenTime;
- (TL_conversation *)dialog;
- (TL_contact *)contact;


@end
