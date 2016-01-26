//
//  TGAllStickersTableView.h
//  Telegram
//
//  Created by keepcoder on 25.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTableView.h"


@interface TGAllStickersTableView : TMTableView

@property (nonatomic,assign,readonly) BOOL hasRecentStickers;

-(void)removeSticker:(TL_outDocument *)document;
-(void)load:(BOOL)force;

@property (nonatomic,strong) dispatch_block_t didNeedReload;

-(void)showWithStickerPack:(TL_messages_stickerSet *)stickerPack;

-(NSArray *)allStickers;
-(NSArray *)sets;

-(void)updateSets:(NSArray *)sets;

-(void)scrollToStickerPack:(long)packId;

@end
