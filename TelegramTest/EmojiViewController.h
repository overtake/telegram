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

@property (nonatomic,weak) MessagesViewController *messagesViewController;

+(void)reloadStickers;
+(void)loadStickersIfNeeded;

+(NSArray *)allStickers;
+(NSArray *)allSets;
+(TL_stickerSet *)setWithId:(long)n_id;
+(NSArray *)stickersWithId:(long)n_id;
-(void)saveModifier:(NSString *)modifier forEmoji:(NSString *)emoji;

-(NSString *)emojiModifier:(NSString *)emoji;

@end
