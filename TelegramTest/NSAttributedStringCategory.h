//
//  NSAttributedStringGeometrySizes.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Category)

- (NSSize)sizeForTextFieldForWidth:(int)width;
- (NSSize)coreTextSizeForTextFieldForWidth:(int)width;

- (NSRange)range;

-(NSRange)selectRange:(NSSize)frameSize startPoint:(NSPoint)startPoint currentPoint:(NSPoint)currentPoint;

@end
