//
//  TMScrollView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/24/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "TMScrollAnimation.h"
#import "Butter/BTRScrollView.h"


@protocol TMScrollViewDelegate <NSObject>

@optional
-(void)scrollDidChangeFrameSize:(NSSize)size;


@end

@interface TMScrollView : BTRScrollView
@property (nonatomic) BOOL disableScrolling;
@property (nonatomic,copy) dispatch_block_t drawBlock;

@property (nonatomic) BOOL isHideVerticalScroller;
@property (nonatomic) BOOL isHideHorizontalScroller;


@property (nonatomic,strong) id <TMScrollViewDelegate> delegate;


-(void)dropScrollData;

- (BOOL) isScrollEndOfDocument;
- (BOOL) isNeedUpdateTop;
- (BOOL) isNeedUpdateRight;
- (BOOL) isNeedUpdateBottom;
- (NSPoint) documentOffset;
- (NSSize) documentSize;
- (void) scrollToPoint:(NSPoint)point animation:(BOOL)animation;
- (void) scrollToEndWithAnimation:(BOOL)animation;
-(BOOL) isAnimating;

@end
