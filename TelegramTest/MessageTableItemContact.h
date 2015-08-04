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

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) TLUser *contactUser;
@property (nonatomic, strong) NSString *contactText;
@property (nonatomic, strong) NSString *contactName;
@property (nonatomic, assign) NSSize contactNameSize;
@property (nonatomic, strong) NSAttributedString *contactNumber;
@property (nonatomic, strong) NSString *contactNumberString;

@property (nonatomic) NSSize contactNumberSize;
@property (nonatomic) int user_id;

@end
