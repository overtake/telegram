//
//  TGLinearProgressView.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//



@interface TGLinearProgressView : NSView
{
    float min;// default = 0;
    float max;// default = 100;
    @public float duration;
    float fps;
}


@property (nonatomic,strong) NSColor *progressColor;
@property (nonatomic,assign) float currentProgress;
@property (nonatomic,strong) NSColor *backgroundColor;

-(void)setProgress:(float)progress animated:(BOOL)animated;

@end;