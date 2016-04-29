//
//  TGReplyObject.h
//  Telegram
//
//  Created by keepcoder on 11.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGReplyObject : NSObject

@property (nonatomic,strong,readonly) NSAttributedString *replyHeader;
@property (nonatomic,strong,readonly) TGImageObject *replyThumb;
@property (nonatomic,strong,readonly) NSAttributedString *replyText;

@property (nonatomic,strong,readonly) NSURL *geoURL;

@property (nonatomic,assign,readonly) int replyHeight;
@property (nonatomic,assign,readonly) int replyHeaderHeight;
@property (nonatomic,assign,readonly) int containerHeight;

@property (nonatomic,assign,readonly,getter=isPinnedMessage) BOOL pinnedMessage;
@property (nonatomic,assign,readonly,getter=isEditMessage) BOOL editMessage;

@property (nonatomic,strong,readonly) TL_localMessage *replyMessage;

@property (nonatomic,strong) TL_localMessage *fromMessage;

@property (nonatomic,weak) MessageTableItem *item;

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item;
-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item withoutCache:(BOOL)withoutCache;
-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item pinnedMessage:(BOOL)pinnedMessage;
-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item editMessage:(BOOL)editMessage;

+(void)loadReplyMessage:(TL_localMessage *)fromMessage completionHandler:(void (^)(TL_localMessage *message))completionHandler;

@end
