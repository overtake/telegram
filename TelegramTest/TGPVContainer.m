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
@interface TGPVContainer ()
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMNameTextField *userNameTextField;
@property (nonatomic,strong) TMTextField *dateTextField;
@property (nonatomic, strong) TMMenuPopover *menuPopover;

@property (nonatomic,strong) AVPlayerView *videoPlayerView;

@property (nonatomic,strong) MessageCellDescriptionView *photoCaptionView;

@end

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

-(void)mouseDown:(NSEvent *)theEvent {
    
    if([self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_imageView.frame])
        [TGPhotoViewer nextItem];
    //else
        //[super mouseDown:theEvent];
}

-(void)initialize {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
   
 //   self.layer.cornerRadius = 6;

    self.imageView = [[TGPVImageView alloc] initWithFrame:NSMakeRect(0, bottomHeight, 0, 0)];
 //   [self.imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
 //   self.imageView.cornerRadius = 6;
    
    _photoCaptionView = [[MessageCellDescriptionView alloc] initWithFrame:NSZeroRect];
    
    [self addSubview:self.imageView];
    
    
    
//    self.userNameTextField = [TMNameTextField defaultTextField];
//    [self.userNameTextField setSelector:@selector(titleForMessage)];
//    
//    [self.userNameTextField setFrameOrigin:NSMakePoint(0, 30)];
//    [self.userNameTextField setFrameSize:NSMakeSize(NSWidth(self.frame), 25)];
//    [self.userNameTextField setAutoresizingMask:NSViewWidthSizable];
//    
//    [self addSubview:self.userNameTextField];
//    
//    self.dateTextField = [TMTextField defaultTextField];
//    [self.dateTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
//    [self.dateTextField setAlignment:NSCenterTextAlignment];
//    [self.dateTextField setFrameOrigin:NSMakePoint(0, 15)];
//    [self.dateTextField setFrameSize:NSMakeSize(NSWidth(self.frame), 20)];
//    [self.dateTextField setAutoresizingMask:NSViewWidthSizable];
//    
//    [self addSubview:self.dateTextField];
}



-(NSSize)maxSize {
    NSRect screenFrame = [NSScreen mainScreen].frame;
    
    return NSMakeSize(NSWidth(screenFrame) - 100, NSHeight(screenFrame) - 120);;
}

- (NSSize)contentFullSize:(TGPhotoViewerItem *)item {
    
    
    NSSize size = item.imageObject.imageSize;
    
    if([item.previewObject.reservedObject isKindOfClass:[NSDictionary class]]) {
        
        size = [item.previewObject.reservedObject[@"size"] sizeValue];
        
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
    
    if([_currentViewerItem.previewObject.media isKindOfClass:[TL_localMessage class]] && [[_currentViewerItem.previewObject.media media] isKindOfClass:[TL_messageMediaPhoto class]]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:[(TL_messageMediaPhoto *)[_currentViewerItem.previewObject.media media] caption] withColor:[NSColor whiteColor]];
        
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        return attr;
    }
    return nil;
}


-(void)setCurrentViewerItem:(TGPhotoViewerItem *)currentViewerItem animated:(BOOL)animated {
    
    _currentViewerItem = currentViewerItem;
    
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
    
    
    
    float x = (self.superview.bounds.size.width - self.bounds.size.width) / 2;
    float y = (self.superview.bounds.size.height - self.bounds.size.height + 75) / 2;
    
    [self setFrameOrigin:NSMakePoint(roundf(x),roundf(y))];
    
    
    
        
  //  [self setCenterByView:self.superview];
    
   
    
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
    
    [self.imageView setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - size.width) / 2) , roundf((self.bounds.size.height - size.height + c_s.height + 10 ) / 2) )];
    
    
    if(caption) {
        [_photoCaptionView setFrame:NSMakeRect(roundf((self.frame.size.width - c_s.width) / 2), MAX(NSHeight(self.frame) - NSMaxY(_imageView.frame) ,0) , c_s.width, c_s.height)];
    }
  
    
    [self.imageView setHidden:[currentViewerItem.previewObject.reservedObject isKindOfClass:[NSDictionary class]]];
    
    
    if([currentViewerItem.previewObject.reservedObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *video = currentViewerItem.previewObject.reservedObject;
        
        NSURL *url = video[@"url"];
        
        
        if(!_videoPlayerView) {
            _videoPlayerView = [[AVPlayerView alloc] initWithFrame:NSMakeRect(0, roundf((self.frame.size.height - size.height) / 2), size.width, size.height)];
            
            [_videoPlayerView setControlsStyle:AVPlayerViewControlsStyleFloating];
            [self addSubview:_videoPlayerView];
            
            AVPlayer *player = [AVPlayer playerWithURL:url];
            _videoPlayerView.player = player;
            [player play];
        }
        
        
    } else {
        [_videoPlayerView.player pause];
        _videoPlayerView.player = nil;
        [_videoPlayerView removeFromSuperview];
        _videoPlayerView = nil;
    }

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
