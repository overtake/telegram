//
//  NSEventCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSEvent (Category)

- (BOOL)isLeftMouseButtonClick;
- (BOOL)isRightMouseButtonClick;

@end
