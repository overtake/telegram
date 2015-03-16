//
//  NSMenuItemCategory.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMenuItem (Category)

+ (id) menuItemWithTitle:(NSString *)title withBlock:(void (^)(id sender))block;

- (void)setBlockAction:(void (^)(id sender))block;
- (void (^)(id))blockAction;

- (void)setHighlightedImage:(NSImage *)image;
- (NSImage *)highlightedImage;

-(void)setSubtitle:(NSString *)subtitle;
-(NSString *)subtitle;
@end
