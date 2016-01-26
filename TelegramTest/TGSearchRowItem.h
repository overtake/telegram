//
//  TGSearchRowItem.h
//  Telegram
//
//  Created by keepcoder on 30.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TGGeneralRowItem.h"
@interface TGSearchRowItem : TGGeneralRowItem

@property (nonatomic,weak) id<TMSearchTextFieldDelegate> delegate;

@end
