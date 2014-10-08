//
//  SearchMessagesView.h
//  Telegram
//
//  Created by keepcoder on 07.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface SearchMessagesView : TMView

@property (nonatomic,strong) MessagesViewController *controller;

-(void)showSearchBox:(void (^)(NSString *search))callback next:(dispatch_block_t)nextCallback prevCallback:(dispatch_block_t)prevCallback closeCallback:(dispatch_block_t) closeCallback;


@end
