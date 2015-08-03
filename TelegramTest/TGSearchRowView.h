//
//  TGSearchRowView.h
//  Telegram
//
//  Created by keepcoder on 30.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowView.h"
#import "TGSearchRowItem.h"
@interface TGSearchRowView : TMRowView
@property (nonatomic,strong,readonly) TMSearchTextField *searchField;
@property(nonatomic,assign) int xOffset;

@property (nonatomic,weak) id <TMSearchTextFieldDelegate> delegate;

@end
