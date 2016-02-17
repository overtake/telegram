//
//  VideoLayer.h
//  MPlayerShell
//
//  Copyright (c) 2013 Don Melton
//

#import <Cocoa/Cocoa.h>

@interface VideoLayer : NSOpenGLLayer

@property (nonatomic) CVPixelBufferRef pixelBuffer;

@end
