//
//  TGImageView.h
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BTRImageView.h"

#import "ImageObject.h"

@interface TGImageView : BTRImageView<NSImageDelegate,TGImageObjectDelegate>


@property (nonatomic,strong) ImageObject *object;


@property (nonatomic, strong) NSColor *borderColor;
@property (nonatomic) int blurRadius;
@property (nonatomic) int roundSize;
@property (nonatomic) float borderWidth;

@property (nonatomic, copy) dispatch_block_t tapBlock;


@property (nonatomic) BOOL isNotNeedHackMouseUp;

@property (nonatomic,copy) NSImage* (^cropInBackground)(NSImage *image);

-(NSImage *)cachedImage:(NSString *)key;
-(NSImage *)cachedThumb:(NSString *)key;


static CAAnimation *contentAnimation();

@end
