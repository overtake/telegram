//
//  TMScrollView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/24/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "HackUtils.h"
#import "TMTableView.h"

@interface TMScrollView()
@property (nonatomic) float lastScrollTop;
@property (nonatomic) float lastScrollBottom;
@property (nonatomic) float lastScrollRight;
@property (nonatomic) float lastWidth;
@property (nonatomic, strong) TMScrollAnimation *scrollAnimation;
@property (nonatomic) BOOL isScrollToEnd;
@property (nonatomic) BOOL isScrollRightNow;

@property (nonatomic) NSPoint startLiveOffset;
@property (nonatomic,assign) NSSize startLiveSize;
@end

@implementation TMScrollView

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        self.scrollAnimation = [[TMScrollAnimation alloc] init];
        self.scrollAnimation.scrollView = self;
        
        [self setScrollerStyle:NSScrollerStyleOverlay];
        
//        [self setPostsBoundsChangedNotifications:YES];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewFrameDidChangeNotification object:self];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.contentView];
        
              

    }
    return self;
}

- (void)setIsHideHorizontalScroller:(BOOL)isHideHorizontalScroller {
    self->_isHideHorizontalScroller = isHideHorizontalScroller;
    
    [self.horizontalScroller setHidden:isHideHorizontalScroller];
}

- (void)setIsHideVerticalScroller:(BOOL)isHideVerticalScroller {
    self->_isHideVerticalScroller = isHideVerticalScroller;
    
    [self.verticalScroller setHidden:isHideVerticalScroller];
}

- (void)tile {
    [super tile];
    
    if(self.isHideVerticalScroller) {
        [self.verticalScroller setHidden:YES];
    }
    
//    [self.verticalScroller setFrameOrigin:NSMakePoint(self.verticalScroller.frame.origin.x, self.verticalScroller.frame.origin.y + 10)];
//    [self.verticalScroller setFrameSize:NSMakeSize(self.verticalScroller.frame.size.width, self.verticalScroller.frame.size.height - 10)];
    
    if(self.isHideHorizontalScroller) {
        [self.horizontalScroller setHidden:YES];
    }
}

- (void)setScrollerStyle:(NSScrollerStyle)newScrollerStyle {
    [super setScrollerStyle:NSScrollerStyleOverlay];
}

- (void) boundsDidChange:(NSNotification *)notification {
    if(self.lastWidth != self.bounds.size.width) {
        self.lastWidth = self.bounds.size.width;
       // MTLog(@"log change frame %@ %@", NSStringFromRect(self.bounds), self);

    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];

    if([self.delegate respondsToSelector:@selector(scrollDidChangeFrameSize:)]) {
        [self.delegate scrollDidChangeFrameSize:newSize];
    }
}


-(void)viewWillStartLiveResize {
    self.startLiveOffset = self.documentOffset;
    self.startLiveSize = self.frame.size;
}

- (void) contentViewBoundsDidChange:(NSNotification *)notification {
    
    
    if(self.scrollAnimation.isAnimating && self.scrollAnimation.progressPoint.y != [self documentOffset].y) {
        [self.scrollAnimation stopAnimationWithScrollToTarget:NO];
    }
}

-(BOOL) isAnimating {
    return self.scrollAnimation.isAnimating;
}



- (BOOL) isScrollEndOfDocument {
    return self.isScrollToEnd || [self documentOffset].y == 0;
}

- (BOOL) isNeedUpdateTop {
    BOOL result = self.lastScrollTop < 0;
    if(self.lastScrollTop > (int)[self documentOffset].y) {
        
        result = [self documentOffset].y  <= 1500; // эт бред если что
    }
    
    
    self.lastScrollTop = [self documentOffset].y;
    return  result;
}


-(void)dropScrollData {
    self.lastScrollBottom = 0;
    self.lastScrollTop = 0;
    self.lastScrollRight = 0;
}

- (BOOL) isNeedUpdateRight {
    BOOL result = self.lastScrollRight > self.documentSize.width;
    if(self.lastScrollRight > (int)[self documentOffset].x) {
        
        result = [self documentOffset].x > (self.documentSize.width - 1500); // эт бред если что
    }
    
    
    self.lastScrollRight = [self documentOffset].x;
    return  result;
}

- (BOOL) isNeedUpdateBottom {
    BOOL result = NO;
    if(self.lastScrollBottom < (int)[self documentOffset].y ) {
        result = ([self documentSize].height-[self documentOffset].y) < 1000; // эт бред если что
    }
    self.lastScrollBottom = [self documentOffset].y > 0 ? [self documentOffset].y : 0;
    return  result;
}

- (NSPoint) documentOffset {
    return NSMakePoint(self.contentView.bounds.origin.x, self.contentView.bounds.origin.y);
}

- (NSSize) documentSize {
    return self.contentView.documentRect.size;
}

//- (void)scrollWheel:(NSEvent *)theEvent {
//    if(!self.disableScrolling) {
//        [super scrollWheel:theEvent];
//    } else {
//        self.isScrollRightNow = NO;
//        return;
//    }
//    
//    if(theEvent.phase == NSEventPhaseEnded) {
//        self.isScrollRightNow = NO;
//        return;
//    }
//    
//    if(theEvent.phase == NSEventPhaseCancelled) {
//        self.isScrollRightNow = NO;
//        return;
//    }
//    
//    if(theEvent.momentumPhase == NSEventPhaseEnded) {
//        self.isScrollRightNow = NO;
//        return;
//    }
//    
//    if(theEvent.momentumPhase == NSEventPhaseCancelled) {
//        self.isScrollRightNow = NO;
//        return;
//    }
//    
//    self.isScrollRightNow = YES;
//}

- (void)setIsScrollRightNow:(BOOL)isScrollRightNow {
    if(self.isScrollRightNow == isScrollRightNow)
        return;
    
    self->_isScrollRightNow = isScrollRightNow;
    
    TMTableView *tableView = self.documentView;
    if(![tableView isKindOfClass:[NSTableView class]])
        return;
    
    if(isScrollRightNow) {
        if([tableView.delegate respondsToSelector:@selector(scrollDidStart)])
            [tableView.delegate performSelector:@selector(scrollDidStart) withObject:nil];
    } else {
        if([tableView.delegate respondsToSelector:@selector(scrollDidEnd)])
            [tableView.delegate performSelector:@selector(scrollDidEnd) withObject:nil];
    }
}

- (void) scrollToPoint:(NSPoint)point animation:(BOOL)animation {
    if(!animation) {
//        [self.scrollAnimation stopAnimationWithScrollToTarget:NO];
        
        [self.clipView scrollRectToVisible:NSMakeRect(point.x, point.y, NSWidth(self.frame), NSHeight(self.frame)) animated:NO];
        
    } else {
        
        
        if(self.scrollAnimation.isAnimating) {
            if(self.scrollAnimation.targetPoint.y < point.y)
                [self.scrollAnimation setTargetPoint:point];
            else {
                [self.scrollAnimation stopAnimationWithScrollToTarget:YES];
                [self.scrollAnimation setTargetPoint:point];
                [self.scrollAnimation startAnimation];
            }
        } else {
            [self.scrollAnimation setTargetPoint:point];
            [self.scrollAnimation startAnimation];
        }
    }
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.drawBlock) {
        self.drawBlock();
    }
}


- (void) scrollToEndWithAnimation:(BOOL)animation {
    
    
    if(!self.window)
        animation = NO;
    
    if(!animation) {
        BOOL neNorm = YES;
        int i = 0;
        while(neNorm && i < 20) {
            [self scrollToPoint:NSMakePoint(0, 0) animation:NO];
            neNorm = self.documentOffset.y != 0;
            i++;
        }
        
        return;
    }
    
    self.isScrollToEnd = YES;
    [self.clipView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animation completion:^(BOOL scrolled) {
        self.isScrollToEnd = NO;
    }];
}


@end
