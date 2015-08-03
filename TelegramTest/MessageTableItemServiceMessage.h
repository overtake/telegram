//
//  MessageTableItemServiceMessage.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/1/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageTableItem.h"
#import "TGImageObject.h"
typedef enum {
    MessageTableItemServiceMessageAction,
    MessageTableItemServiceMessageDate,
    MessagetableitemServiceMessageDescription
} MessageTableItemServiceMessageType;

@interface MessageTableItemServiceMessage : MessageTableItem

- (id) initWithDate:(int)date;

@property (nonatomic, strong) NSMutableAttributedString *messageAttributedString;

@property (nonatomic) MessageTableItemServiceMessageType type;

@property (nonatomic, strong) TLPhoto *photo;
@property (nonatomic) NSSize photoSize;
@property (nonatomic, strong) TLFileLocation *photoLocation;
@property (nonatomic, strong) NSImage *cachePhoto;
@property (nonatomic, assign) NSSize textSize;
@property (nonatomic,strong) TGImageObject *imageObject;
@end
