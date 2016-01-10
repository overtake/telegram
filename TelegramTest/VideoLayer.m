//
//  VideoLayer.m
//  MPlayerShell
//
//  Copyright (c) 2013 Don Melton
//

#import <OpenGL/gl.h>
#import "VideoLayer.h"

@implementation VideoLayer {
    CVOpenGLTextureCacheRef _textureCache;
}

static NSOpenGLPixelFormatAttribute glAttributes[] = {
    NSOpenGLPFADepthSize, 24,
    // Must specify the 3.2 Core Profile to use OpenGL 3.2
    NSOpenGLPFAOpenGLProfile,
    NSOpenGLProfileVersion3_2Core,
    0
};

-(CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat
{
     NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:glAttributes];
    
    
    pixelFormat = [pf CGLPixelFormatObj];
    
    CGLContextObj glContext = [super copyCGLContextForPixelFormat:pixelFormat];

    CGLLockContext(glContext);

    if (_textureCache) {
        CVOpenGLTextureCacheRelease(_textureCache);
    }
    
    
    if (CVOpenGLTextureCacheCreate(NULL, NULL, glContext, pixelFormat, NULL, &_textureCache)) {
        _textureCache = NULL;
    }
    CGLUnlockContext(glContext);

    return glContext;
}

-(void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if(_pixelBuffer != NULL)
    {
        CFRelease(_pixelBuffer);
        _pixelBuffer = NULL;
    }
    
    CFRetain(pixelBuffer);
    
    _pixelBuffer = pixelBuffer;
    
    [self display];
}

- (void)drawInCGLContext:(CGLContextObj)glContext
             pixelFormat:(CGLPixelFormatObj)pixelFormat
            forLayerTime:(CFTimeInterval)timeInterval
             displayTime:(const CVTimeStamp *)timeStamp
{
    CGLLockContext(glContext);
    CGLSetCurrentContext(glContext);

    CVOpenGLTextureRef texture;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    
    CVReturn status = CVOpenGLTextureCacheCreateTextureFromImage(NULL,
                                               _textureCache,
                                               self.pixelBuffer,
                                               NULL,
                                               &texture);
    
    GLfloat width = CVPixelBufferGetWidth(self.pixelBuffer);
    GLfloat height = CVPixelBufferGetHeight(self.pixelBuffer);
    
    if(status == -6683) {
        int bp = 0;
        CVPixelBufferGetPixelFormatType(self.pixelBuffer);
    }

    if (self.pixelBuffer && texture) {
        GLenum target = CVOpenGLTextureGetTarget(texture);

        glEnable(target);
        glBindTexture(target, CVOpenGLTextureGetName(texture));
        glBegin(GL_QUADS);

        

        glTexCoord2f(    0,      0);    glVertex2f(-1,  1);
        glTexCoord2f(    0, height);    glVertex2f(-1, -1);
        glTexCoord2f(width, height);    glVertex2f( 1, -1);
        glTexCoord2f(width,      0);    glVertex2f( 1,  1);

        glEnd();
        glDisable(target);

        CVOpenGLTextureRelease(texture);
    } else {
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    [super drawInCGLContext:glContext
                pixelFormat:pixelFormat
               forLayerTime:timeInterval
                displayTime:timeStamp];

    CGLUnlockContext(glContext);
}

void dataProviderFreeData(void *info, const void *data, size_t size){
    free((void *)data);
}

- (CGImageRef)processTexture:(GLuint)texture width:(int)width height:(int)height {
    CGImageRef newImage = NULL;
    
    // Set up framebuffer and renderbuffer.
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    GLuint colorRenderbuffer;
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to create OpenGL frame buffer: %x", status);
    } else {
        glViewport(0, 0, width, height);
        glClearColor(0.0,0.0,0.0,1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Do whatever is necessary to actually draw the texture to the framebuffer
      //  [self renderTextureToCurrentFrameBuffer:texture];
        
        // Read the pixels out of the framebuffer
        void *data = malloc(width * height * 4);
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
        
        // Convert the data to a CGImageRef. Note that CGDataProviderRef takes
        // ownership of our malloced data buffer, and the CGImageRef internally
        // retains the CGDataProviderRef. Hence the callback above, to free the data
        // buffer when the provider is finally released.
        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data, width * height * 4, dataProviderFreeData);
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        newImage = CGImageCreate(width, height, 8, 32, width*4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, dataProvider, NULL, true, kCGRenderingIntentDefault);
        CFRelease(dataProvider);
        CGColorSpaceRelease(colorspace);
        
        // Autorelease the CGImageRef
    }
    
    // Clean up the framebuffer and renderbuffer.
    glDeleteRenderbuffers(1, &colorRenderbuffer);
    glDeleteFramebuffers(1, &framebuffer);
    
    return newImage;
}


-(GLuint)textureFromSampleBuffer:(CVImageBufferRef)pixelBuffer {
    GLuint texture = 0;
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    GLfloat width = CVPixelBufferGetWidth(self.pixelBuffer);
    GLfloat height = CVPixelBufferGetHeight(self.pixelBuffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return texture;
}

-(void)releaseCGLContext:(CGLContextObj)glContext
{
    if (_textureCache) {
        CVOpenGLTextureCacheRelease(_textureCache);
        _textureCache = NULL;
    }
    [super releaseCGLContext:glContext];
}

@end
