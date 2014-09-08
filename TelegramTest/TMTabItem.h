//
//  TMTabItem.h
//  Telegram
//
//  Created by keepcoder on 26.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTabItem : NSObject


@property (nonatomic,strong) NSColor *selectedTextColor;
@property (nonatomic,strong) NSColor *textColor;

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSImage *image;
@property (nonatomic,strong) NSImage *selectedImage;




-(id)initWithTitle:(NSString *)title image:(NSImage *)image selectedImage:(NSImage *)selectedImage;

@end
