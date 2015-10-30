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


@property (nonatomic,assign) int avatarHeight;
@property (nonatomic,strong) NSString *status;

@property (nonatomic,strong) dispatch_block_t stateCallback;

-(id)initWithUser:(TLUser *)user;

@end
