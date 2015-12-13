//
//  TGGLVideoFrame.m
//  Telegram
//
//  Created by keepcoder on 13/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGLVideoFrame.h"

@interface TGGLVideoFrame ()


@end

@implementation TGGLVideoFrame

- (instancetype)initWithBuffer:(CVImageBufferRef)buffer timestamp:(NSTimeInterval)timestamp {
    self = [super init];
    if (self != nil) {
        if (buffer) {
            CFRetain(buffer);
        }
        _timestamp = timestamp;
        _buffer = buffer;
    }
    return self;
}

- (void)dealloc {
    if (_buffer) {
        NSLog(@"%ld",CFGetRetainCount(_buffer));
        CFRelease(_buffer);
    }
    
}

@end