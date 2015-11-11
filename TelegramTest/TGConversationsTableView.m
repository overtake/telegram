//
//  TGConversationsTableView.m
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGConversationsTableView.h"
#import "TGConversationTableCell.h"
#import "TGSwipeTableControll.h"
@interface TGHiddenScroller : NSScroller

@end

@implementation TGHiddenScroller

- (void)mouseDown:(NSEvent *)theEvent {
    
}

- (void)mouseUp:(NSEvent *)theEvent {
    
}

- (void)drawKnob {
    
}


@end

@interface TGConversationClipView : NSClipView
@property (nonatomic, strong) TGConversationsTableView *tableView;
@end

@implementation TGConversationClipView

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

-(void)viewDidEndLiveResize {
    [self.tableView reloadData];
}

- (void)scrollToPoint:(NSPoint)newOrigin {
    [super scrollToPoint:newOrigin];
    
    TGSwipeTableControll *controll = self.tableView.swipeView;
    if(controll) {
        [controll hideButton];
        self.tableView.swipeView = nil;
    }
}

- (void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
    
    TGSwipeTableControll *controll = self.tableView.swipeView;
    if(controll) {
        [controll hideButton];
        self.tableView.swipeView = nil;
    }
}

@end

@interface TGConversationsTableView()

@end

@implementation TGConversationsTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        id document = self.scrollView.documentView;
        TGConversationClipView *clipView = [[TGConversationClipView alloc] initWithFrame:self.scrollView.contentView.bounds];
        clipView.tableView = document;
        [clipView setWantsLayer:YES];
        [clipView setDrawsBackground:YES];
        //        [clipView setBackgroundColor:[NSColor redColor]];
        [self.scrollView setContentView:clipView];
        self.scrollView.documentView = document;
        
        
        TGHiddenScroller *scroller = [[TGHiddenScroller alloc] init];
        [scroller setScrollerStyle:NSScrollerStyleLegacy];
        //        [self.scrollView setVerticalScroller:scroller];
        [[self.scrollView verticalScroller] setHidden:YES];
        
        
        
        [self setHoverCells:YES];
    }
    return self;
}


- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend {
    [super selectRowIndexes:indexes byExtendingSelection:extend];
    
    
    TGSwipeTableControll *controll = self.swipeView;
    if(controll) {
        [controll hideButton];
        self.swipeView = nil;
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
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
