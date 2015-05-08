//
//  TGImageView.m
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGImageView.h"
#import "TLFileLocation+Extensions.h"
#import "TGCache.h"
@interface TGImageView ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic,strong) CALayer *borderLayer;
@end

@implementation TGImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSImage *)cachedImage:(NSString *)key {
    return [TGCache cachedImage:key group:@[IMGCACHE]];
}


-(NSImage *)cachedThumb:(NSString *)key {
    return self.object.placeholder;
}


-(void)setObject:(ImageObject *)object {
    
    if(_object.delegate == self)
        object.delegate = nil;
    

     self->_object = object;
    
    NSImage *image = [self cachedImage:[object cacheKey]];
    if(image) {
        self.image = image;
        return;
    }
        
    self.image = [self cachedThumb:[object cacheKey]];
  
    object.delegate = self;
    
    [object initDownloadItem];
    
}


-(void)didDownloadImage:(NSImage *)newImage object:(ImageObject *)object {
    if([[object cacheKey] isEqualToString:[self.object cacheKey]]) {
        if(object.class != NSClassFromString(@"TGPVImageObject"))
            [self addAnimation:contentAnimation() forKey:@"contents"];
        [self setImage:newImage];
        
    }
}



-(BOOL)dragFile:(NSString *)filename fromRect:(NSRect)rect slideBack:(BOOL)aFlag event:(NSEvent *)event {
    return YES;
}




- (void) setTapBlock:(dispatch_block_t)tapBlock {
    self->_tapBlock = tapBlock;
}

- (void) updateTrackingAreas {
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void) cursorUpdate:(NSEvent *)event {
    [super cursorUpdate:event];
    
    if(self.tapBlock) {
       // NSCursor *cursor = [NSCursor pointingHandCursor];
      //  [cursor setOnMouseEntered:YES];
       // [cursor set];
    }
}

- (void) mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [self.window invalidateCursorRectsForView:self];
}

- (void) mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [self.window invalidateCursorRectsForView:self];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}


- (void)mouseUp:(NSEvent *)theEvent  {
    
    if(self.isNotNeedHackMouseUp) {
        [super mouseUp:theEvent];
        return;
    }
    
    
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL isInside = [self mouse:mouseLoc inRect:[self bounds]];
    
    if(self.tapBlock && isInside) {
        //  dispatch_async(dispatch_get_main_queue(), ^{
        self.tapBlock();
        //});
    } else {
        [super mouseUp:theEvent];
    }
}

static CAAnimation *contentAnimation() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .2;
    });
    return animation;
}


@end
