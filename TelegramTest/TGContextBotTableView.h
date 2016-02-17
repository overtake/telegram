//
//  TGContextBotTableView.h
//  Telegram
//
//  Created by keepcoder on 22/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMTableView.h"
#import "TGSettingsTableView.h"
#import "TGContextRowItem.h"


@interface TGContextBotTableView : TGSettingsTableView


@property (nonatomic,copy) dispatch_block_t didSelectedItem;

@end
