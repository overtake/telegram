//
//  ComposeActionSelectBehavior.h
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionBehavior.h"

@interface ComposeActionCustomBehavior : ComposeActionBehavior


@property (nonatomic,strong) dispatch_block_t composeDone;
@property (nonatomic,strong) dispatch_block_t composeChangeSelected;
@property (nonatomic,strong) dispatch_block_t composeCancel;

@property (nonatomic,strong) NSString *customDoneTitle;
@property (nonatomic,strong) NSString *customCenterTitle;


@end
