//
//  TGStickerPackEmojiController.h
//  Telegram
//
//  Created by keepcoder on 08.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGAllStickersTableView.h"
@class TGModernESGViewController;
@interface TGStickerPackEmojiController : TMView

@property (nonatomic,weak) TGModernESGViewController *esgViewController;
@property (nonatomic,strong,readonly) TGAllStickersTableView *stickers;

-(instancetype)initWithFrame:(NSRect)frameRect packHeight:(int)packHeight;

-(void)reload;
-(void)removeAllItems;

@end
