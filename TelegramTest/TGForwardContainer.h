//
//  TGForwardContainer.h
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGForwardObject.h"
@interface TGForwardContainer : TMView

@property (nonatomic,copy) dispatch_block_t deleteHandler;
@property (nonatomic,strong) TGForwardObject *fwdObject;

@end
