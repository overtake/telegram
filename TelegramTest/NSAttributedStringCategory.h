//
//  NSAttributedStringGeometrySizes.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Category)

typedef enum {
    CoreTextSizeExpectEmojiType = 2
} CoreTextSizeExpectType;

- (NSSize)sizeForTextFieldForWidth:(int)width;
- (NSSize)coreTextSizeForTextFieldForWidth:(int)width;
- (NSSize)coreTextSizeForTextFieldForWidth:(int)width withPaths:(NSArray *)paths;


- (NSSize)coreTextSizeOneLineForWidth:(int)width;
- (NSSize)coreTextSizeOneLineForWidth:(int)width expectType:(CoreTextSizeExpectType)expectType;



- (NSRange)range;

-(NSRange)selectRange:(NSSize)frameSize startPoint:(NSPoint)startPoint currentPoint:(NSPoint)currentPoint;



@end
