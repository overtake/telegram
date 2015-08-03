//
//  TGSharedLinkRowView.h
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowView.h"
#import "MessageTableCell.h"
@interface TGSharedLinkRowView : MessageTableCell
@property (nonatomic,assign,getter=isSelected) BOOL selected;

-(void)setEditable:(BOOL)editable animated:(BOOL)animated;

@end
