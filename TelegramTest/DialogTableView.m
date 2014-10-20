//
//  DialogTableView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DialogTableView.h"
#import "DialogTableItemView.h"

@interface HiddenScroller : NSScroller

@end

@implementation HiddenScroller

- (void)mouseDown:(NSEvent *)theEvent {
    
}

- (void)mouseUp:(NSEvent *)theEvent {
    
}

- (void)drawKnob {
    
}


@end

@interface DialogClipView : NSClipView
@property (nonatomic, strong) DialogTableView *tableView;
@end

@implementation DialogClipView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    NSRectFill(NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height));
    
//    if([NSScroller preferredScrollerStyle] != NSScrollerStyleLegacy) {
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(self.bounds.size.width - DIALOG_BORDER_WIDTH, dirtyRect.origin.y, DIALOG_BORDER_WIDTH, dirtyRect.size.height));
//    }
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [Telegram leftViewController].archiver.size = newSize;
    
    [[Telegram leftViewController].archiver save];
}

- (void)scrollToPoint:(NSPoint)newOrigin {
    [super scrollToPoint:newOrigin];
    
    DialogSwipeTableControll *controll = self.tableView.swipeView;
    if(controll) {
        [controll hideButton];
        self.tableView.swipeView = nil;
    }
}

- (void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
    
    DialogSwipeTableControll *controll = self.tableView.swipeView;
    if(controll) {
        [controll hideButton];
        self.tableView.swipeView = nil;
    }
}

@end

@interface DialogTableView()

@end

@implementation DialogTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        id document = self.scrollView.documentView;
        DialogClipView *clipView = [[DialogClipView alloc] initWithFrame:self.scrollView.contentView.bounds];
        clipView.tableView = document;
        [clipView setWantsLayer:YES];
        [clipView setDrawsBackground:YES];
//        [clipView setBackgroundColor:[NSColor redColor]];
        [self.scrollView setContentView:clipView];
        self.scrollView.documentView = document;
        
        
        HiddenScroller *scroller = [[HiddenScroller alloc] init];
        [scroller setScrollerStyle:NSScrollerStyleLegacy];
//        [self.scrollView setVerticalScroller:scroller];
        [[self.scrollView verticalScroller] setHidden:YES];

        
        
        [self setHoverCells:YES];
    }
    return self;
}

- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend {
    [super selectRowIndexes:indexes byExtendingSelection:extend];
    
    
    DialogSwipeTableControll *controll = self.swipeView;
    if(controll) {
        [controll hideButton];
        self.swipeView = nil;
    }
}

- (BOOL)canSelectItem {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    [TMTableView setCurrent:self];
}


@end
