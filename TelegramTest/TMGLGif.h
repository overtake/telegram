//
//  TMGLGif.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>

@interface TMGLGif : NSObject {
    int num_frames;
    NSSize size;
    GLuint* gif_frames;
    float* frame_times;
    
    int current_frame;
    float time_duration;
}

- (id)initWithImage:(NSImage *)image;

- (int)numFrames;
- (NSSize)size;

- (void)drawFrame:(int)frame_number at:(NSPoint)position;
- (void)drawAt:(NSPoint)position;
- (void)animate:(float)dt;

+ (void)gifDrawingMode;

@end