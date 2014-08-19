//
//  TGUser.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"

typedef enum {
    TGUserTypeContact,
    TGUserTypeEmpty,
    TGUserTypeDeleted,
    TGUserTypeForeign,
    TGUserTypeSelf,
    TGUserTypeRequest
} TGUserType;

@interface TGUser (Category)

- (TGUserType)type;
- (void)setType:(TGUserType)type;
- (TGUserType)rebuildType;
- (BOOL)isOnline;
- (BOOL)isBlocked;
- (void)rebuildNames;
- (void)rebuidStatuses;

- (NSString *)fullName;
- (NSString *)phoneWithFormat;

- (NSAttributedString *)dialogTitle;
- (NSAttributedString *)dialogTitleEncrypted;
- (NSAttributedString *)chatInfoTitle;

- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)encryptedTitleForMessage;

//Statuses
- (NSAttributedString *)statusAttributedString;
- (NSAttributedString *)statusForMessagesHeaderView;
- (NSAttributedString *)statusForUserInfoView;
- (NSAttributedString *)statusForGroupInfo;
- (NSAttributedString *)statusForSearchTableView;


- (int)lastSeenUpdate;
- (void)setLastSeenUpdate:(int)seenUpdate;


- (NSString *)dialogFullName;
- (TGInputPeer *)inputPeer;
- (TGInputUser *)inputUser;
- (NSString *)shortLastSeen;
- (NSString *)lastSeen;
- (int)lastSeenTime;
- (TL_conversation *)dialog;


@end
