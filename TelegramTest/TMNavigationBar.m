//
//  TMNavigationBar.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMNavigationBar.h"
#import "NSString+Extended.h"

#define ANIM_DURATION 2.05

@interface TMNavigationBar()

@property (nonatomic, strong) TMView *leftViewBlock;
@property (nonatomic, strong) TMView *centerViewBlock;
@property (nonatomic, strong) TMView *rightViewBlock;

@property (nonatomic) NSUInteger rightHash;
@end

@implementation TMNavigationBar

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        
        self.leftViewBlock = [[TMView alloc] initWithFrame:NSZeroRect];
        [self addSubview:self.leftViewBlock];
        
        self.centerViewBlock = [[TMView alloc] initWithFrame:NSZeroRect];
        [self.centerViewBlock setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.centerViewBlock];
        
        self.rightViewBlock = [[TMView alloc] initWithFrame:NSZeroRect];
        [self.rightViewBlock setAutoresizingMask:YES];
        [self.rightViewBlock setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:self.rightViewBlock];
    }
    return self;
}

- (void) setLeftView:(TMView *)view animated:(BOOL)animated {
    [self.leftView removeFromSuperview];
    self.leftView = view;
    [self.leftViewBlock setFrameSize:NSMakeSize(self.leftView.bounds.size.width, self.leftView.bounds.size.height)];
    [self.leftViewBlock addSubview:self.leftView];
    [self.leftViewBlock setFrameOrigin:NSMakePoint(15, roundf((self.bounds.size.height - view.bounds.size.height) /2))];
    [self buildSizes];
}

- (void) setCenterView:(TMView *)view animated:(BOOL)animated {
    [self.centerView removeFromSuperview];
    self.centerView = view;
    [self.centerView setAutoresizingMask:NSViewWidthSizable];
    [self.centerView setFrameSize:NSMakeSize(self.centerViewBlock.bounds.size.width, self.centerViewBlock.bounds.size.height)];
    [self.centerViewBlock addSubview:self.centerView];
    [self.centerViewBlock setFrameOrigin:NSMakePoint(0, 0)];
    [self buildSizes];
}

- (void) buildSizes {
    float maxSize = MAX(self.leftView.frame.size.width, self.rightView.frame.size.width);
    
    [self.centerViewBlock setFrameSize:NSMakeSize(self.bounds.size.width - 60 - maxSize * 2, self.bounds.size.height)];
    [self.centerViewBlock setFrameOrigin:NSMakePoint(32 + maxSize, 0)];
    
//    float maxLeftWidth = self.bounds.size.width - 60 - 20 - self.rightView.bounds.size.width;
//    [self.leftViewBlock setAutoresizingMask:NSViewNotSizable];
//    [self.leftViewBlock setFrameSize:NSMakeSize(maxLeftWidth, self.leftView.bounds.size.height)];
//    [self.leftViewBlock setAutoresizingMask:NSViewWidthSizable];
}

- (void) setRightView:(TMView *)newRightView animated:(BOOL)animated {
    
    TMView *oldRightView = self.rightView;
    
    animated = NO;
    
    if(animated) {
        
        __block NSUInteger hash = [[NSString randStringWithLength:16] hash];
        self.rightHash = hash;
        
        self.rightView = newRightView;
//        [oldRightView setWantsLayer:YES];
//        [oldRightView.layer setOpacity:1];
//        [oldRightView.layer setOpaque:YES];
//        [self.rightView setWantsLayer:YES];
//        [self.rightView.layer setOpaque:YES];

        [self.rightViewBlock addSubview:self.rightView];
        
//        [oldRightView.layer removeAllAnimations];
//        [self.rightView.layer removeAllAnimations];

        //Фикс для размеров
        
        NSSize blockSize = self.rightViewBlock.bounds.size;
        NSSize newSize = self.rightView.bounds.size;
        
        if(blockSize.width > newSize.width)
            [self.rightView setFrameOrigin:NSMakePoint(blockSize.width - newSize.width, self.rightView.frame.origin.y)];
        
        if(blockSize.width < newSize.width) {
            [self.rightViewBlock setFrameSize:NSMakeSize(newSize.width, self.rightViewBlock.frame.size.height)];
            [oldRightView setFrameOrigin:NSMakePoint(newSize.width - blockSize.width, oldRightView.frame.origin.y)];
        }
        
        if(blockSize.height > newSize.height)
            [self.rightView setFrameOrigin:NSMakePoint(self.rightView.frame.origin.x, roundf((blockSize.height - newSize.height) / 2))];
        
        if(blockSize.height < newSize.height) {
            [self.rightViewBlock setFrameSize:NSMakeSize(self.rightViewBlock.frame.size.width, newSize.height)];
            [oldRightView setFrameOrigin:NSMakePoint(oldRightView.frame.origin.x, ceilf((newSize.height - blockSize.height) / 2.0))];
        }
        
        [self.rightViewBlock setFrameOrigin:NSMakePoint(self.bounds.size.width - self.rightViewBlock.bounds.size.width - 15, roundf((self.bounds.size.height - self.rightViewBlock.bounds.size.height) / 2))];
        
        oldRightView.layer.opacity = 1;
        self.rightView.layer.opacity = 0;
        
        [NSAnimationContext beginGrouping];
        {
            [[NSAnimationContext currentContext] setCompletionHandler:^{
                if(self.rightHash != hash) {
                    return;
                }
                
                //                [oldRightView setWantsLayer:NO];
                //                [self.rightView setWantsLayer:NO];
                
                [oldRightView removeFromSuperview];
                [self.rightView setFrameOrigin:NSMakePoint(0, 0)];
                [self.rightViewBlock setFrameSize:newSize];
                [self.rightViewBlock setFrameOrigin:NSMakePoint(self.bounds.size.width - self.rightViewBlock.bounds.size.width - 15, roundf((self.bounds.size.height - self.rightViewBlock.bounds.size.height) / 2))];
                [self buildSizes];
            }];
            
            
//            [oldRightView.layer addAnimation:[TMAnimations fadeWithDuration:ANIM_DURATION fromValue:1 toValue:0] forKey:@"flashAnimation"];
//            [self.rightView.layer addAnimation:[TMAnimations fadeWithDuration:ANIM_DURATION fromValue:0 toValue:1] forKey:@"flashAnimation"];
            
            [[NSAnimationContext currentContext] setDuration:ANIM_DURATION];
//            [[NSAnimationContext currentContext] setTimingFunction:self.timingFunction];
            
            // Animates the new view to the same frame as the current view is right now
//            [[self.cachedImageView animator] setFrame:self.containerView.bounds];
            [oldRightView.animator setAlphaValue:0.0];
            
            // This is the old frame
//            [[self.oldCachedImageView animator] setFrame:[self rectForViewWithAnimationStyle:self.animationStyle oldView:YES]];
            [self.rightView.animator setAlphaValue:1.0];
            
        }
        [NSAnimationContext endGrouping];
        
//        [CATransaction begin];
//        {
//            [CATransaction setCompletionBlock:^{
//                if(self.rightHash != hash) {
//                    return;
//                }
//                
////                [oldRightView setWantsLayer:NO];
////                [self.rightView setWantsLayer:NO];
//                
//                [oldRightView removeFromSuperview];
//                [self.rightView setFrameOrigin:NSMakePoint(0, 0)];
//                [self.rightViewBlock setFrameSize:newSize];
//                [self.rightViewBlock setFrameOrigin:NSMakePoint(self.bounds.size.width - self.rightViewBlock.bounds.size.width - 30, (self.bounds.size.height - self.rightViewBlock.bounds.size.height) / 2)];
//                [self buildSizes];
//            }];
//
//            oldRightView.layer.opacity = 0;
//            self.rightView.layer.opacity = 1;
//            
//            [oldRightView.layer addAnimation:[TMAnimations fadeWithDuration:ANIM_DURATION fromValue:1 toValue:0] forKey:@"flashAnimation"];
//            [self.rightView.layer addAnimation:[TMAnimations fadeWithDuration:ANIM_DURATION fromValue:0 toValue:1] forKey:@"flashAnimation"];
//        }
//        [CATransaction commit];
        
        
    } else {
        [oldRightView removeFromSuperview];
        
        self.rightView = newRightView;
        [self.rightViewBlock addSubview:self.rightView];
        [self.rightViewBlock setFrameOrigin:NSMakePoint(self.bounds.size.width - newRightView.bounds.size.width - 15, roundf((self.bounds.size.height - newRightView.bounds.size.height) /2))];
        [self.rightViewBlock setFrameSize:newRightView.bounds.size];
        [self buildSizes];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
//	[super drawRect:dirtyRect];
    
   // [NSColorFromRGB(0xfdfdfd) set];
   // NSRectFill(dirtyRect);

    [GRAY_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end
