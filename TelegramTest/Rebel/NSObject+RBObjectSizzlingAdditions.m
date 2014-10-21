//
//  NSObject+NSObjectSizzlingAdditions.m
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSObject+RBObjectSizzlingAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (NSObjectSizzlingAdditions)

// Shamelessly taken from JAViewController since mine is a bit longer & ties into my other framework methods
+ (void)rbl_swapMethod:(SEL)originalSelector with:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    const char *originalTypeEncoding = method_getTypeEncoding(originalMethod);
    const char *newTypeEncoding = method_getTypeEncoding(newMethod);
    NSAssert2(!strcmp(originalTypeEncoding, newTypeEncoding), @"Method type encodings must be the same: %s vs. %s", originalTypeEncoding, newTypeEncoding);
	
    if(class_addMethod(self, originalSelector, method_getImplementation(newMethod), newTypeEncoding)) {
        class_replaceMethod(self, newSelector, method_getImplementation(originalMethod), originalTypeEncoding);
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
