//
//  DraggingControllerView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 05.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DraggingControllerView.h"
#import "DraggingItemView.h"

@interface DraggingControllerView ()

@property (nonatomic,strong) DraggingItemView *mediaView;
@property (nonatomic,strong) DraggingItemView *documentView;

@property (nonatomic,strong) NSTrackingArea *trackingArea;
@property (nonatomic,assign) DraggingViewType type;

@property (nonatomic,strong) TMView *backgroundView;

@end

@implementation DraggingControllerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _backgroundView = [[TMView alloc] initWithFrame:self.bounds];
        
        _backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        
        _backgroundView.wantsLayer = YES;
        _backgroundView.layer.backgroundColor = [NSColor whiteColor].CGColor;
        _backgroundView.layer.opacity = 0.9;
        
        [self addSubview:_backgroundView];
        
        _mediaView = [[DraggingItemView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        
        _mediaView.type = DraggingTypeMedia;
        
        _documentView = [[DraggingItemView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];

        
        _documentView.type = DraggingTypeDocument;
        
        
        _mediaView.title = NSLocalizedString(@"Conversation.DropTitle", nil);
        _mediaView.subtitle = NSLocalizedString(@"Conversation.DropQuickDescription", nil);
        
        
        _documentView.title = NSLocalizedString(@"Conversation.DropTitle", nil);
        _documentView.subtitle = NSLocalizedString(@"Conversation.DropAsFilesDescription", nil);
        
        [self addSubview:_mediaView];
        
        [self addSubview:_documentView];
        
        
    }
    return self;
}

+(void)setType:(DraggingViewType)type {
    [[self view] setType:type];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self removeFromSuperview];
}

- (void)updateTrackingAreas {
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:_trackingArea];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)configure:(NSRect)forRect {
    
    int margin = 10;
    float maxHeight = (forRect.size.height - (margin*3) ) / 2;
    
    self.frame = NSMakeRect(0, 0, forRect.size.width, forRect.size.height);
    
    
    [_mediaView setHidden:self.type == DraggingTypeSingleChoose];
    
    _mediaView.frame = NSMakeRect(margin, margin, forRect.size.width- (margin *2), maxHeight);
    
    
    if(!_mediaView.isHidden)
        _documentView.frame = NSMakeRect(margin, _mediaView.frame.origin.y+maxHeight+margin, _mediaView.frame.size.width, maxHeight);
    else
        _documentView.frame = NSMakeRect(margin, margin, _mediaView.frame.size.width, forRect.size.height - margin * 2);
    
    
    
    _mediaView.dragEntered = NO;
    _documentView.dragEntered = NO;
}

+ (DraggingControllerView *)view {
    static DraggingControllerView *instance;
    
    NSRect tableRect = [Telegram rightViewController].view.frame;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DraggingControllerView alloc] initWithFrame:NSMakeRect(0, 0, tableRect.size.width, tableRect.size.height)];
    });
    
    [instance configure:tableRect];
    
    return instance;
}

@end
