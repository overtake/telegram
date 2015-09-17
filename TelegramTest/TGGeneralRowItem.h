//
//  TGGeneralRowItem.h
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGGeneralRowItem : TMRowItem

@property (nonatomic,assign) int height;
@property (nonatomic,assign) int xOffset;
@property (nonatomic,assign) BOOL drawsSeparator;

-(id)initWithHeight:(int)height;

-(Class)viewClass;


@end
