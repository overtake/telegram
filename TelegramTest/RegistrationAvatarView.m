//
//  RegistrationAvatarView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "RegistrationAvatarView.h"
#import <Quartz/Quartz.h>
#import "TMImageUtils.h"

@interface RegistrationAvatarView()
@property (nonatomic, strong) TMTextField *placeholderTextField;
@end

@implementation RegistrationAvatarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [self image2];
        
        self.placeholderTextField = [[TMTextField alloc] init];
        [self.placeholderTextField setEditable:NO];
        [self.placeholderTextField setBordered:NO];
        [self.placeholderTextField setFont:TGSystemFont(15)];
        [self.placeholderTextField setTextColor:NSColorFromRGB(0xc8c8c8)];
        [self.placeholderTextField setStringValue:NSLocalizedString(@"Registration.AddPhoto", nil)];
        [self.placeholderTextField setAlignment:NSCenterTextAlignment];
        [self.placeholderTextField sizeToFit];
        [self.placeholderTextField setCenterByView:self];
        [self addSubview:self.placeholderTextField];
        
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds
                                                           options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect)
                                                             owner:self userInfo:nil]];
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    if(!self.photo) {
        [self.placeholderTextField setTextColor:NSColorFromRGB(0xa8a8a8)];
        self.image = [self image1];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    if(!self.photo) {
        [self.placeholderTextField setTextColor:NSColorFromRGB(0xc8c8c8)];
        self.image = [self image2];
    }
}

- (void)photoTake {
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    [pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
	[pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(640, 640)] forKey:IKPictureTakerOutputImageMaxSizeKey];
    [pictureTaker beginPictureTakerSheetForWindow:self.window withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
}

- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf {
    if(returnCode == NSOKButton){
        NSImage *outputImage = [pictureTaker outputImage];
        if(outputImage.size.width >= 100 && outputImage.size.height >= 100) {
            self.photo = outputImage;
            NSImage *image = [TMImageUtils roundedImageNew:outputImage size:self.bounds.size];
            [self.placeholderTextField setHidden:YES];
            [self addAnimation:ani3() forKey:@"contents"];
            self.image = image;

        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    MTLog(@"isLeft %d isRight %d", theEvent.isLeftMouseButtonClick, theEvent.isRightMouseButtonClick);
    
    if(theEvent.isLeftMouseButtonClick) {
        [self photoTake];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItem:[NSMenuItem menuItemWithTitle:self.photo ? NSLocalizedString(@"Registration.ChangePhoto", nil) : NSLocalizedString(@"Registration.ChoosePhoto", nil) withBlock:^(id sender) {
        [self photoTake];
    }]];
    if(self.photo) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Registration.DeletePhoto", nil) withBlock:^(id sender) {
            [self removePhoto];
        }]];
    }
    
//    NSPoint point = [NSEvent mouseLocation];

    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
//    [menu popUpForView:self];
}

- (void)removePhoto {
    self.photo = nil;
    [self addAnimation:ani3() forKey:@"opacity"];
    self.image = [self image2];
    [self.placeholderTextField prepareForAnimation];
    self.placeholderTextField.layer.opacity = 0;
    [self.placeholderTextField setHidden:NO];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.placeholderTextField setWantsLayer:NO];
    }];
    [self.placeholderTextField setAnimation:[TMAnimations fadeWithDuration:0.5 fromValue:0 toValue:1] forKey:@"opacity"];
    [CATransaction commit];
}

- (NSImage *)image1 {
    int width = 102;
    int widthNormal = 100;
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, width)];
    [image lockFocus];
    [NSColorFromRGB(0xc9c9c9) set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithRoundedRect:NSMakeRect(1, 1, widthNormal, widthNormal) xRadius:widthNormal/2 yRadius:widthNormal/2];
    [path stroke];
    [image unlockFocus];
    return image;
}

- (NSImage *)image2 {
    int width = 102;
    int widthNormal = 100;

    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, width)];
    [image lockFocus];
    [NSColorFromRGB(0xe9e9e9) set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithRoundedRect:NSMakeRect(1, 1, widthNormal, widthNormal) xRadius:widthNormal/2 yRadius:widthNormal/2];
    [path stroke];
    [image unlockFocus];
    
    return image;
}

static CAAnimation *ani3() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .5;
    });
    return animation;
}

@end
