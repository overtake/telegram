
#import <Cocoa/Cocoa.h>

@interface VideoLayer : CAOpenGLLayer

-(void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end
