//
//  TGTextLabel.h
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGFont.h"
@interface TGTextLabel : TMView


- (instancetype)initWithText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth;
- (instancetype)initWithText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth truncateInTheMiddle:(bool)truncateInTheMiddle;



- (void)setText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth;
- (void)setText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth needsContentUpdate:(bool *)needsContentUpdate;
- (void)setText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth height:(int)height;
- (NSAttributedString *)text;
- (void)setMaxWidth:(CGFloat)maxWidth;
@end
