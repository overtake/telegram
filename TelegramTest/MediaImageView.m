//
//  MediaImageView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/16/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MediaImageView.h"

@implementation MediaImageView

- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
    
 
    NSRect rect;
    if(self.image.size.width > self.image.size.height) {
        float k = self.image.size.height / self.bounds.size.height;
        float width = roundf(self.image.size.width / k);
        rect = NSMakeRect(-roundf((width - self.bounds.size.width) / 2), 0, width, self.bounds.size.height);
    } else {
        float k = self.image.size.width / self.bounds.size.width;
        float height = roundf(self.image.size.height / k);
        rect = NSMakeRect(0, -roundf((height - self.bounds.size.height) / 2), self.bounds.size.width, height);
    }
    
    [self.image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];

    
}

@end
