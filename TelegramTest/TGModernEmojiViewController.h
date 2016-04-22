//
//  TGModernESGViewController.h
//  Telegram
//
//  Created by keepcoder on 19/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@class TGModernESGViewController;

@interface TGModernEmojiViewController : TMViewController

@property (nonatomic,weak) TGModernESGViewController *esgViewController;


@property (nonatomic,weak) MessagesViewController *messagesViewController;
@property (nonatomic,weak) RBLPopover *epopover;

@property (nonatomic, strong) void (^insertEmoji) (NSString *emoji);


-(void)saveModifier:(NSString *)modifier forEmoji:(NSString *)emoji;
-(NSString *)emojiModifier:(NSString *)emoji;
- (void)insertEmoji:(NSString *)emoji;

+ (void)saveEmoji:(NSArray *)array;


- (void)show;
- (void)close;

@end
