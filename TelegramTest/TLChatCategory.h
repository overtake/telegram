//
//  TLChatCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"

@interface TLChat (Category)

typedef enum {
    TLChatTypeNormal,
    TLChatTypeForbidden,
    TLChatTypeEmpty
} TLChatType;

- (NSAttributedString *)dialogTitle;
- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)titleForChatInfo;

- (TLChatType) type;
- (void) setType:(TLChatType)type;

-(TL_conversation *)dialog;

-(TLChatFull *)chatFull;
-(TLInputChat *)input;
- (NSAttributedString *)statusAttributedString;
- (NSAttributedString *)statusForMessagesHeaderView;
- (NSAttributedString *)statusForSearchTableView;


-(BOOL)isAdmin;
-(BOOL)isBroadcast;
-(BOOL)isPublic;

-(NSString *)usernameLink;

@end
