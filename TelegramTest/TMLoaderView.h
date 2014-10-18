//
//  TMLoaderView.h
//  Telegram
//
//  Created by keepcoder on 16.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCircularProgress.h"

@interface TMLoaderView : TMCircularProgress

typedef enum {
    TMLoaderViewStateDownloading = 16,
    TMLoaderViewStateUploading = 4,
    TMLoaderViewStateNeedDownload = 32
} TMLoaderViewState;


@property (nonatomic,assign) TMLoaderViewState state;


-(void)setImage:(NSImage *)image forState:(TMLoaderViewState)state;

-(void)addTarget:(id)target selector:(SEL)selector;


@end
