//
//  CompressedDocumentSenderItem.h
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "DocumentSenderItem.h"

@interface CompressedDocumentSenderItem : DocumentSenderItem
-(id)initWithItem:(TGCompressItem *)compressItem additionFlags:(int)additionFlags;
@end
