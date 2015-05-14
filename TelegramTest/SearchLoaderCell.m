//
//  SearchLoaderCell.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchLoaderCell.h"

@interface SearchLoaderCell()
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@end

@implementation SearchLoaderCell

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    self.progressIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 15, 15)];
    [self.progressIndicator setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMaxYMargin];
    [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    [self.progressIndicator startAnimation:nil];
    [self addSubview:self.progressIndicator];
    
    [self.progressIndicator setCenterByView:self];
    
    return self;
}

- (void)dealloc {
    [self.progressIndicator stopAnimation:nil];
}

@end
