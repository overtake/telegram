//
//  NSApplication+RBLBlockAdditions.h
//  Rebel
//
//  Created by Jonathan Willing on 10/24/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Adds support for block handlers on a standard sheet.
@interface NSApplication (RBLBlockAdditions)

// Adds onto the standard `beginSheet:modalForWindow:modalDelegate:didEndSelector:contextInfo:`
// with support for a block completion handler.
- (void)rbl_beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)modalWindow completionHandler:(void (^)(NSInteger returnCode))handler;

@end
