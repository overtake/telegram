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


@property (nonatomic,strong) NSView *currentRightController;
@end

@implementation UserInfoShortButtonView

+ (id) buttonWithText:(NSString *)string tapBlock:(dispatch_block_t)block {
    UserInfoShortButtonView *view = [[UserInfoShortButtonView alloc] initWithFrame:NSZeroRect withName:string andBlock:block];
    return view;
}

- (id)initWithFrame:(NSRect)frame withName:(NSString *)name andBlock:(dispatch_block_t)block {
    self = [super initWithFrame:frame];
    if (self) {
        self.textButton = [TMTextButton standartUserProfileButtonWithTitle:name];
        self.textButton.tapBlock = block;
        [self.textButton sizeToFit];
        [self.textButton setFrameOrigin:NSMakePoint(10, 12)];
        [self setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.textButton];
        
        self.progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 17)];
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        [self.progress setHidden:YES];
        
        
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
    
    self.currentRightController = rightContainer;
    
    while (_rightContainer.subviews.count) {
        [_rightContainer.subviews[0] removeFromSuperview];
    }
    
    [_rightContainer addSubview:_currentRightController];

    [self updateRightControllerFrame];
}

- (void)updateRightControllerFrame {
      _rightContainer.frame = NSMakeRect(roundf(self.frame.size.width - _currentRightController.frame.size.width) + +_rightContainerOffset.x, roundf((self.frame.size.height-_currentRightController.frame.size.height) /2) + +_rightContainerOffset.y, _currentRightController.frame.size.width, _currentRightController.frame.size.height);
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
//    NSLog(@"exit");
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(self.textButton.tapBlock && !self.locked) {
        self.textButton.tapBlock();
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    
}

- (void)removeFromSuperviewWithoutNeedingDisplay {
    
}

- (void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];
}


- (void)setFrameSize:(NSSize)newSize {
    newSize.height = 42;
    [super setFrameSize:newSize];
    
    [self setRightContainer:self.currentRightController];
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
    
//    NSLog(@"isAC %d", isActiveInAttachedSheed);
    
	if (self.window.isKeyWindow && NSPointInRect(mouseLocation, self.bounds) && !isActiveInAttachedSheed) {
        self.backgroundColor = NSColorFromRGB(0xfafafa);
        [self.backgroundColor set];
        NSRectFill(NSMakeRect(0, 1, self.bounds.size.width, self.bounds.size.height-1));
        [[NSCursor pointingHandCursor] set];
	} else {
        self.backgroundColor = nil;
        [[NSCursor arrowCursor] set];
	}
}

- (void)drawRect:(NSRect)dirtyRect {
    [self changeBackground];

    [super drawRect:dirtyRect];

    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
    
    
    
}

@end
