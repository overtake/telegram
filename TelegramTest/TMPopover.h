//
//  TMPopover.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMPopover : NSPopover

@property (nonatomic, strong) TMViewController *viewController;

- (id)initWithViewController:(TMViewController *)viewController;
- (void)showRelativeToView:(NSView *)view;
@end
