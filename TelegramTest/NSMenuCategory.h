//
//  NSMenuCategory.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMenu(Category)

typedef enum {
    PopUpAlignTypeLeft,
    PopUpAlignTypeRight,
    PopUpAlignTypeCenter
} PopUpAlignType;

- (void)popUpForView:(NSView *)view withType:(PopUpAlignType)type;
- (void)popUpForView:(NSView *)view;
- (void)popUpForView:(NSView *)view center:(BOOL)center;
@end
