//
//  SearchMessagesView.h
//  Telegram
//
//  Created by keepcoder on 07.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface SearchMessagesView : TMView

@property (nonatomic,weak) MessagesViewController *controller;

-(void)showSearchBox:( void (^)(TL_localMessage *msg, NSString *searchString))callback closeCallback:(dispatch_block_t) closeCallback;

-(NSString *)currentString;


@end
