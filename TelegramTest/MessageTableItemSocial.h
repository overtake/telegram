//
//  MessageTableItemSocial.h
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "YoutubeServiceDescription.h"
#import "InstagramServiceDescription.h"
@interface MessageTableItemSocial : MessageTableItem


@property (nonatomic,strong,readonly) SocialServiceDescription *social;

-(id)initWithObject:(id)object socialClass:(Class)socialClass;

@end
