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

-(id)initWithReplyMessage:(TL_localMessage *)message;

@end
