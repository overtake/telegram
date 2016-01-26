//
//  TGSplitView.m
//  TelegramModern
//
//  Created by keepcoder on 24.06.15.
//  Copyright (c) 2015 telegram. All rights reserved.
//

#import "TGSplitView.h"

@interface TGSplitView ()
{
    NSMutableDictionary *_proportions;
    NSMutableDictionary *_startSize;
   // TGView *self;
    NSMutableArray *_controllers;
    BOOL _isSingleLayout;
    NSMutableDictionary *_layoutProportions;
    
    NSPoint _startPoint;
    BOOL _splitSuccess;
    NSUInteger _splitIdx;
}
@end

@implementation TGSplitView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _proportions = [[NSMutableDictionary alloc] init];
        _controllers = [[NSMutableArray alloc] init];
        _startSize = [[NSMutableDictionary alloc] init];
        _layoutProportions = [[NSMutableDictionary alloc] init];
        _canChangeState = YES;
       // self = [[TGView alloc] initWithFrame:self.bounds];
       // [self addSubview:self];
        
        _state = -1;
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

-(void)addController:(TGViewController *)controller proportion:(struct TGSplitProportion)proportion {
    
    assert([NSThread isMainThread] && controller.view.superview == nil);
    
    
    [self addSubview:controller.view];
    
    [_controllers addObject:controller];
    
    _startSize[controller.internalId] = [NSValue valueWithSize:controller.view.frame.size];
    
    NSValue *encodeProportion = [NSValue valueWithBytes:&proportion objCType:@encode(struct TGSplitProportion)];
    
    _proportions[controller.internalId] = encodeProportion;
    
}


-(void)update {
    [self setFrameSize:self.frame.size];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];

    
    struct TGSplitProportion singleLayout = {380,300+380};
    struct TGSplitProportion dualLayout = {300+380,FLT_MAX};
    struct TGSplitProportion tripleLayout = {0,0};
    
   // [_layoutProportions[@(TGSplitViewStateSingleLayout)] getValue:&singleLayout];
   // [_layoutProportions[@(TGSplitViewStateDualLayout)] getValue:&dualLayout];
    [_layoutProportions[@(TGSplitViewStateTripleLayout)] getValue:&tripleLayout];
    
    
    if(isAcceptLayout(singleLayout) && _canChangeState) {
        if(_state != TGSplitViewStateSingleLayout && NSWidth(self.frame) < singleLayout.max )
            self.state = TGSplitViewStateSingleLayout;
        
        if(isAcceptLayout(dualLayout)) {
            if(isAcceptLayout(tripleLayout)) {
                if(_state != TGSplitViewStateDualLayout && NSWidth(self.frame) > dualLayout.min && NSWidth(self.frame) < tripleLayout.min)
                    self.state = TGSplitViewStateDualLayout;
                else
                    self.state = TGSplitViewStateTripleLayout;
            } else
                if(_state != TGSplitViewStateDualLayout && NSWidth(self.frame) > dualLayout.min)
                    self.state = TGSplitViewStateDualLayout;
        }
    }
    
    __block NSUInteger x = 0;
    
    [_controllers enumerateObjectsUsingBlock:^(TGViewController<TGSplitViewDelegate> *obj, NSUInteger idx, BOOL *stop) {
        
        struct TGSplitProportion proportion;
        
        [_proportions[obj.internalId] getValue:&proportion];
        
        NSSize startSize = [_startSize[obj.internalId] sizeValue];
        
        
        NSSize size = NSMakeSize(x, NSHeight(self.frame));
        
        
        int min = startSize.width;
        
        if(startSize.width < proportion.min)
        {
            min = proportion.min;
        } else if(startSize.width > proportion.max)
        {
            min = NSWidth(self.frame) - x;
            
        }
        
        if(idx == _controllers.count - 1)
            min = NSWidth(self.frame) - x;
        
        size = NSMakeSize(x + min > NSWidth(self.frame) ? (NSWidth(self.frame) - x) : min, NSHeight(self.frame));
        
        NSRect rect = NSMakeRect(x, 0, size.width, size.height);
        
        if(!NSEqualRects(rect, obj.view.frame))
            [obj splitViewDidNeedResizeController:rect];
        
        x+=size.width;
        
    }];
    
  
    
}

bool isAcceptLayout(struct TGSplitProportion prop) {
    return prop.min != 0 && prop.max != 0;
}

-(void)setState:(TGSplitViewState)state {
    
    BOOL notify = state != _state;
    
    _state = state;
    
    assert(notify);
    
    if(notify) {
        
        [_delegate splitViewDidNeedSwapToLayout:_state];
        
    }
    
}

-(void)removeController:(TGViewController *)controller {
    NSUInteger idx = [_controllers indexOfObject:controller];
    
    assert([NSThread isMainThread]);
    
    if(idx != NSNotFound) {
        [self.subviews[idx] removeFromSuperview];
        [_controllers removeObjectAtIndex:idx];
        [_startSize removeObjectForKey:controller.internalId];
        [_proportions removeObjectForKey:controller.internalId];
    }
    
}

-(void)removeAllControllers {
    [self removeAllSubviews];
    [_controllers removeAllObjects];
    [_startSize removeAllObjects];
    [_proportions removeAllObjects];
}

-(void)setProportion:(struct TGSplitProportion)proportion forState:(TGSplitViewState)state {
    _layoutProportions[@(state)] = [NSValue valueWithBytes:&proportion objCType:@encode(struct TGSplitProportion)];
}


-(void)updateStartSize:(NSSize)size forController:(TGViewController<TGSplitViewDelegate> *)controller {
    
    _startSize[controller.internalId] = [NSValue valueWithSize:size];
    
    
    struct TGSplitProportion proportion = {.min = size.width, .max = size.width};
    
    NSValue *encodeProportion = [NSValue valueWithBytes:&proportion objCType:@encode(struct TGSplitProportion)];
    
    _proportions[controller.internalId] = encodeProportion;
    
    [self update];
    
}

-(BOOL)wantsDefaultClipping {
    return NO;
}


-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    _startPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    _splitIdx = 0;
    _splitSuccess = NO;
    
    [self.subviews enumerateObjectsUsingBlock:^(TGView *obj, NSUInteger idx, BOOL *stop) {
        
        if(fabs(_startPoint.x - NSMaxX(obj.frame)) <= 10)
        {
            _splitSuccess = YES;
            _splitIdx = idx;
            *stop = YES;
        }
        
    }];
    
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    _startPoint = NSMakePoint(0, 0);
    _splitSuccess = NO;
    [[NSCursor arrowCursor] set];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    if(_startPoint.x == 0 || !_splitSuccess)
        return;
    
    NSPoint current = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    
    if(![self.delegate splitViewIsMinimisize:_controllers[_splitIdx]])
    {
        [[NSCursor resizeLeftCursor] set];
    } else {
        [[NSCursor resizeRightCursor] set];
    }
    
    if(_startPoint.x - current.x >= 100) {
        
        _startPoint = current;
        
        [self.delegate splitViewDidNeedMinimisize:_controllers[_splitIdx]];
        
        
    } else if(current.x - _startPoint.x >= 100) {
        
        _startPoint = current;
        
        [self.delegate splitViewDidNeedFullsize:_controllers[_splitIdx]];
        
    }
}

@end
