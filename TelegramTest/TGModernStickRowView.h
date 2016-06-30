//
//  TGModernStickRowView.h
//  Telegram
//
//  Created by keepcoder on 21/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowView.h"
#import "TGTextLabel.h"

@interface TGModernStickRowView : TMRowView
@property (nonatomic,assign) BOOL isStickView;
@property (nonatomic,strong,readonly) TGTextLabel *textLabel;
@end
