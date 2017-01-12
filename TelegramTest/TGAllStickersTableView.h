//
//  TGAllStickersTableView.h
//  Telegram
//
//  Created by keepcoder on 25.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTableView.h"
#import "TGStickerImageView.h"
@interface TGAllStickerTableItemView : TMRowView
@property (nonatomic,strong) TGStickerImageView *imageView;
@end

@interface TGAllStickersTableItem : TMRowItem
@property (nonatomic,strong) NSMutableArray *stickers;
@property (nonatomic,strong) NSMutableArray *objects;

@property (nonatomic,assign) long packId;

-(id)initWithObject:(NSArray *)object packId:(long)packId;
@end

@interface TGAllStickersTableView : TMTableView

@property (nonatomic,assign) BOOL hasRecentStickers;

@property (nonatomic,assign) BOOL canSendStickerAlways;

-(void)load:(BOOL)force;

@property (nonatomic,strong) dispatch_block_t didNeedReload;

-(void)showWithStickerPack:(TL_messages_stickerSet *)stickerPack;

@property (nonatomic,weak) MessagesViewController *messagesViewController;

-(NSDictionary *)allStickers;
-(NSArray *)sets;

-(void)hideStickerPreview;

-(void)updateSets:(NSArray *)sets;

-(void)scrollToStickerPack:(long)packId completionHandler:(dispatch_block_t)completionHandler;

+(void)addRecentSticker:(TLDocument *)document;

@end
