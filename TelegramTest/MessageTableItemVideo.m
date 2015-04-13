//
//  MessageTableItemVideo.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemVideo.h"
#import "ImageUtils.h"
#import "NSStringCategory.h"
@implementation MessageTableItemVideo

- (id) initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
       
        [self rebuildTimeString];
        
        
        [self rebuildImageObject];
        
        
        [self checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] ? AutoGroupVideo : AutoPrivateVideo size:self.message.media.video.size];
    }
    return self;
}


-(void)rebuildImageObject {
    
    TLVideo *video = self.message.media.video;
    TLPhotoSize *photoSize = video.thumb;
    NSImage *placeholder;
    if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
        placeholder = [[NSImage alloc] initWithData:photoSize.bytes];
    }
    
    self.videoPhotoLocation = photoSize.location;
    self.videoSize = photoSize.size;
    
    
    
    NSSize blockSize = NSMakeSize(photoSize.w , photoSize.h );
    
    self.imageObject = [[TGImageObject alloc] initWithLocation:[photoSize isKindOfClass:[TL_photoCachedSize class]] ? nil : photoSize.location placeHolder:placeholder sourceId:self.message.n_id];
    
    self.imageObject.imageSize = blockSize;
    
    
    self.previewSize = blockSize;
    
    [self makeSizeByWidth:310];
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = strongsize(NSMakeSize(self.message.media.video.thumb.w, self.message.media.video.thumb.h), width - 60);
    
    
    return YES;
}


- (Class)downloadClass {
    return [DownloadVideoItem class];
}

-(void)rebuildTimeString {
    
    NSString *sizeInfo = self.message.media.video.size == 0 ? NSLocalizedString(@"Message.Send.Compressing", nil) : [NSString sizeToTransformedValue:self.message.media.video.size];
    
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[[NSString durationTransformedValue:self.message.media.video.duration] stringByAppendingString:@", "] attributes:@{NSForegroundColorAttributeName: [NSColor whiteColor] }];
    
    
    [attr appendString:sizeInfo withColor:NSColorFromRGB(0xffffff)];
    
    self.videoTimeAttributedString = attr;
    
    
    NSSize size = [self.videoTimeAttributedString size];
    size.width = ceil(size.width + 14);
    size.height = ceil(size.height + 7);
    self.videoTimeSize = size;
}

- (NSString *)filePath {
    return mediaFilePath(self.message.media);
}

-(BOOL)isset {
    NSString *path = [self filePath];
    return isPathExists(path) && [FileUtils checkNormalizedSize:path checksize:self.message.media.video.size];
}

-(BOOL)needUploader {
    return YES;
}


-(void)doAfterDownload {
    [self rebuildImageObject];
}

-(BOOL)canDownload {
    return self.message.media.video.dc_id != 0;
}

@end
