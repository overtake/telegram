//
//  TGContextImportantItem.h
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGContextImportantRowItem : TMRowItem

-(id)initWithObject:(id)object bot:(TLUser *)bot;
@property (nonatomic,strong,readonly) TLUser *bot;
@property (nonatomic,strong,readonly) TL_inlineBotSwitchPM *botResult;
@property (nonatomic,strong,readonly) NSAttributedString *header;
@end
