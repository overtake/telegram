//
//  TGStickerPackModalView.h
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModalView.h"

@interface TGStickerPackModalView : TGModalView

@property (nonatomic,assign) BOOL canSendSticker;

-(void)setStickerPack:(TL_messages_stickerSet *)stickerPack;

@end
