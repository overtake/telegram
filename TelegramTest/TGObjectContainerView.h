//
//  TGUserContainerView.h
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
@interface TGObjectContainerView : TMRowView


typedef enum {
    TGObjectContainerViewTypeEditable,
    TGObjectContainerViewSelectable
} TGObjectContainerViewType;


-(void)setEditable:(BOOL)editable animated:(BOOL)animated;

@end
