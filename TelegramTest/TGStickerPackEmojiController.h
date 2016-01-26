//
//  TGStickerPackEmojiController.h
//  Telegram
//
//  Created by keepcoder on 08.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGAllStickersTableView.h"

@interface TGStickerPackEmojiController : TMView


@property (nonatomic,strong,readonly) TGAllStickersTableView *stickers;

-(void)reload;
-(void)removeAllItems;

@end
