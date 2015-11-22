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


- (NSSize)dialogTitleSize;

- (NSAttributedString *)dialogTitle;
- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)titleForChatInfo;

- (TLChatType) type;
- (void) setType:(TLChatType)type;

-(TL_conversation *)dialog;

-(TLChatFull *)chatFull;
- (NSAttributedString *)statusAttributedString;
- (NSAttributedString *)statusForMessagesHeaderView;
- (NSAttributedString *)statusForSearchTableView;

-(BOOL)left;


-(BOOL)isManager;
-(BOOL)isChannel;
-(id)inputPeer;
-(NSString *)usernameLink;



@end
