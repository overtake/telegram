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

@property (nonatomic,weak) MessagesViewController *messagesViewController;

-(void)show:(NSWindow *)window animated:(BOOL)animated stickerPack:(TL_messages_stickerSet *)pack messagesController:(MessagesViewController *)messagesViewController;


@property (nonatomic,copy) dispatch_block_t addcallback;

@end
