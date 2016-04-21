//
//  EmojiButton.h
//  Telegram
//
//  Created by keepcoder on 17.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "BTRButton.h"

@interface EmojiButton : TMView
@property (nonatomic, strong) NSAttributedString *smile;
@property (nonatomic, strong) NSArray<NSAttributedString *> *list;

@property (nonatomic,strong) void (^emojiCallback)(NSString *emoji);
@end
