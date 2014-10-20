//
//  TMTextButton.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"

@interface TMTextButton : TMTextField

@property (nonatomic, strong) dispatch_block_t tapBlock;

@property (nonatomic) BOOL disable;
@property (nonatomic, strong) NSColor *disableColor;

+ (instancetype)standartUserProfileButtonWithTitle:(NSString *)title;
+ (instancetype)standartUserProfileNavigationButtonWithTitle:(NSString *)title;
+ (instancetype)standartMessageNavigationButtonWithTitle:(NSString *)title;

+ (instancetype)standartButtonWithTitle:(NSString *)title standartImage:(NSImage *)image disabledImage:(NSImage *)disabledImage;

@end
