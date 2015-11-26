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

@property (nonatomic,strong,readonly) TL_localMessage *replyMessage;

@property (nonatomic,strong,readonly) TL_localMessage *fromMessage;

@property (nonatomic,weak,readonly) MessageTableItem *item;

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item;

@end
