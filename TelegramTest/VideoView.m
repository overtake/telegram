/*
 videoTools - R package; display raw frame buffer on Mac OS X
 
 (C)Copyright 2007 Simon Urbanek <urbanek@r-project.org>
 
 Parts based on vo_macosx MPlayer Mac OSX video out module by 
 Nicolas Plourde <nicolasplourde@gmail.com> Copyright (c) 2005
 
 License: GPL v2
*/

#include <sys/types.h>
#include <stdint.h>
#include <stdlib.h>

#import "VideoView.h"

#define IMGFMT_BGR32 0x52474220
#define IMGFMT_RGB32 0x42475220
#define IMGFMT_YUY2  0x32595559
#define IMGFMT_YV12  0x32315659
#define IMGFMT_IYUV  0x56555949
#define IMGFMT_RGB24 0x42475218
#define IMGFMT_BGR24 0x52474218

@implementation VideoView

- (void) awakeFromNib
{
	NSRect frameRect = [self frame]; 
	NSLog(@"ViewInit.awakeFromNib (%f x %f)", frameRect.size.width, frameRect.size.height);
	[self configureWidth:frameRect.size.width height:frameRect.size.height format:IMGFMT_RGB32];
}

- (int) configureWidth: (uint32_t) width height: (uint32_t) height format: (uint32_t) format
{
	
	//init screen
	NSArray *screen_array = [NSScreen screens];
	screen_handle = [screen_array objectAtIndex:0];
	screen_frame = [screen_handle frame];

	image_format = format;
	image_width  = width;
	image_height = height;
	switch (image_format) 
	{
		case IMGFMT_BGR32:
		case IMGFMT_RGB32:
			image_depth = 32;
			pixelFormat = k32ARGBPixelFormat;
			break;
		case IMGFMT_YUY2:
			image_depth = 16;
			pixelFormat = kYUVSPixelFormat;
			break;
	}
	
	
	image_bytes = (image_depth + 7) / 8;
	image_data = malloc(image_width*image_height*image_bytes);
	NSLog(@"image_bytes=%d, pixelFormat=%x [%x], image_depth=%d, %d x %d\n", image_bytes, pixelFormat, format, image_depth, image_width, image_height);

	isFullscreen = 0;
	winSizeMult = 1;
	monitor_aspect = 1;
	movie_aspect = 1;
	isRootwin = 0;
	vo_keepaspect = 0;

	[self config];
	
	return 0;
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

- (id) config
{
	GLint swapInterval = 1;
	
	CVReturn rerror = kCVReturnSuccess;
	
	//create OpenGL Context
	glContext = [[NSOpenGLContext alloc] initWithFormat:[NSOpenGLView defaultPixelFormat] shareContext:nil];	
	
	[self setOpenGLContext:glContext];
	[glContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	[glContext setView:self];
	[glContext makeCurrentContext];	
	

	
	rerror = CVOpenGLTextureCacheCreate(NULL, 0, [glContext CGLContextObj], [[NSOpenGLView defaultPixelFormat] CGLPixelFormatObj], 0, &textureCache);
	if(rerror != kCVReturnSuccess) {
		NSLog(@"Failed to create OpenGL texture Cache(%d)", rerror);
		return nil;
	}
	
	rerror = CVOpenGLTextureCacheCreateTextureFromImage(	NULL, textureCache, _pixelBuffer, 0, &texture);
	if(rerror != kCVReturnSuccess) {
		NSLog(@"Failed to create OpenGL texture(%d)", rerror);
		return nil;
	}
	
	return self;
}

/*
	Setup OpenGL
*/
- (void)prepareOpenGL
{
	glEnable(GL_BLEND); 
	glDisable(GL_DEPTH_TEST);
	glDepthMask(GL_FALSE);
	glDisable(GL_CULL_FACE);
	[self reshape];
}

/*
	reshape OpenGL viewport
*/ 
- (void)reshape
{
	uint32_t d_width = image_width;
	uint32_t d_height = image_height;
	float aspectX=1.0;
	float aspectY=1.0;
	int padding = 0;
	
	NSRect frame = [self frame];
	frame.origin.x = frame.origin.y = 0;
	
	glViewport(0, 0, frame.size.width, frame.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, frame.size.width, frame.size.height, 0, -1.0, 1.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	//set texture frame
	if(vo_keepaspect)
	{
		d_height = ((float)d_width/movie_aspect);
		
		aspectX = (float)((float)frame.size.width/(float)d_width);
		aspectY = (float)((float)(frame.size.height)/(float)d_height);
		
		if((d_height*aspectX)>(frame.size.height))
		{
			padding = (frame.size.width - d_width*aspectY)/2;
			textureFrame = NSMakeRect(padding, 0, d_width*aspectY+padding, d_height*aspectY);
		}
		else
		{
			padding = ((frame.size.height) - d_height*aspectX)/2;
			textureFrame = NSMakeRect(0, padding, d_width*aspectX, d_height*aspectX+padding);
		}
	}
	else
	{
		textureFrame = frame;
	}
}

/*
	Render frame
*/ 
- (void) render
{
	int curTime;
	static int lastTime;

	glClear(GL_COLOR_BUFFER_BIT);	
	
	glEnable(CVOpenGLTextureGetTarget(texture));
	glBindTexture(CVOpenGLTextureGetTarget(texture), CVOpenGLTextureGetName(texture));
	
	glColor3f(1,1,1);
	glBegin(GL_QUADS);
	glTexCoord2f(upperLeft[0], upperLeft[1]); glVertex2i(	textureFrame.origin.x, textureFrame.origin.y);
	glTexCoord2f(lowerLeft[0], lowerLeft[1]); glVertex2i(	textureFrame.origin.x, textureFrame.size.height);
	glTexCoord2f(lowerRight[0], lowerRight[1]); glVertex2i(	textureFrame.size.width, textureFrame.size.height);
	glTexCoord2f(upperRight[0], upperRight[1]); glVertex2i(	textureFrame.size.width, textureFrame.origin.y);
	glEnd();
	glDisable(CVOpenGLTextureGetTarget(texture));
	
	//render resize box
	if(!isFullscreen)
	{
		NSRect frame = [self frame];
		
		glBegin(GL_LINES);
		glColor4f(0.2, 0.2, 0.2, 0.5);
		glVertex2i(frame.size.width-1, frame.size.height-1); glVertex2i(frame.size.width-1, frame.size.height-1);
		glVertex2i(frame.size.width-1, frame.size.height-5); glVertex2i(frame.size.width-5, frame.size.height-1);
		glVertex2i(frame.size.width-1, frame.size.height-9); glVertex2i(frame.size.width-9, frame.size.height-1);

		glColor4f(0.4, 0.4, 0.4, 0.5);
		glVertex2i(frame.size.width-1, frame.size.height-2); glVertex2i(frame.size.width-2, frame.size.height-1);
		glVertex2i(frame.size.width-1, frame.size.height-6); glVertex2i(frame.size.width-6, frame.size.height-1);
		glVertex2i(frame.size.width-1, frame.size.height-10); glVertex2i(frame.size.width-10, frame.size.height-1);
		
		glColor4f(0.6, 0.6, 0.6, 0.5);
		glVertex2i(frame.size.width-1, frame.size.height-3); glVertex2i(frame.size.width-3, frame.size.height-1);
		glVertex2i(frame.size.width-1, frame.size.height-7); glVertex2i(frame.size.width-7, frame.size.height-1);
		glVertex2i(frame.size.width-1, frame.size.height-11); glVertex2i(frame.size.width-11, frame.size.height-1);
		glEnd();
	}
	
	glFlush();
	
	//auto hide mouse cursor and futur on-screen control?
	if(isFullscreen && !mouseHide && !isRootwin)
	{
		int curTime = TickCount()/60;
		static int lastTime = 0;
		
		if( ((curTime - lastTime) >= 5) || (lastTime == 0) )
		{
			CGDisplayHideCursor(kCGDirectMainDisplay);
			mouseHide = YES;
			lastTime = curTime;
		}
	}
	
	//update activity every 30 seconds to prevent
	//screensaver from starting up.
	curTime  = TickCount()/60;
	lastTime = 0;
		
	if( ((curTime - lastTime) >= 30) || (lastTime == 0) )
	{
		UpdateSystemActivity(UsrActivity);
		lastTime = curTime;
	}
}

/*
	Create OpenGL texture from current frame & set texco 
*/ 
- (void) setCurrentTexture
{
	CVReturn rerror = kCVReturnSuccess;
	
	rerror = CVOpenGLTextureCacheCreateTextureFromImage (NULL, textureCache,  _pixelBuffer,  0, &texture);
	if (rerror != kCVReturnSuccess) {
		NSLog(@"Failed to create OpenGL texture(%d)", rerror);
		return;
	}

    CVOpenGLTextureGetCleanTexCoords(texture, lowerLeft, lowerRight, upperRight, upperLeft);
}

/*
	redraw win rect
*/ 
- (void) drawRect: (NSRect *) bounds
{
	[self render];
}


- (unsigned int) width { return image_width; }
- (unsigned int) height { return image_height; }
- (unsigned char*) imageBuffer { return image_data; }
- (unsigned int) format { return (image_format==IMGFMT_YUY2)?1:0; }

- (void) updateMono: (const char*) data
{
	[self updateMono:data offset:0 length:image_width*image_height];
}

- (void) updateMono: (const char*) data offset: (int) offset length: (int) len
{
	const char *d = data, *ed = d + len;
	char *c = (char*) image_data + (offset*4);
	while (d < ed) {
		char v = *d;
		*(c++) = 0; *(c++) = v; *(c++) = v; *(c++) = v;
		d++;
	}
	[self setCurrentTexture];
	[self render];
}

- (void) updateMonoWithData: (NSData*) data atOffset: (int) offset
{
	const char *d = (const char*) [data bytes];
	const char *ed = d + [data length];
	char *c = (char*) image_data + (offset*4);
	while (d < ed) {
		char v = *d;
		*(c++) = 0; *(c++) = v; *(c++) = v; *(c++) = v;
		d++;
	}
	[self setCurrentTexture];
	[self render];
}

- (void) updateMonoWithData: (NSData*) data
{
	[self updateMonoWithData:data atOffset:0];
}

@end
