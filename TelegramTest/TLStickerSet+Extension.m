//
//  TLStickerSet+Extension.m
//  Telegram
//
//  Created by keepcoder on 21/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TLStickerSet+Extension.h"

@implementation TLStickerSet (Extension)


-(BOOL)isEqual:(TLStickerSet *)object {
    if([object isKindOfClass:[TL_stickerSet class]])
        return self.n_id == object.n_id;
    return self == object;
}

-(BOOL)isEqualTo:(TLStickerSet *)object {
    if([object isKindOfClass:[TL_stickerSet class]])
        return self.n_id == object.n_id;
    return self == object;
}

@end
