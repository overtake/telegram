//
//  EmojiViewController.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface EmojiViewController : TMViewController<NSTableViewDataSource, NSTableViewDelegate>

- (void)insertEmoji:(NSString *)emoji;
- (void)saveEmoji:(NSArray *)array;

- (void)showPopovers;
- (void)close;

@property (nonatomic, copy) void (^insertEmoji) (NSString *emoji);

+ (EmojiViewController *)instance;

+(void)reloadStickers;


@end
