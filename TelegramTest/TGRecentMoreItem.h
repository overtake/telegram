//
//  TGRecentMoreItem.h
//  Telegram
//
//  Created by keepcoder on 27/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGRecentMoreItem : TMRowItem
@property (nonatomic,strong) NSAttributedString *attrHeader;
@property (nonatomic,strong) NSArray *otherItems;


@end
