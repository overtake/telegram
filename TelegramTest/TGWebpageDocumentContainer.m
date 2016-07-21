
//
//  TGWebpageDocumentContainer.m
//  Telegram
//
//  Created by keepcoder on 12/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebpageDocumentContainer.h"
#import "TGWebpageDocumentObject.h"
#import "TMMediaController.h"
#import "TMPreviewDocumentItem.h"
#import "MessageTableCellMpegView.h"
#import "TGModernMessageCellContainerView.h"
@interface TGWebpageDocumentContainer ()
@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) TGModernMessageCellContainerView *cellView;
@end

@implementation TGWebpageDocumentContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@synthesize loaderView = _loaderView;

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
    
    }
    
    return self;
}


-(void)setWebpage:(TGWebpageDocumentObject *)webpage {
    [super setWebpage:webpage];
    
    [self.siteName setHidden:YES];
    [self.author setHidden:YES];
    
    if(!_cellView || _cellView.class != webpage.documentItem.viewClass) {
        [_cellView.containerView removeFromSuperview];
        _cellView = [[webpage.documentItem.viewClass alloc] initWithFrame:NSZeroRect];
        
        [_cellView.containerView removeFromSuperview];
        
        [self addSubview:_cellView.containerView];
    }
    
    [_cellView setItem:webpage.documentItem];
    
    [_cellView.containerView setFrameOrigin:NSMakePoint(0, 0)];
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    if([self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_cellView.containerView.frame]) {
        if([self.webpage.webpage.embed_type isEqualToString:@"iframe"] && theEvent.clickCount == 1) {
            [self showPhoto];
        } else {
            [_cellView mouseDown:theEvent];
        }
        
    } else {
        [super mouseDown:theEvent];
    }
}

-(BOOL)mouseInContainer:(NSEvent *)theEvent {
    return [self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_cellView.containerView.frame];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    [_cellView _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    
}


-(void)updateState:(TMLoaderViewState)state {
    
    
}

-(void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [_cellView viewDidMoveToWindow];
}

@end
