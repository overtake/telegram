//
//  TGStickerPackRowItem.h
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TGMessagesStickerImageObject.h"
#import "TGGeneralRowItem.h"
@interface TGStickerPackRowItem : TGGeneralRowItem
@property (nonatomic,strong) NSDictionary *pack;
@property (nonatomic,strong) NSAttributedString *title;
@property (nonatomic,strong) TGMessagesStickerImageObject *imageObject;
@property (nonatomic,strong) TLInputStickerSet *inputSet;
@property (nonatomic,strong) TL_stickerSet *set;
@property (nonatomic,strong) NSArray *stickers;
@end
