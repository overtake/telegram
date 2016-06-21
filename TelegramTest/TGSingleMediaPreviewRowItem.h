//
//  TGSingleMediaPreviewRowItem.h
//  Telegram
//
//  Created by keepcoder on 21/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGSingleMediaPreviewRowItem : TGGeneralRowItem


-(id)initWithObject:(id)object ptype:(PasteBoardItemType)ptype;

@property (nonatomic,strong,readonly) NSAttributedString *text;
@property (nonatomic,assign,readonly) NSSize textSize;

@property (nonatomic,assign,readonly) PasteBoardItemType ptype;
@property (nonatomic,strong,readonly) NSImage *thumbImage;

@end
