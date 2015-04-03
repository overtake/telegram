//
//  GeneralSettingsBlockHeaderView.h
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowView.h"

@interface GeneralSettingsBlockHeaderItem : TMRowItem
@property (nonatomic,strong,readonly) NSAttributedString *header;
@property (nonatomic,assign) int height;
@property (nonatomic,assign) BOOL isFlipped;

@end


@interface GeneralSettingsBlockHeaderView : TMRowView


@end
