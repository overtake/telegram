//
//  TMTabItem.m
//  Telegram
//
//  Created by keepcoder on 26.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTabItem.h"

@implementation TMTabItem


-(id)initWithTitle:(NSString *)title image:(NSImage *)image selectedImage:(NSImage *)selectedImage {
    
    if(self = [super init]) {
        self.selectedImage = selectedImage;
        self.title = title;
        self.image = image;
    }
    
    return self;
}

@end
