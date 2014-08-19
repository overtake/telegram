//
//  TMCircularProgress.h
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

typedef enum {
    TMCircularProgressDarkStyle,
    TMCircularProgressLightStyle
} TMCircularProgressStyle;

@interface TMCircularProgress : NSView
{
    float min;// default = 0;
    float max;// default = 100;
    BOOL reversed;// default = no;
    float duration;
    float fps;
}

@property (nonatomic) TMCircularProgressStyle style;

@property (nonatomic,strong) NSImage *cancelImage;

@property (nonatomic,copy) void (^cancelCallback)(void);

@property (nonatomic,strong) NSColor *progressColor;
@property (nonatomic,assign) float currentProgress;
@property (nonatomic,strong) NSColor *backgroundColor;

-(void)setProgress:(float)progress animated:(BOOL)animated;

@end
