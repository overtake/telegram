//
//  TMNavigationBar.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMNavigationBar.h"
#import "NSString+Extended.h"
#import "TGAnimationBlockDelegate.h"
#define ANIM_DURATION 2.05

@interface TMNavigationBar()<ConnectionStatusDelegate>

@property (nonatomic, strong) TMView *leftViewBlock;
@property (nonatomic, strong) TMView *centerViewBlock;
@property (nonatomic, strong) TMView *rightViewBlock;


@property (nonatomic,strong) ConnectionStatusViewControllerView *connectionView;

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
        [self.centerViewBlock setWantsLayer:YES];
        [self addSubview:self.centerViewBlock];
        
        self.rightViewBlock = [[TMView alloc] initWithFrame:NSZeroRect];
        [self.rightViewBlock setAutoresizingMask:YES];
        [self.rightViewBlock setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:self.rightViewBlock];
        
        self.connectionView = [[ConnectionStatusViewControllerView alloc] initWithFrame:NSZeroRect];
        
        self.connectionView.delegate = self;
        
        [self.connectionView setWantsLayer:YES];
        
        [self addSubview:self.connectionView];
        

        
    }
    return self;
}

static const float duration = 0.25;

-(void)showConnectionController:(BOOL)animated {
    
    [self changeConnection:YES animated:animated];
   
}


-(void)changeConnection:(BOOL)show animated:(BOOL)animated {
    
    [self.connectionView.layer removeAllAnimations];
    [self.centerViewBlock.layer removeAllAnimations];
    
    
    [self.connectionView setFrameOrigin:NSMakePoint(NSMinX(self.connectionView.frame), !show ? 0 : NSHeight(self.connectionView.frame))];
    [self.centerViewBlock setFrameOrigin:NSMakePoint(NSMinX(self.centerViewBlock.frame), 0)];
    
    
    if(animated) {
        
        [self.connectionView setHidden:NO];
        
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [[self.connectionView animator] setFrameOrigin:NSMakePoint(NSMinX(self.connectionView.frame), show ? 0 : NSHeight(self.connectionView.frame))];
            
            [[self.centerView animator] setFrameOrigin:NSMakePoint(NSMinX(self.centerView.frame), !show ? 0 : -NSHeight(self.centerViewBlock.frame))];
            
        } completionHandler:^{
        
        }];
        
//        TGAnimationBlockDelegate *connectionDelegate = [[TGAnimationBlockDelegate alloc] initWithLayer:self.connectionView.layer];
//        
//       // [CATransaction begin];
//        
//        POPBasicAnimation *connectionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
//        
//        connectionAnimation.duration = duration;
//        connectionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        
//        connectionAnimation.toValue = @( show ? 0 : NSHeight(self.connectionView.frame)  );
//        connectionAnimation.fromValue = @( show ? NSHeight(self.connectionView.frame) : 0 );
//        connectionAnimation.delegate = connectionDelegate;
//        connectionAnimation.removedOnCompletion = YES;
//        
//        
//        [connectionDelegate setCompletion:^(BOOL isFinished) {
//            if(isFinished)
//                [self.connectionView setFrameOrigin:NSMakePoint(NSMinX(self.connectionView.frame), [connectionAnimation.toValue floatValue])];
//        }];
//
//        [self.connectionView.layer pop_addAnimation:connectionAnimation forKey:@"position"];
//        
//        
//        TGAnimationBlockDelegate *centerDelegate = [[TGAnimationBlockDelegate alloc] initWithLayer:self.connectionView.layer];
//        
//        POPBasicAnimation *centerAnimation =[POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
//        
//        centerAnimation.duration = duration;
//        centerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        
//        centerAnimation.toValue = @( !show ? 0 : -NSHeight(self.centerViewBlock.frame) );
//        centerAnimation.fromValue = @( !show ? -NSHeight(self.centerViewBlock.frame) : 0 );
//        centerAnimation.delegate = centerDelegate;
//        centerAnimation.removedOnCompletion = YES;
//        
//      //  self.centerViewBlock.layer.position = CGPointMake(NSMinX(self.connectionView.frame), [centerAnimation.toValue floatValue]);
//        
//        [centerDelegate setCompletion:^(BOOL isFinished) {
//            if(isFinished)
//                [self.centerViewBlock setFrameOrigin:NSMakePoint(NSMinX(self.centerViewBlock.frame), 0)];
//        }];
//        
//        [self.centerViewBlock.layer pop_addAnimation:centerAnimation forKey:@"position"];
//        
//     //   [CATransaction commit];
        
        
    } else {
       
        [self.connectionView setHidden:!show];
        
        [self.connectionView setFrameOrigin:NSMakePoint(NSMinX(self.connectionView.frame), show ? 0 : NSHeight(self.connectionView.frame))];
        [self.centerViewBlock setFrameOrigin:NSMakePoint(NSMinX(self.centerViewBlock.frame), 0)];
        
    }
    
}



-(void)hideConnectionController:(BOOL)animated {
     [self changeConnection:NO animated:animated];
}

-(void)setConnectionState:(ConnectingStatusType)state {
    [self.connectionView setState:state];
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
  //  [self.centerView setAutoresizingMask:NSViewWidthSizable];
    [self.centerView setFrameSize:NSMakeSize(self.centerViewBlock.bounds.size.width, self.centerViewBlock.bounds.size.height)];
    [self.centerViewBlock addSubview:self.centerView];
    [self.centerViewBlock setFrameOrigin:NSMakePoint(0, 0)];
    [self buildSizes];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self buildSizes];
}

- (void) buildSizes {
    float maxSize = MAX(self.leftView.frame.size.width, self.rightView.frame.size.width);
    
    [self.centerViewBlock setFrameSize:NSMakeSize(self.bounds.size.width - 20 - maxSize * 2, self.bounds.size.height)];
    [self.centerViewBlock setCenteredXByView:self.centerViewBlock.superview];
    [self.centerView setFrame:self.centerViewBlock.bounds];
    
    
    [self.centerView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [obj setCenteredXByView:self.centerView];
        
    }];
    
    [self.connectionView setFrame:self.centerViewBlock.frame];
    
    if(self.connectionView.state == ConnectingStatusTypeNormal || self.connectionView.state == ConnectingStatusTypeConnected) {
        [self.connectionView hide:NO];
    } else {
        [self.connectionView show:NO];
    }
    
    
    
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
    
    [NSColorFromRGB(0xffffff) set];
    NSRectFill(dirtyRect);

    [GRAY_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}

@end
