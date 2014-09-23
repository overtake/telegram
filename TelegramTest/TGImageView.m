//
//  TGImageView.m
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGImageView.h"
#import "ImageCache.h"
#import "TGFileLocation+Extensions.h"
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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)setObject:(TGImageObject *)object {

    
     self->_object = object;
    
    self.image = nil;
    
    object.imageView = self;
    object.delegate = self;
    
    if(self.roundSize) {
        BTRImage *image = (BTRImage *)[self getCacheImageByHash:[self getKeyFromFileLocation:object.location]];
        if(image) {
            self.image = image;
            return;
        } else {
            image = (BTRImage *)[[ImageCache sharedManager] imageFromMemory:object.location];
            
            if(image) {
               
                image = (BTRImage *)[self roundedImage:image size:object.imageSize];
                
                self.image = image;
                
                [[ImageCache sharedManager] setRoundImageToMemory:image hash:[self getKeyFromFileLocation:object.location]];
                return;
            }
        }
        
        
        self.image = object.placeholder ? [self roundedImage:object.placeholder size:object.imageSize] : nil;
        
    } else {
        NSImage *image = [[ImageCache sharedManager] imageFromMemory:object.location];
        if(image) {
            self.image = (BTRImage *)image;
            return;
        }
        self.image = object.placeholder ? object.placeholder : nil;
    }
    
    
  
    
    
    [object initDownloadItem];
    
}


-(void)didDownloadImage:(NSImage *)newImage object:(TGImageObject *)object {
    if(newImage) {
        [[ImageCache sharedManager] setImage:newImage forLocation:object.location];
        if(object.location.hashCacheKey == self.object.location.hashCacheKey) {
            if(self.roundSize) {
                
                __block NSImage *roundImage;
                
                weakify();
                
                [ASQueue dispatchOnStageQueue:^{
                    if([self.object.location hashCacheKey] == [object.location hashCacheKey]) {
                        
                        if(!NSSizeNotZero(object.imageSize)) {
                            object.imageSize = self.frame.size;
                        }
                        
                        
                        NSImage *img = newImage;
                        
                        //crop image if size < realsize and < const
                        
                        if(NSSizeNotZero(object.realSize) && NSSizeNotZero(object.imageSize) && object.realSize.width > MIN_IMG_SIZE.width && object.realSize.width > MIN_IMG_SIZE.height && object.imageSize.width == MIN_IMG_SIZE.width && object.imageSize.height == MIN_IMG_SIZE.height) {
                            
                            int difference = roundf( (object.realSize.width - object.imageSize.width) /2);
                            
                            img = cropImage(newImage,object.imageSize, NSMakePoint(difference, 0));
                            
                        }
                        
                        roundImage = [self roundedImage:img size:object.imageSize];
                        [[ImageCache sharedManager] setRoundImageToMemory:roundImage hash:[self getKeyFromFileLocation:object.location]];
                        [[ASQueue mainQueue] dispatchOnQueue:^{
                            
                            [strongSelf setImage:roundImage];
                            
                            strongSelf = nil;
                        }];
                    
                    }
                    
                    
                }];
                
                return;
            }
            
            [self setImage:newImage];
        }
        
    }
 
}




- (NSImage *) getCacheImageByHash:(NSUInteger)hash {
    return [[ImageCache sharedManager] roundImageFromMemoryByHash:hash];
}

- (NSUInteger) getKeyFromFileLocation:(TGFileLocation *)fileLocation {
    NSString *string = [NSString stringWithFormat:@"%d_%f_%lu", self.roundSize, [self.borderColor redComponent], fileLocation.hashCacheKey];
    return [string hash];
}


- (NSImage *) roundedImage:(NSImage *)oldImage size:(NSSize)size {
    
    if(!oldImage)
        return oldImage;
    
    static CALayer *layer;
    if(!layer) {
        layer = [CALayer layer];
    }
    

    
    
    NSImage *image = nil;
    @autoreleasepool {
        CGFloat displayScale = [[NSScreen mainScreen] backingScaleFactor];
        
        size.width *= displayScale;
        size.height *= displayScale;

        if(self.blurRadius) {
            oldImage = [ImageUtils blurImage:oldImage blurRadius:self.blurRadius frameSize:size];
        }
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[oldImage TIFFRepresentation], NULL);
        
        if(source != NULL) {
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
            
            [layer setContents:(__bridge id)(maskRef)];
            [layer setFrame:NSMakeRect(0, 0, size.width, size.height)];
            [layer setBounds:NSMakeRect(0, 0, size.width, size.height)];
            [layer setMasksToBounds:YES];
            
            
            if(self.borderWidth) {
               
               // [layer setBorderColor:self.borderColor.CGColor];
               // [layer setBorderWidth:self.borderWidth * displayScale];

                
            } else {
                [self.borderLayer setBorderWidth:0];
            }
            
            
            
            [layer setCornerRadius:self.roundSize * displayScale];
            
            
            
            CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                         size.width,
                                                         size.height,
                                                         8 /*bitsPerComponent*/,
                                                         0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                         [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                         kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
            [layer renderInContext:context];
            
            
            CGImageRef cgImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            
            
            
            image = [[NSImage alloc] initWithCGImage:cgImage size:size];
            CGImageRelease(cgImage);
            CGImageRelease(maskRef);
        }
    }
    
    return image;
}

-(BOOL)dragFile:(NSString *)filename fromRect:(NSRect)rect slideBack:(BOOL)aFlag event:(NSEvent *)event {
    return YES;
}




- (void) setTapBlock:(dispatch_block_t)tapBlock {
    if(tapBlock) {
        
    } else {
        
    }
    
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
        [super mouseDown:theEvent];
    }
}


@end
