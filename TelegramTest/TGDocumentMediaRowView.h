//
//  TGDocumentMediaRowView.h
//  Telegram
//
//  Created by keepcoder on 27.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowView.h"
#import "MessageTableCell.h"
@interface TGDocumentMediaRowView : MessageTableCell


@property (nonatomic,assign,getter=isSelected) BOOL selected;

-(void)setEditable:(BOOL)editable animated:(BOOL)animated;

@end
