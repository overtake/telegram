//
//  MessageTableItemSticker.h
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "TGStickerImageObject.h"
@interface MessageTableItemSticker : MessageTableItem
@property (nonatomic,strong) TGStickerImageObject *imageObject;
@end
