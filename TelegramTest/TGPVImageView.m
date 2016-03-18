//
//  TGPVImageView.m
//  Telegram
//
//  Created by keepcoder on 11.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVImageView.h"
#import "TMLoaderView.h"
#import "TGCache.h"
@interface TGPVImageView ()
@end

@implementation TGPVImageView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
       
     
    }
    
    return self;
}

-(void)setObject:(TGImageObject *)object {
    [super setObject:object];
}

-(NSImage *)cachedImage:(NSString *)key {
    return [TGCache cachedImage:key group:@[PVCACHE]];
}

-(NSImage *)cachedThumb:(NSString *)key {
    return self.object.placeholder;
}

-(void)didDownloadImage:(NSImage *)image object:(TGImageObject *)object {
    if([[object cacheKey] isEqualToString:[self.object cacheKey]]) {
        
        self.image = image;
    }
}




-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}


-(void)didUpdatedProgress:(float)progress {
    
}

@end
