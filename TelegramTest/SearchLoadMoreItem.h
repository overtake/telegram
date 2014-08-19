//
//  SearchLoadMoreItem.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface SearchLoadMoreItem : TMRowItem

@property (nonatomic, strong) dispatch_block_t clickBlock;
@property (nonatomic) int num;

@end
