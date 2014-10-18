//
//  GLView.h
//  Telegram
//
//  Created by keepcoder on 16.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// for display link
#import <QuartzCore/QuartzCore.h>

@interface GLView : NSOpenGLView
{
    CVDisplayLinkRef displayLink;
    
    double    deltaTime;
    double    outputTime;
    float    viewWidth;
    float    viewHeight;
}

@end