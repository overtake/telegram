//
//  NSImageView+Extends.h
//  Messenger for Telegram
//
//  Created by keepcoder on 31.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImageView (Category)

- (void)setCallback:(void (^)(void))callback;

@end
