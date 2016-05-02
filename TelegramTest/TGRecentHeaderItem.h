//
//  TGRecentHeaderItem.h
//  Telegram
//
//  Created by keepcoder on 27/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGRecentHeaderItem : TMRowItem
@property (nonatomic,strong) NSAttributedString *attrHeader;
@property (nonatomic,strong) NSAttributedString *showMore;
@property (nonatomic,strong) NSAttributedString *showLess;


@property (nonatomic,strong) NSArray *otherItems;
@property (nonatomic,assign) BOOL isMore;

@end
