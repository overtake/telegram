//
//  UserInfoShortButtonView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoShortButtonView.h"

@interface UserInfoShortButtonView()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSProgressIndicator *progress;


@property (nonatomic,strong) dispatch_block_t tapBlock;
@end

@implementation UserInfoShortButtonView

+ (id) buttonWithText:(NSString *)string tapBlock:(dispatch_block_t)block {
    UserInfoShortButtonView *view = [[UserInfoShortButtonView alloc] initWithFrame:NSZeroRect withName:string andBlock:block];
    return view;
}

- (id)initWithFrame:(NSRect)frame withName:(NSString *)name andBlock:(dispatch_block_t)block {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.wantsLayer = YES;
        
        self.textButton = [TMTextButton standartUserProfileButtonWithTitle:name];
        self.tapBlock = block;
        [self.textButton sizeToFit];
        [self.textButton setFrameOrigin:NSMakePoint(0, 7)]; // 10
        [[self.textButton cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.textButton cell] setTruncatesLastVisibleLine:YES];
        [self setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.textButton];
        
        self.progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 17)];
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        [self.progress setHidden:YES];
        
        
      //  self.textButton.drawsBackground = YES;
      //  [self.textButton setBackgroundColor:[NSColor blueColor]];
        
        
        _rightContainer = [[TMView alloc] initWithFrame:NSZeroRect];
       
        _rightContainer.layer.backgroundColor = NSColorFromRGB(0x000000).CGColor;
        
        [self addSubview:_rightContainer];
        
        _locked = NO;
        
        
        [Notification addObserver:self selector:@selector(redraw) name:@"MODALVIEW_VISIBLE_CHANGE"];
    
        [self updateTrackingAreas];
    }
    return self;
}

-(void)setRightContainerOffset:(NSPoint)rightContainerOffset {
    self->_rightContainerOffset = rightContainerOffset;
    
    [self updateRightControllerFrame];
}



-(void)setRightContainer:(NSView *)rightContainer {
    
    [rightContainer removeFromSuperview];
    _currentRightController = rightContainer;
    
    while (_rightContainer.subviews.count) {
        [_rightContainer.subviews[0] removeFromSuperview];
    }
    
    
    [_currentRightController setFrameOrigin:NSMakePoint(1, 1)];
    
    [_rightContainer addSubview:_currentRightController];

    [self updateRightControllerFrame];
}

- (void)updateRightControllerFrame {
      _rightContainer.frame = NSMakeRect(roundf(self.frame.size.width - _currentRightController.frame.size.width) + _rightContainerOffset.x - 2, roundf((self.frame.size.height-_currentRightController.frame.size.height) /2) + _rightContainerOffset.y - 2, _currentRightController.frame.size.width + 2, _currentRightController.frame.size.height + 2 );
}

-(void)setLocked:(BOOL)locked {
    self->_locked = locked;
    
     [self setRightContainer:self.progress];
    
    [self.progress setHidden:!locked];
    if(locked) {
        [self.progress startAnimation:self];
    } else {
        [self.progress stopAnimation:self];
    }
    
   
}

- (void)updateTrackingAreas {
    if (self.trackingArea) {
		[self removeTrackingArea:self.trackingArea];
		self.trackingArea = nil;
	}
    
    NSUInteger options = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options:options
            
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
    
    
    [super updateTrackingAreas];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self setNeedsDisplay:YES];
}

- (void)cursorUpdate:(NSEvent *)event {
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self setNeedsDisplay:YES];
//    MTLog(@"exit");
}

- (void)mouseDown:(NSEvent *)theEvent {
    
  //  self.backgroundColor = NSColorFromRGB(0xfafafa);
   
    [self setNeedsDisplay:YES];
    if(self.tapBlock && !self.locked) {
        self.tapBlock();
    }
   // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
   //     self.backgroundColor = [NSColor clearColor];
    //    [self setNeedsDisplay:YES];
   // });
    
  
}

- (void)mouseUp:(NSEvent *)theEvent {
    
    self.backgroundColor = [NSColor clearColor];
    [self setNeedsDisplay:YES];
    [super mouseUp:theEvent];
    
  
}

- (void)removeFromSuperviewWithoutNeedingDisplay {
    
}

- (void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];
}

-(void)sizeToFit {
    [self setFrameSize:self.frame.size];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self setRightContainer:self.currentRightController];
    
    
    [self.textButton sizeToFit];
    
    [self.textButton setFrameSize:NSMakeSize(MIN(NSWidth(_textButton.frame),newSize.width - NSWidth(self.rightContainer.frame) - 15 ), 22)];
    
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj class] == [TMTextField class]) {

            [obj sizeToFit];
            
            [obj setFrameSize:NSMakeSize(MIN(NSWidth([obj frame]),NSWidth(self.frame) - NSMaxX(_textButton.frame) - NSWidth(_rightContainer.frame) - 30), NSHeight([obj frame]))];
            
            [obj setFrameOrigin:NSMakePoint(NSMinX(_rightContainer.frame) - 10 - NSWidth([obj frame]), NSMinY([obj frame]))];
        }
        
    }];
    
}



- (void)redraw {
    [self changeBackground];
    [self setNeedsDisplay:YES];
}

- (void)changeBackground {
    if([Telegram rightViewController].isModalViewActive)
        return;
    
    
    NSPoint mouseLocation = [self.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint:mouseLocation fromView:nil];
    
    
    BOOL isActiveInAttachedSheed = NO;
    if(self.window.attachedSheet) {
        NSPoint attachedMouseLocation = [self.window.attachedSheet mouseLocationOutsideOfEventStream];
        attachedMouseLocation = [self.window.attachedSheet.contentView convertPoint:attachedMouseLocation fromView:nil];

        isActiveInAttachedSheed = NSPointInRect(attachedMouseLocation, [self.window.attachedSheet.contentView bounds]);
    }
    
//    MTLog(@"isAC %d", isActiveInAttachedSheed);
    
//	if (self.window.isKeyWindow && NSPointInRect(mouseLocation, self.bounds) && !isActiveInAttachedSheed) {//cursoroff
//        self.backgroundColor = NSColorFromRGB(0xfafafa);
//        [self.backgroundColor set];
//        NSRectFill(NSMakeRect(0, 1, self.bounds.size.width, self.bounds.size.height-1));
//        [[NSCursor pointingHandCursor] set];
//	} else {
//        self.backgroundColor = nil;
//        [[NSCursor arrowCursor] set];
//	}
}


-(void)setSelectedColor:(NSColor *)selectedColor {
    self->_selectedColor = selectedColor;
    
    [self setNeedsDisplay:YES];
}

-(void)setIsSelected:(BOOL)isSelected {
    self->_isSelected = isSelected;
    
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
    [self changeBackground];

    [super drawRect:dirtyRect];

    [LIGHT_GRAY_BORDER_COLOR set];
    NSRectFill(NSMakeRect(self.textButton.frame.origin.x, 0, self.bounds.size.width, 1));
    
    if(self.backgroundColor) {
        [self.backgroundColor set];
        NSRectFill(NSMakeRect(0, 1, self.bounds.size.width, self.bounds.size.height-1));
    }
  
    if(self.isSelected) {
        [self.selectedColor set];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
    }
    
    
}

@end
