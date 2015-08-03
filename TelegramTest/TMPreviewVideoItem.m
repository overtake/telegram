//
//  TMPreviewVideoItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewVideoItem.h"
#import "FileUtils.h"
#import "TLFileLocation+Extensions.h"
#import "ImageCache.h"

@implementation TMPreviewVideoItem

@synthesize url = _url;
@synthesize previewObject = _previewObject;
@synthesize previewImage = _previewImage;

-(id)initWithItem:(PreviewObject *)previewObject {
    if(self = [super init]) {
        
        _previewObject = previewObject;
        
        _url = [NSURL fileURLWithPath:mediaFilePath(((TL_messageMediaVideo *)[(TL_localMessage *)_previewObject.media media]))];
        
    }
    return self;
}

-(NSString *)previewItemTitle {
    return @"Video";
}


-(NSImage *)previewImage {
    
//    TLPhotoSize *thumb = ((TL_messageMediaVideo *)_previewObject.media).video.thumb;
//    
//    if([thumb isKindOfClass:[TL_photoCachedSize class]]) {
//        _previewImage = [[NSImage alloc] initWithData:thumb.bytes];
//    } else {
//        _previewImage = [[ImageCache sharedManager] imageFromMemory:thumb.location];
//    }
    
    return _previewImage;
}

-(BOOL)isEqualToItem:(id<TMPreviewItem>)item {
    return _previewObject.msg_id == item.previewObject.msg_id;
}

-(NSURL *)previewItemURL {
    return _url;
}

- (NSString *)fileName {
    NSString *filename = [self.url lastPathComponent];
    
    if(!filename)
        filename = @"file";
    return filename;
}

@end
