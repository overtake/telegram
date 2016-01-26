//
//  TGRecentTableItem.h
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGRecentSearchRowItem : TMRowItem
@property (nonatomic,strong,readonly) TL_conversation *conversation;
@end
