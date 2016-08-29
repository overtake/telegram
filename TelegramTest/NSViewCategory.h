//
//  NSViewCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CALayerOpacityAnimation = 1,
    CALayerPositionAnimation = 2,
    CALayerHeightAnimation = 3
} CALayerAnimations;



@interface NSView (Category)

- (void)setCenterByView:(NSView *)view;
- (void)setCenteredXByView:(NSView *)view;
- (void)setCenteredYByView:(NSView *)view;
- (CGPoint)center;

- (void)prepareForAnimation;

- (void)setAnimation:(CAAnimation *)anim forKey:(NSString *)key;
-(void)removeFromSuperview:(BOOL)animated;
-(CABasicAnimation *)moveWithCAAnimation:(NSPoint)position animated:(BOOL)animated;
-(void)heightWithCAAnimation:(NSRect)rect animated:(BOOL)animated;
-(void)widthWithCAAnimation:(NSRect)rect animated:(BOOL)animated;

-(void)performCAFade:(BOOL)animated;
-(void)performCAShow:(BOOL)animated;
-(void)performShake:(dispatch_block_t)completeBlock;
- (void)removeAllSubviews;
- (id)superviewByClass:(NSString *)className;
@end
