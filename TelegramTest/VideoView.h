#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#include <sys/types.h>
#include <stdint.h>

@interface VideoView : NSOpenGLView
{
	//Cocoa
	NSOpenGLContext *glContext;
	NSEvent *event;
	
	NSRect screen_frame;
	NSScreen *screen_handle;
	
	//image
	unsigned char *image_data;
	uint32_t image_width;
	uint32_t image_height;
	uint32_t image_depth;
	uint32_t image_bytes;
	uint32_t image_format;
	
	int isFullscreen;
	int isOntop;
	int isRootwin;
	float monitor_aspect; // FIXME
	int vo_keepaspect;
	float movie_aspect;
	float old_movie_aspect;
	
	//CoreVideo
	
	CVOpenGLTextureCacheRef textureCache;
	CVOpenGLTextureRef texture;
	NSRect textureFrame;
	
	OSType pixelFormat;

    GLfloat     lowerLeft[2]; 
    GLfloat lowerRight[2]; 
    GLfloat upperRight[2];
    GLfloat upperLeft[2];
	
	BOOL mouseHide;
	float winSizeMult;
	//menu command id
	NSMenuItem *kQuitCmd;
	NSMenuItem *kHalfScreenCmd;
	NSMenuItem *kNormalScreenCmd;
	NSMenuItem *kDoubleScreenCmd;
	NSMenuItem *kFullScreenCmd;
	NSMenuItem *kKeepAspectCmd;
	NSMenuItem *kAspectOrgCmd;
	NSMenuItem *kAspectFullCmd;
	NSMenuItem *kAspectWideCmd;
	NSMenuItem *kPanScanCmd;
	
	
}

@property (nonatomic) CVPixelBufferRef pixelBuffer;


- (unsigned int) width;
- (unsigned int) height;
- (unsigned char*) imageBuffer;
- (unsigned int) format;

	//window & rendering
- (int) configureWidth: (uint32_t) width height: (uint32_t) height format: (uint32_t) format;
- (id) config;
- (void) prepareOpenGL;
- (void) render;
- (void) reshape;
- (void) setCurrentTexture;
- (void) drawRect: (NSRect *) bounds;

- (void) updateMono: (const char*) data; // assumes full size
- (void) updateMono: (const char*) data offset: (int) offset length: (int) len;
- (void) updateMonoWithData: (NSData*) data; // can be of any full-width size
- (void) updateMonoWithData: (NSData*) data atOffset: (int) offset; // can be of any full-width size

@end
