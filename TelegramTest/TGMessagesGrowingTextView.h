//
//  TGMessagesGrowingTextView.h
//  Telegram
//
//  Created by keepcoder on 20/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernGrowingTextView.h"

@interface TGMessagesGrowingTextView : TGModernGrowingTextView

@property (nonatomic,assign,readonly) BOOL isInline;
-(void)setInline:(BOOL)isInline placeHolder:(NSAttributedString *)placeholder;
@end
