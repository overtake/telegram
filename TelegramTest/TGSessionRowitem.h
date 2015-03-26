//
//  TGSessionRowitem.h
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGSessionRowitem : TMRowItem

@property (nonatomic,strong,readonly) TL_authorization *authorization;



@end
