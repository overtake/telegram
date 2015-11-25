//
//  TGAudioProgressView.h
//  Telegram
//
//  Created by keepcoder on 02.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGAudioProgressView : TMView


@property (nonatomic,assign) int currentProgress;

@property (nonatomic,assign) int downloadProgress;

@property (nonatomic,strong) void (^progressCallback)(float progress);

@property (nonatomic,assign) BOOL showDivider;

@property (nonatomic,assign) BOOL disableChanges;

@end
