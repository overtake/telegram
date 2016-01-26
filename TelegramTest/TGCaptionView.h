//
//  TGCaptionView.h
//  Telegram
//
//  Created by keepcoder on 29.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "MessageTableItem.h"
#import "TGCTextView.h"
@interface TGCaptionTextView : TGCTextView
@property (nonatomic,weak) MessageTableItem *item;
@end

@interface TGCaptionView : TMView
@property (nonatomic,strong,readonly) TGCaptionTextView *textView;
-(void)setAttributedString:(NSAttributedString *)string fieldSize:(NSSize)size;
@property (nonatomic,weak) MessageTableItem *item;
@end
