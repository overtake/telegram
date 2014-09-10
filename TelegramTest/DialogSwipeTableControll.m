//
//  DialogSwipeTableControll.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/31/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DialogSwipeTableControll.h"

@interface DialogSwipeTableControll()

@property (nonatomic, strong) DialogRedButtonView *buttonView;
@property (nonatomic) BOOL isClossed;
@property (nonatomic) NSPoint startDragPoint;
@property (nonatomic) NSPoint startContainerPosition;
@end

@implementation DialogSwipeTableControll

- (id)initWithFrame:(NSRect)frameRect itemView:(DialogTableItemView *)itemView {
    self = [super initWithFrame:frameRect];
    if(self) {
        self.wantsLayer = YES;
        self.buttonView = [[DialogRedButtonView alloc] initWithFrame:NSMakeRect(0, 0, 0, self.bounds.size.height)];
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
    self->_backgroundColor = backgroundColor;
    
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
        DialogSwipeTableControll *view = self.tableView.swipeView;
        [view hideButton];
        self.tableView.swipeView = nil;
        return YES;
    }
    return NO;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(!self.itemView.isSwipePanelActive) {
        [super mouseDown:theEvent];
        return;
    }
    
    NSPoint point = [theEvent locationInWindow];
    
    point = [self.tableView convertPoint:point fromView:nil];
    
    NSRange range = [self.tableView rowsInRect:NSMakeRect(point.x, point.y, 1, 1)];
    
    
    
    
    //    DLog(@"");
    self.startDragPoint = theEvent.locationInWindow;
    self.startContainerPosition = self.containerView.layer.position;
    
    self.isClossed = [self checkIsSwipe];
    
    if(self.tableView.selectedItem != self.tableView.list[range.location] || [Telegram rightViewController].navigationViewController.currentController != [Telegram rightViewController].messagesViewController) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:range.location] byExtendingSelection:NO];
    }
    
}



- (void)mouseUp:(NSEvent *)theEvent {
    if(!self.itemView.isSwipePanelActive) {
        //  [super mouseUp:theEvent];
        return;
    }
    
    if(theEvent.clickCount != 0) {
        if(!self.isClossed) {
            if(self.tableView.swipeView) {
                DialogSwipeTableControll *view = self.tableView.swipeView;
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
    //    DLog(@"");
    
    CGPoint fromPoint = self.containerView.layer.position;
    CGPoint toPoint = NSMakePoint(0, 0);
    
    [self.containerView.layer removeAllAnimations];
    [self.containerView.layer setPosition:toPoint];
    self.buttonView.disable = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self setContainerPosition:toPoint];
        self.buttonView.disable = NO;
    }];
    [self.containerView.layer addAnimation:[TMAnimations postionWithDuration:0 fromValue:fromPoint toValue:toPoint] forKey:@"position"];
    [CATransaction commit];
    
    self.tableView.isSwipeContainerOpen = NO;
}

- (void)showButton {
    CGPoint fromPoint = self.containerView.layer.position;
    CGPoint toPoint = NSMakePoint(-self.buttonView.frame.size.width, 0);
    
    [self.containerView.layer removeAllAnimations];
    [self setContainerPosition:toPoint];
    self.buttonView.disable = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.buttonView.disable = NO;
    }];
    [self.containerView.layer addAnimation:[TMAnimations postionWithDuration:0 fromValue:fromPoint toValue:toPoint] forKey:@"position"];
    [CATransaction commit];
    
    self.tableView.isSwipeContainerOpen = YES;
    self.tableView.swipeView = self;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if(!self.itemView.isSwipePanelActive) {
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

@end
