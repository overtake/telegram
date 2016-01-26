//
//  TGProfileParamItem.h
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGProfileParamItem : TGGeneralRowItem


@property (nonatomic,strong) NSString *header;
@property (nonatomic,strong) NSAttributedString *value;

@property (nonatomic,assign) NSSize size;

-(void)setHeader:(NSString *)header withValue:(NSString *)value;
@end
