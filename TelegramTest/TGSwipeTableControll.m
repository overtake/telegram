//
//  DialogSwipeTableControll.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/31/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGSwipeTableControll.h"
#import "HackUtils.h"
@interface TGSwipeTableControll()
{
    BOOL _splitDrag;
}
@property (nonatomic, strong) TGSwipeRedView *buttonView;
@property (nonatomic) BOOL isClossed;
@property (nonatomic) NSPoint startDragPoint;
@property (nonatomic) NSPoint startContainerPosition;

@end

@implementation TGSwipeTableControll

- (id)initWithFrame:(NSRect)frameRect itemView:(TGConversationTableCell *)itemView {
    self = [super initWithFrame:frameRect];
    if(self) {
        self.wantsLayer = YES;
        
        
        _itemView = itemView;
        self.buttonView = [[TGSwipeRedView alloc] initWithFrame:NSMakeRect(0, 0, 0, self.bounds.size.height)];
        [self.buttonView setFrameOrigin:NSMakePoint(self.bounds.size.width - self.buttonView.bounds.size.width, 0)];
        [self.buttonView setHidden:YES];
        [self.buttonView setAutoresizingMask:NSViewMinXMargin];
        [self.buttonView setItemView:itemView];
        [super addSubview:self.buttonView];
        
        self.containerView = [[TMView alloc] initWithFrame:frameRect];
        [self.containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [super addSubview:self.containerView];
        
        
    }
    return self;
}

- (void)addSubview:(NSView *)aView {
    [self.containerView addSubview:aView];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if(self.containerView.backgroundColor) {
        [self.containerView setBackgroundColor:backgroundColor];
        [self.containerView setNeedsDisplay:YES];
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)checkIsSwipe {
    if(self.tableView.swipeView && self.tableView.swipeView != self) {
        TGSwipeTableControll *view = self.tableView.swipeView;
        [view hideButton];
        self.tableView.swipeView = nil;
        return YES;
    }
    return NO;
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    _splitDrag = NO;
    
    if(!self.itemView.isSwipePanelActive) {
        [super mouseDown:theEvent];
        return;
    }
    
    
    NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    
    if(NSWidth(self.frame) - viewPoint.x  <= 10) {
        
        [[self superviewByClass:@"TGSplitView"] mouseDown:theEvent];
        
        _splitDrag = YES;
        
        return;
    }
    
    NSPoint point = [theEvent locationInWindow];
    
    point = [self.tableView convertPoint:point fromView:nil];
    
    NSRange range = [self.tableView rowsInRect:NSMakeRect(point.x, point.y, 1, 1)];
    
    
    
    
    //    MTLog(@"");
    self.startDragPoint = theEvent.locationInWindow;
    self.startContainerPosition = self.containerView.layer.position;
    
    self.isClossed = [self checkIsSwipe];
    
    if(self.tableView.selectedItem != self.tableView.list[range.location] || [Telegram rightViewController].navigationViewController.currentController != [Telegram rightViewController].messagesViewController || [Telegram rightViewController].isModalViewActive) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:range.location] byExtendingSelection:NO];
    }
    
}



- (void)mouseUp:(NSEvent *)theEvent {
    
    _splitDrag = NO;
    
    if(!self.itemView.isSwipePanelActive) {
        //  [super mouseUp:theEvent];
        return;
    }
    
    if(theEvent.clickCount != 0) {
        if(!self.isClossed) {
            if(self.tableView.swipeView) {
                TGSwipeTableControll *view = self.tableView.swipeView;
                [view hideButton];
                self.tableView.swipeView = nil;
            } else {
                //  [super mouseDown:theEvent];
                [self hideButton];
            }
        }
        return;
    }
    
    if(self.containerView.layer.position.x >= -self.buttonView.frame.size.width / 2.0) {
        [self hideButton];
        self.tableView.swipeView = nil;
    } else {
        [self showButton];
    }
    
    
}

- (void)hideButton {
    //    MTLog(@"");
    
    CGPoint fromPoint = self.containerView.layer.position;
    CGPoint toPoint = NSMakePoint(0, 0);
    
    [self.containerView.layer removeAllAnimations];
    [self.containerView.layer setPosition:toPoint];
    self.buttonView.disable = YES;
    [CATransaction setCompletionBlock:^{
        [self setContainerPosition:toPoint];
        self.buttonView.disable = NO;
    }];
    [self.containerView.layer addAnimation:[TMAnimations postionWithDuration:0 fromValue:fromPoint toValue:toPoint] forKey:@"position"];
    
    self.tableView.isSwipeContainerOpen = NO;
}

- (void)showButton {
    CGPoint fromPoint = self.containerView.layer.position;
    CGPoint toPoint = NSMakePoint(-self.buttonView.frame.size.width, 0);
    
    [self.containerView.layer removeAllAnimations];
    [self setContainerPosition:toPoint];
    self.buttonView.disable = YES;
    [CATransaction setCompletionBlock:^{
        self.buttonView.disable = NO;
    }];
    [self.containerView.layer addAnimation:[TMAnimations postionWithDuration:0 fromValue:fromPoint toValue:toPoint] forKey:@"position"];
    
    self.tableView.isSwipeContainerOpen = YES;
    self.tableView.swipeView = self;
}


- (void)mouseDragged:(NSEvent *)theEvent {
    if(!self.itemView.isSwipePanelActive) {
        [super mouseDragged:theEvent];
        return;
    }
    
    
    NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(!_splitDrag && NSWidth(self.frame) - viewPoint.x  <= 10) {
        _splitDrag = YES;
        
        [[self superviewByClass:@"TGSplitView"] mouseDown:theEvent];
        
    }
    
    if(_splitDrag)
    {
        [super mouseDragged:theEvent];
        return;
    }
    
    float x = theEvent.locationInWindow.x - self.startDragPoint.x;
    
    
    if(self.startContainerPosition.x + x >= 0) {
        x = -self.startContainerPosition.x;
    }
    
    [self.containerView.layer removeAllAnimations];
    [self setContainerPosition:NSMakePoint(self.startContainerPosition.x + x, 0)];
}

- (void)setContainerPosition:(CGPoint)point {
    [self.containerView.layer setPosition:point];
    
    NSColor *color;
    if(self.containerView.layer.position.x == 0) {
        [self.buttonView setHidden:YES];
    } else {
        color = self.backgroundColor;
        [self.buttonView setHidden:NO];
    }
    
    if(color != self.containerView.backgroundColor) {
        [self.containerView setBackgroundColor:color];
        [self.containerView setNeedsDisplay:YES];
    }
    
    self.buttonView.disable = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.drawBlock)
        self.drawBlock();
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_containerView setFrameSize:newSize];
}

-(TGConversationsTableView *)tableView {
    return _itemView.tableView;
}

@end
