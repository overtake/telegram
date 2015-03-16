//
//  Tae Won Ha
//  http://qvacua.com
//  https://github.com/qvacua
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSMenuItemCategory.h"
#import <objc/runtime.h>

static char * const qBlockActionKey = "BlockActionKey";

@implementation NSMenuItem (Category)

DYNAMIC_PROPERTY(HIGHLIGHTED)
DYNAMIC_PROPERTY(SUBTITLE)
+ (id) menuItemWithTitle:(NSString *)title withBlock:(void (^)(id sender))block {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setTitle:title];
    [item setBlockAction:block];
    
    return item;
}

- (void)setHighlightedImage:(NSImage *)image {
    [self setHIGHLIGHTED:image];
}

- (NSImage *)highlightedImage {
    return [self getHIGHLIGHTED];
}


-(void)setSubtitle:(NSString *)subtitle {
    [self setSUBTITLE:subtitle];
}
-(NSString *)subtitle {
    return [self getSUBTITLE];
}

- (void)setBlockAction:(void (^)(id))block {
    objc_setAssociatedObject(self, qBlockActionKey, nil, OBJC_ASSOCIATION_RETAIN);
    
    if (block == nil) {
        [self setTarget:nil];
        [self setAction:NULL];
        
        return;
    }
    
    objc_setAssociatedObject(self, qBlockActionKey, block, OBJC_ASSOCIATION_RETAIN);
    [self setTarget:self];
    [self setAction:@selector(blockActionWrapper:)];
}

- (void (^)(id))blockAction {
    return objc_getAssociatedObject(self, qBlockActionKey);
}

- (void)blockActionWrapper:(id)sender {
    void (^block)(id) = objc_getAssociatedObject(self, qBlockActionKey);
    
    block(sender);
}

@end    
