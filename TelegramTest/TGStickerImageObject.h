//
//  TGStickerImageObject.h
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGImageObject.h"

@interface TGStickerImageObject : TGImageObject

-(id)initWithMessage:(TL_localMessage *)message placeholder:(NSImage *)placeholder;
@end
