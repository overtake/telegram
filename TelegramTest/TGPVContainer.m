//
//  TGPVContainer.m
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVContainer.h"
#import "TGPVImageView.h"
#import "MessageTableElements.h"
#import "TGPhotoViewer.h"
#import "SelfDestructionController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MessageCellDescriptionView.h"



@interface TGZoomableImage : TGPVImageView
@property (nonatomic,assign) NSPoint startPoint;
@property (nonatomic,assign) BOOL isDragged;
@end

@implementation TGZoomableImage


-(void)mouseDown:(NSEvent *)theEvent {
   
    _startPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _isDragged = NO;
}


-(void)mouseUp:(NSEvent *)theEvent {
    _startPoint = NSZeroPoint;
    [super mouseUp:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    if(_startPoint.x == 0 || _startPoint.y == 0)
        return;
    
    if(NSWidth(self.frame) > NSWidth(self.superview.frame) || NSHeight(self.frame) > NSHeight(self.superview.frame))
    {
        
        NSPoint currentPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        
        NSSize addXY = NSMakeSize(currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y);
        
        [self addSizeToScroll:addXY];
        
       
        
    }
    
}

-(void)addSizeToScroll:(NSSize)size {
    
    [self setFrameOrigin:NSMakePoint(NSMinX(self.frame) + size.width, NSMinY(self.frame) + size.height)];
    
     _isDragged = YES;
}

-(void)scrollWheel:(NSEvent *)event {
    [super scrollWheel:event];
    
    
    if(NSWidth(self.frame) > NSWidth(self.superview.frame) || NSHeight(self.frame) > NSHeight(self.superview.frame))
    {
        
        NSSize addXY = NSMakeSize([event scrollingDeltaX], -[event scrollingDeltaY]);
        
        [self addSizeToScroll:addXY];
        
    }
    
    
}

-(void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:NSMakePoint(MIN(MAX(newOrigin.x,NSWidth(self.superview.frame) - NSWidth(self.frame)),0), MIN(MAX(newOrigin.y,NSHeight(self.superview.frame) - NSHeight(self.frame)),0))];
}

-(void)setObject:(ImageObject *)object {
    [super setObject:object];
    
    _isDragged = NO;
}

@end


@interface TGVideoPlayer : AVPlayerView
@end


@implementation TGVideoPlayer


@end


@interface TGPVContainer ()
@property (nonatomic,strong) TGZoomableImage *imageView;
@property (nonatomic,strong) TMNameTextField *userNameTextField;
@property (nonatomic,strong) TMTextField *dateTextField;
@property (nonatomic, strong) TMMenuPopover *menuPopover;

@property (nonatomic,strong) TGVideoPlayer *videoPlayerView;

@property (nonatomic,strong) MessageCellDescriptionView *photoCaptionView;



@property (nonatomic,assign) int currentIncrease;




@property (nonatomic,strong) TMView *imageContainerView;
@end


#define ZOOM_PERCENT 0.30
#define ZOOM_COUNT 10

@implementation TGPVContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    
    return self;
}

-(BOOL)isInImageContainer:(NSEvent *)theEvent {
    return [self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_imageContainerView.frame];
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if([self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_imageContainerView.frame])
        [TGPhotoViewer nextItem];
    else
        [[TGPhotoViewer viewer] hide];
}

-(void)initialize {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
   
 //   self.layer.cornerRadius = 6;

    self.imageView = [[TGZoomableImage alloc] initWithFrame:NSMakeRect(0, bottomHeight, 0, 0)];
    
    
    _photoCaptionView = [[MessageCellDescriptionView alloc] initWithFrame:NSZeroRect];
    
    
    
    _imageContainerView = [[TMView alloc] initWithFrame:NSZeroRect];
    [_imageContainerView addSubview:self.imageView];
    
    [self addSubview:_imageContainerView];
    
  //  [self addSubview:_decreaseZoomButton];
    
}


- (void)touchesBeganWithEvent:(NSEvent *)event {
    
}
- (void)touchesMovedWithEvent:(NSEvent *)event {
    
}
- (void)touchesEndedWithEvent:(NSEvent *)event {
    
}
- (void)touchesCancelledWithEvent:(NSEvent *)event  {
    
}

-(BOOL)becomeFirstResponder {
    
    [self.window makeFirstResponder:self];
    
    return [super becomeFirstResponder];
    
}

-(void)increaseZoom {
    self.currentIncrease++;
}
-(void)decreaseZoom {
    self.currentIncrease--;
}


-(void)setCurrentIncrease:(int)currentIncrease {
    
    int n = MAX(MIN(ZOOM_COUNT,currentIncrease),0);
    
    if(n == _currentIncrease || _imageContainerView.isHidden)
        return;
    
    _currentIncrease = n;
    
    
    [_photoCaptionView setHidden:_currentIncrease > 0];
    
    if(_currentIncrease > 0)
    {
        NSSize size = self.currentViewerItem.imageObject.imageSize;
        
        size.width+= roundf((size.width * ZOOM_PERCENT) * _currentIncrease);
        size.height+= roundf((size.height *  ZOOM_PERCENT) * _currentIncrease);
        
        
        NSSize maxSize = [self maxSize];
        
        
       
        NSSize difSize = NSMakeSize(NSWidth(_imageView.frame),NSHeight(_imageView.frame));
        
        [_imageView setFrameSize:size];
        
        
        [_imageContainerView setFrameSize:NSMakeSize(MIN(maxSize.width,size.width), MIN(maxSize.height,size.height))];
        [self setFrameSize:NSMakeSize(_imageContainerView.frame.size.width, maxSize.height)];
        
        
        difSize.width = NSWidth(_imageView.frame) - difSize.width;
        difSize.height = NSHeight(_imageView.frame) - difSize.height;
        
        
        if(!_imageView.isDragged)
        {
            [_imageView setCenterByView:_imageContainerView];
        } else {
            [_imageView setFrameOrigin:NSMakePoint(NSMinX(_imageView.frame) - difSize.width/2, NSMinY(_imageView.frame) - difSize.height/2)];
        }
        
        [self updateContainerOrigin];
        
        [_imageContainerView setCenterByView:self];
        
        
        
    } else {
        [self setCurrentViewerItem:_currentViewerItem animated:NO];
    }
    
    
    
}


/*
 -(void)setCurrentIncrease:(int)currentIncrease {
 
 int n = MAX(MIN(ZOOM_COUNT,currentIncrease),0);
 
 if(n == _currentIncrease || _imageContainerView.isHidden)
 return;
 
 _currentIncrease = n;
 
 
 if(_currentIncrease > 0)
 {
 NSSize size = self.currentViewerItem.imageObject.imageSize;
 
 size.width+= roundf((size.width * ZOOM_PERCENT) * _currentIncrease);
 size.height+= roundf((size.height *  ZOOM_PERCENT) * _currentIncrease);
 
 
 NSSize maxSize = [self maxSize];
 
 NSSize difSize = NSMakeSize(NSWidth(_imageView.frame),NSHeight(_imageView.frame));
 
 [_imageView setFrameSize:size];
 
 
 
 NSSize containerSize = NSMakeSize(MIN(maxSize.width,size.width), MIN(maxSize.height,size.height));
 
 NSPoint containerPoint = NSMakePoint(roundf((containerSize.width - containerSize.width) / 2), ((maxSize.height - containerSize.height) / 2));
 
 
 
 
 
 [self setFrameSize:NSMakeSize(containerSize.width, maxSize.height)];
 [self updateContainerOrigin];
 
 // self.backgroundColor = [NSColor redColor];
 
 [_imageContainerView setCenterByView:self];
 
 _imageContainerView.layer.backgroundColor = [NSColor blueColor].CGColor;
 
 {
 
 
 if(_imageContainerView.layer.anchorPoint.x == 0) {
 _imageContainerView.layer.anchorPoint = NSMakePoint(0.5, 0.5);
 CGPoint point = _imageContainerView.layer.position;
 
 point.x += roundf(_imageContainerView.frame.size.width / 2);
 point.y += roundf(_imageContainerView.frame.size.height / 2);
 
 _imageContainerView.layer.position = point;
 }
 
 POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
 anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
 anim.fromValue = [NSValue valueWithSize:_imageContainerView.frame.size];
 anim.toValue = [NSValue valueWithSize:containerSize];
 anim.duration = 0.1;
 anim.removedOnCompletion = YES;
 
 [anim setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
 [_imageContainerView setFrame:NSMakeRect(containerPoint.x, containerPoint.y, containerSize.width, containerSize.height)];
 }];
 
 [_imageContainerView.layer pop_addAnimation:anim forKey:@"scale"];
 }
 
 
 
 {
 POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
 anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 anim.fromValue = [NSValue valueWithPoint:_imageContainerView.frame.origin];
 anim.toValue = [NSValue valueWithPoint:containerPoint];
 anim.removedOnCompletion = YES;
 
 
 //    [_imageContainerView.layer pop_addAnimation:anim forKey:@"position"];
 }
 
 
 //  [_imageContainerView setFrameSize:NSMakeSize(MIN(maxSize.width,size.width), MIN(maxSize.height,size.height))];
 
 
 difSize.width = NSWidth(_imageView.frame) - difSize.width;
 difSize.height = NSHeight(_imageView.frame) - difSize.height;
 
 
 if(!_imageView.isDragged)
 {
 [_imageView setCenterByView:_imageContainerView];
 } else {
 [_imageView setFrameOrigin:NSMakePoint(NSMinX(_imageView.frame) - difSize.width/2, NSMinY(_imageView.frame) - difSize.height/2)];
 }
 
 [self updateContainerOrigin];
 
 // [_imageContainerView setCenterByView:self];
 } else {
 [self setCurrentViewerItem:_currentViewerItem animated:NO];
 }
 
 
 }
 */

-(NSSize)maxSize {
    NSRect screenFrame = [NSScreen mainScreen].frame;
    
    return NSMakeSize(NSWidth(screenFrame) - 100, NSHeight(screenFrame) - 120);;
}

- (NSSize)contentFullSize:(TGPhotoViewerItem *)item {
    
    
    NSSize size = item.imageObject.imageSize;
    
    if([item.previewObject.reservedObject isKindOfClass:[NSDictionary class]]) {
        
        size = [item.previewObject.reservedObject[@"size"] sizeValue];
        
        if(size.width == 0 || size.height == 0) {
            size = NSMakeSize(1024, 720);
        }
        
    }
    
    NSSize maxSize = [self maxSize];
    
    
    NSAttributedString *caption = [self caption];
    if(caption) {
        NSSize s = [caption sizeForTextFieldForWidth:size.width];
        
        maxSize.height-=(s.height+20);
    }
    
     return convertSize(size, maxSize);
}

-(void)copy:(id)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:[NSArray arrayWithObject:[NSURL fileURLWithPath:locationFilePath(self.currentViewerItem.imageObject.location, @"jpg")]]];
}




//-(BOOL)respondsToSelector:(SEL)aSelector {
//    
//    
//    if(aSelector == @selector(copy:)) {
//        return NO;
//    }
//    
//    return [super respondsToSelector:aSelector];
//}


static const int bottomHeight = 60;

-(NSAttributedString *)caption {
    
    if([_currentViewerItem.previewObject.media isKindOfClass:[TL_localMessage class]] && [[(TL_localMessage *)_currentViewerItem.previewObject.media media] isKindOfClass:[TL_messageMediaPhoto class]]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:[(TL_messageMediaPhoto *)[(TL_localMessage *)_currentViewerItem.previewObject.media media] caption] withColor:[NSColor whiteColor]];
        
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        return attr;
    }
    return nil;
}


-(void)updateContainerOrigin {
    float x = (self.superview.bounds.size.width - self.bounds.size.width) / 2;
    float y = (self.superview.bounds.size.height - self.bounds.size.height + 75) / 2;
    
    [self setFrameOrigin:NSMakePoint(roundf(x),roundf(y))];
}

-(void)setCurrentViewerItem:(TGPhotoViewerItem *)currentViewerItem animated:(BOOL)animated {
    
    _currentViewerItem = currentViewerItem;
    
    _currentIncrease = 0;
    
    self.imageView.object = currentViewerItem.imageObject;
    
    
    if([currentViewerItem.previewObject.media isKindOfClass:[TL_destructMessage class]]) {
        
        TL_destructMessage *msg = (TL_destructMessage *) currentViewerItem.previewObject.media;
        
        if(msg.ttl_seconds != 0 && msg.destruction_time == 0 && !msg.n_out) {
            [SelfDestructionController addMessage:msg force:YES];
        }
        
    }
    
    
    NSSize size = [self contentFullSize:currentViewerItem];
    
    NSSize containerSize = size;
    
    const NSSize min = NSMakeSize(200, 150);
    
    
    assert([NSThread isMainThread]);
    
    containerSize = NSMakeSize(MAX(min.width,size.width), MAX(min.height, size.height));
    
    
        
    [self setFrameSize:NSMakeSize(containerSize.width, [self maxSize].height)];
    
    [self updateContainerOrigin];
    
    
    NSAttributedString *caption = [self caption];
    
    NSSize c_s = NSZeroSize;
    
    [_photoCaptionView setHidden:caption.length == 0];
    
    if(caption.length > 0) {
        
        c_s = [caption sizeForTextFieldForWidth:size.width - 20];
        c_s.width = ceil(c_s.width + 6);
        c_s.height = ceil(c_s.height + 5);
        
        
        [_photoCaptionView setString:caption];
        
        [self addSubview:_photoCaptionView];
        
    } else {
        [_photoCaptionView removeFromSuperview];
    }
    
    [self.imageView setFrameSize:NSMakeSize(size.width , size.height )];
    [self.imageView setFrameOrigin:NSZeroPoint];
    
    [self.imageContainerView setFrameSize:self.imageView.frame.size];
    
    
    [self.imageContainerView setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - NSWidth(self.imageView.frame)) / 2) , roundf((self.bounds.size.height - NSHeight(self.imageView.frame) + c_s.height + 10 ) / 2) )];
    
    
    if(caption) {
        [_photoCaptionView setFrame:NSMakeRect(roundf((self.frame.size.width - c_s.width) / 2), MAX(NSHeight(self.frame) - NSMaxY(_imageContainerView.frame) ,0) , c_s.width, c_s.height)];
    }
  
    
    [self.imageContainerView setHidden:[currentViewerItem.previewObject.reservedObject isKindOfClass:[NSDictionary class]]];
    
    
    if([currentViewerItem.previewObject.reservedObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *video = currentViewerItem.previewObject.reservedObject;
        
        NSURL *url = video[@"url"];
        
        
        if(!_videoPlayerView) {
            
            _videoPlayerView = [[TGVideoPlayer alloc] initWithFrame:NSMakeRect(0, roundf((self.frame.size.height - size.height) / 2), size.width, size.height)];
            _videoPlayerView.showsFullScreenToggleButton = YES;
            [_videoPlayerView setControlsStyle:AVPlayerViewControlsStyleFloating];
            [self addSubview:_videoPlayerView];
            
            AVPlayer *player = [AVPlayer playerWithURL:url];
            _videoPlayerView.player = player;
            
            dispatch_async(dispatch_get_current_queue(), ^{
                if(player.status == AVPlayerStatusReadyToPlay &&
                   player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                    [player play];
                }
            });
            
            
            
        }
        
        
    } else {
        
        [_videoPlayerView.player pause];
        
        
        _videoPlayerView.player = nil;
        [_videoPlayerView removeFromSuperview];
        _videoPlayerView = nil;
    }

}

-(BOOL)ifVideoFullScreenPlayingNeedToogle {
    
    
    if(NSWidth(_videoPlayerView.frame) == NSWidth([NSScreen mainScreen].frame)) {
        return YES;
    }
    
    return NO;

}



-(void)runAnimation:(TGPhotoViewerItem *)item {
    
    
    NSSize contentSize = [self contentFullSize:item];
    
    NSRect to = NSMakeRect(roundf((self.superview.bounds.size.width - contentSize.width) / 2), roundf((self.superview.bounds.size.height - contentSize.height ) / 2), contentSize.width, contentSize.height + bottomHeight);
    
//
//    
    [self setFrame:to];
    [self.imageView setFrameSize:contentSize];
    
//    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [context setDuration:0.3];
        [[self animator] setFrame:to];
       // [[self.imageView animator] setFrameSize:contentSize];
        
    } completionHandler:^{
        
    }];
    
   // self.layer.opacity = 0.2;
    
    
//    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    
//    opacity.fromValue = @(0.2);
//    opacity.toValue = @(1.0);
//    
//    [self.layer addAnimation:opacity forKey:@"opacity"];
  //  self.layer.opacity = 1.0;
    
//    
//
//    POPBasicAnimation *animationSize = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
//    
//    animationSize.duration = 0.4;
//    
//    animationSize.fromValue = [NSValue valueWithCGSize:from.size];
//    
//    animationSize.toValue = [NSValue valueWithCGSize:to.size];
//    
//    [self.layer pop_addAnimation:animationSize forKey:@"animationSize"];
//    
    
//    POPBasicAnimation *animationPosition = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
//    
//    animationPosition.duration = 0.4;
//    
//    animationPosition.fromValue = [NSValue valueWithCGPoint:from.origin];
//    
//    animationPosition.toValue = [NSValue valueWithCGPoint:to.origin];
//    
//    [self.layer pop_addAnimation:animationPosition forKey:@"position"];
    
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Menu",NSStringFromClass([[TGPhotoViewer behavior] class])]);
    
    if(![[[TGPhotoViewer viewer] controls] respondsToSelector:selector])
        return;
    
    
    if(!self.menuPopover) {
        
        self.menuPopover = [[TMMenuPopover alloc] initWithMenu:[[[TGPhotoViewer viewer] controls] performSelector:selector]];
    }
    
    if(!self.menuPopover.isShown) {
        NSRect rect = NSZeroRect;
        rect.origin = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        weak();
        [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {
            weakSelf.menuPopover = nil;
        }];
        [self.menuPopover showRelativeToRect:rect ofView:self preferredEdge:CGRectMinYEdge];
    }
    
    //    [self.attachMenu popUpForView:self.attachButton];
}


@end
