//
//  TGSProfileMediaRowItem.h
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGSProfileMediaRowItem : TGGeneralRowItem

@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,weak) TMViewController *controller;

@end
