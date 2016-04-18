//
//  MessageTableItemContact.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "MessageTableItemContact.h"

@interface MessageTableItemContact : MessageTableItem


@property (nonatomic, strong) TLUser *contactUser;
@property (nonatomic, strong) NSString *contactText;

@property (nonatomic,strong) NSString *fullName;

@property (nonatomic) NSSize textSize;
@property (nonatomic,strong) NSAttributedString *attributedText;
@property (nonatomic) int user_id;

@end
