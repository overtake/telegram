//
//  TMGLGif.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMGLGif.h"

@implementation TMGLGif

- (id)initWithImage:(NSImage *)img
{
    int i;
    NSUInteger samplesPerPixel;
    
    self = [super init];
    
    if(img == NULL) {
        DLog(@"Unable to load image named: %@", img);
        return NULL;
    }
    
    NSBitmapImageRep *rep = [[img representations] objectAtIndex:0];
    num_frames = [[rep valueForProperty:NSImageFrameCount] intValue];
    
    size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
    gif_frames = (GLuint*)malloc(num_frames*sizeof(GLuint));
    frame_times = (float*)malloc(num_frames*sizeof(float));
    
    for(i = 0; i < num_frames; i++) {
        [rep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:i]];
        frame_times[i] = [[rep valueForProperty:NSImageCurrentFrameDuration] floatValue];
        
        samplesPerPixel = [rep samplesPerPixel];
        
        if(![rep isPlanar] && (samplesPerPixel == 4 || samplesPerPixel == 3)) {
            glGenTextures(1, &gif_frames[i]);
            glBindTexture(GL_TEXTURE_RECTANGLE_EXT, gif_frames[i]);
            glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            
            
            glTexImage2D(GL_TEXTURE_RECTANGLE_EXT,
                         0,
                         samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                         (int)[rep pixelsWide],
                         (int)[rep pixelsHigh],
                         0,
                         samplesPerPixel == 4 ? GL_BGRA_EXT : GL_RGB,
#ifdef __BIG_ENDIAN__
                         GL_UNSIGNED_INT_8_8_8_8_REV,
#else
                         GL_UNSIGNED_INT_8_8_8_8,
#endif
                         [rep bitmapData]);
        }
        else {
            DLog(@"-textureFromView: Unsupported bitmap data format: isPlanar:%d, samplesPerPixel:%ld, bitsPerPixel:%ld, bytesPerRow:%ld, bytesPerPlane:%ld",
                  [rep isPlanar],
                  (long)[rep samplesPerPixel],
                  (long)
                  (long)[rep bitsPerPixel],
                  [rep bytesPerRow],
                  (long)[rep bytesPerPlane]);
            
            return NULL;
        }
    }
    
    current_frame = 0;
    time_duration = 0;
    
    return self;
}

- (void)dealloc
{
    free(gif_frames);
    free(frame_times);
    
}

- (int)numFrames
{
    return num_frames;
}

- (NSSize)size
{
    return size;
}

- (void)drawFrame:(int)frame_number at:(NSPoint)position
{
    glBindTexture (GL_TEXTURE_RECTANGLE_EXT, gif_frames[frame_number]);
    
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex2f(position.x, position.y);
    
    glTexCoord2f(size.width, 0);
    glVertex2f(size.width+position.x, position.y);
    
    glTexCoord2f(size.width, size.height);
    glVertex2f(size.width+position.x, size.height+position.y);
    
    glTexCoord2f(0, size.height);
    glVertex2f(position.x, size.height+position.y);
    glEnd();
}

- (void)drawAt:(NSPoint)position
{
    [self drawFrame:current_frame at:position];
}

- (void)animate:(float)dt
{
    time_duration += dt*0.1;
    
    while(time_duration > frame_times[current_frame]) {
        time_duration -= frame_times[current_frame];
        current_frame++;
        
        if(current_frame >= num_frames)
            current_frame = 0;
    }
}

+ (void)gifDrawingMode
{
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

@end