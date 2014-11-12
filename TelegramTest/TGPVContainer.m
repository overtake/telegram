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
@interface TGPVContainer ()
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMNameTextField *userNameTextField;
@property (nonatomic,strong) TMTextField *dateTextField;

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
    [TGPhotoViewer nextItem];
}

-(void)initialize {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
   
 //   self.layer.cornerRadius = 6;

    self.imageView = [[TGPVImageView alloc] initWithFrame:NSMakeRect(0, bottomHeight, 0, 0)];
 //   [self.imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
 //   self.imageView.cornerRadius = 6;
    
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
    return NSMakeSize(NSWidth(screenFrame) - 100, NSHeight(screenFrame) - 140);;
}

- (NSSize)contentFullSize:(TGPhotoViewerItem *)item {
   
    
    
    TL_localMessage *msg = item.previewObject.media;
    
    TL_photoSize *photoSize = [msg.media.photo.sizes lastObject];
    
    return convertSize(NSMakeSize(photoSize.w, photoSize.h), [self maxSize]);
}

static const int bottomHeight = 60;

-(void)setCurrentViewerItem:(TGPhotoViewerItem *)currentViewerItem animated:(BOOL)animated {
    _currentViewerItem = currentViewerItem;
    
   
    
    [self.userNameTextField setUser:currentViewerItem.user];
    [self.dateTextField setStringValue:currentViewerItem.stringDate];
    self.imageView.object = currentViewerItem.imageObject;
    
    
    NSSize size = [self contentFullSize:currentViewerItem];
    
    NSSize containerSize = size;
    
    const NSSize min = NSMakeSize(200, 150);
    
    
    assert([NSThread isMainThread]);
    
    containerSize = NSMakeSize(MAX(min.width,size.width), MAX(min.height, size.height));
    
    
        
    [self setFrameSize:NSMakeSize(containerSize.width, containerSize.height)];
    
    
    
    float x = (self.superview.bounds.size.width - self.bounds.size.width) / 2;
    float y = (self.superview.bounds.size.height - self.bounds.size.height + 75) / 2;
    
    [self setFrameOrigin:NSMakePoint(roundf(x),roundf(y))];
        
  //  [self setCenterByView:self.superview];
    
    
    
    [self.imageView setFrameSize:NSMakeSize(size.width - 10, size.height - 10)];
    
    [self.imageView setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - size.width) / 2) + 5, roundf((self.bounds.size.height - size.height ) / 2) + 5)];

}



-(void)runAnimation:(TGPhotoViewerItem *)item {
    
    
    NSSize contentSize = [self contentFullSize:item];
    
    NSRect to = NSMakeRect(roundf((self.superview.bounds.size.width - contentSize.width) / 2), roundf((self.superview.bounds.size.height - contentSize.height ) / 2), contentSize.width, contentSize.height + bottomHeight);
    
//
//    
    [self setFrame:to];
    [self.imageView setFrameSize:contentSize];
    
//    
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//        [context setDuration:0.3];
//        [[self animator] setFrame:to];
//       // [[self.imageView animator] setFrameSize:contentSize];
//        
//    } completionHandler:^{
//        
//    }];
    
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




@end
