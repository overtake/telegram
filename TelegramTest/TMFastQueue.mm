//
//  TMFastQueue.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMFastQueue.h"
#include <stack>

@interface TMFastQueue()

@property (nonatomic) std::stack<NSView *> *queue;

@end

@implementation TMFastQueue

- (id) init {
    self = [super init];
    self.queue = new std::stack<NSView *>();
    return self;
}

- (NSView *) popElement {
    if(self.queue->empty())
        return nil;
    NSView *view = self.queue->top();
    self.queue->pop();
    return view;
}

- (void) push:(NSView *)view {
    self.queue->push(view);
}

- (void) dealloc {
    delete self.queue;
}
@end
