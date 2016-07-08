//
//  TGModernSearchItem.h
//  Telegram
//
//  Created by keepcoder on 07/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGModernSearchItem : TGGeneralRowItem
@property (nonatomic,strong,readonly) TL_conversation *conversation;
@property (nonatomic,strong,readonly) NSString *selectText;

@property (nonatomic, strong,readonly) NSMutableAttributedString *status;

-(id)initWithObject:(id)object selectText:(NSString *)selectText;
@end
