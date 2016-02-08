//
//  TGWaveformView.h
//  Telegram
//
//  Created by keepcoder on 07/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGWaveformView : TMView


@property (nonatomic,strong) NSArray *waveform;
@property (nonatomic,assign) int progress;

@property (nonatomic,strong) NSColor *defaultColor;
@property (nonatomic,strong) NSColor *progressColor;

@end
