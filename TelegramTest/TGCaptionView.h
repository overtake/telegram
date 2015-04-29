//
//  TGCaptionView.h
//  Telegram
//
//  Created by keepcoder on 29.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGCaptionView : TMView
@property (nonatomic,strong,readonly) TGCTextView *textView;
-(void)setAttributedString:(NSAttributedString *)string fieldSize:(NSSize)size;

@end
