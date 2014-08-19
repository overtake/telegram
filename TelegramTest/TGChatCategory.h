//
//  TGChatCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"

@interface TGChat (Category)

typedef enum {
    TGChatTypeNormal,
    TGChatTypeForbidden,
    TGChatTypeEmpty
} TGChatType;

- (NSAttributedString *)dialogTitle;
- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)titleForChatInfo;

- (TGChatType) type;
- (void) setType:(TGChatType)type;

-(TL_conversation *)dialog;

- (NSAttributedString *)statusAttributedString;
- (NSAttributedString *)statusForMessagesHeaderView;
- (NSAttributedString *)statusForSearchTableView;
@end
