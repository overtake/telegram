//
//  NSApplication+RBLBlockAdditions.m
//  Rebel
//
//  Created by Jonathan Willing on 10/24/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSApplication+RBLBlockAdditions.h"
#import <objc/runtime.h>

static void *RBLNSApplicationSheetBlockAssociatedObjectKey = &RBLNSApplicationSheetBlockAssociatedObjectKey;

@implementation NSApplication (RBLBlockAdditions)

- (void)rbl_beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)modalWindow completionHandler:(void (^)(NSInteger returnCode))handler {
    [self beginSheet:sheet modalForWindow:modalWindow modalDelegate:self didEndSelector:@selector(rbl_sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    objc_setAssociatedObject(sheet, RBLNSApplicationSheetBlockAssociatedObjectKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)rbl_sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    void (^handler)(NSInteger returnCode) = objc_getAssociatedObject(sheet, RBLNSApplicationSheetBlockAssociatedObjectKey);
    [sheet orderOut:self];
    handler(returnCode);
    objc_setAssociatedObject(sheet, RBLNSApplicationSheetBlockAssociatedObjectKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
