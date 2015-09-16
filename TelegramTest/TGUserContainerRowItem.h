//
//  TGUserContainerRowItem.h
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGUserContainerRowItem : TGGeneralRowItem


@property (nonatomic,strong,readonly) TLUser *user;

-(id)initWithUser:(TLUser *)user;

@end
