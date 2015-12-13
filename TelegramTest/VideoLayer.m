
#import <OpenGL/gl.h>
#import "VideoLayer.h"

@implementation VideoLayer {
    CVOpenGLTextureCacheRef _textureCache;
    CVOpenGLTextureRef _texture;
    GLfloat _frameWidth;
    GLfloat _frameHeight;
}

-(CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat
{
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

    if(pixelBuffer != NULL) {
        CFRetain(pixelBuffer);
        
        CVOpenGLTextureCacheCreateTextureFromImage(NULL,
                                                   _textureCache,
                                                   pixelBuffer,
                                                   NULL,
                                                   &_texture);
        
        _frameWidth = CVPixelBufferGetWidth(pixelBuffer);
        _frameHeight = CVPixelBufferGetHeight(pixelBuffer);
        
        CFRelease(pixelBuffer);
    }
    
}


- (void)drawInCGLContext:(CGLContextObj)glContext
             pixelFormat:(CGLPixelFormatObj)pixelFormat
            forLayerTime:(CFTimeInterval)timeInterval
             displayTime:(const CVTimeStamp *)timeStamp
{
    CGLLockContext(glContext);
    CGLSetCurrentContext(glContext);

    
    if (_texture != NULL) {
        GLenum target = CVOpenGLTextureGetTarget(_texture);

        glEnable(target);
        glBindTexture(target, CVOpenGLTextureGetName(_texture));
        glBegin(GL_QUADS);


        glTexCoord2f(    0,      0);    glVertex2f(-1,  1);
        glTexCoord2f(    0, _frameHeight);    glVertex2f(-1, -1);
        glTexCoord2f(_frameWidth, _frameHeight);    glVertex2f( 1, -1);
        glTexCoord2f(_frameWidth,      0);    glVertex2f( 1,  1);
        

        glEnd();
      //  glBindTexture(GL_TEXTURE_2D, 0);
        glDisable(target);
        

      //  CVOpenGLTextureRelease(_texture);
        _texture = NULL;
    
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

-(void)dealloc {
    if(_texture != NULL)
        CFRelease(_texture);
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
