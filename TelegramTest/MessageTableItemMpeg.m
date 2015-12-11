//
//  MessageTableItemMpeg.m
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableItemMpeg.h"

@implementation MessageTableItemMpeg


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
        _player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:@"/Users/mikhailfilimonov/Desktop/giphy.mp4"]];
        
        
        
    }
    
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = strongsize(NSMakeSize(500, 280), width - 30);
    
    return YES;
}

-(NSString *)path {
    return @"/Users/mikhailfilimonov/Desktop/1.mov";
}

@end
