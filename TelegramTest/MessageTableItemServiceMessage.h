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
    MessageTableItemServiceMessageDate
} MessageTableItemServiceMessageType;

@interface MessageTableItemServiceMessage : MessageTableItem

- (id) initWithDate:(int)date;

@property (nonatomic, strong) NSAttributedString *messageAttributedString;

@property (nonatomic) MessageTableItemServiceMessageType type;

@property (nonatomic, strong) TGPhoto *photo;
@property (nonatomic) NSSize photoSize;
@property (nonatomic, strong) TGFileLocation *photoLocation;
@property (nonatomic, strong) NSImage *cachePhoto;

@property (nonatomic,strong) TGImageObject *imageObject;
@end
