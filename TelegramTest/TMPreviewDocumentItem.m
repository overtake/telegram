//
//  TMPreviewDocumentItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 12.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewDocumentItem.h"
#import "FileUtils.h"
#import "ImageCache.h"
@implementation TMPreviewDocumentItem

@synthesize url = _url;
@synthesize previewObject = _previewObject;
@synthesize previewImage = _previewImage;

-(id)initWithItem:(PreviewObject *)previewObject {
    if(self = [super init]) {
        _previewObject = previewObject;
        
        
        _url = [NSURL fileURLWithPath:mediaFilePath(((TL_messageMediaDocument *)[(TL_localMessage *)_previewObject.media media]))];
        
        
        if(!isPathExists(_url.path) || ![FileUtils checkNormalizedSize:_url.path checksize:((TL_messageMediaDocument *)[(TL_localMessage *)_previewObject.media media]).document.size]) {
            return nil;
        }
        
    }
    return self;
}

-(NSString *)previewItemTitle {
    return ((TL_messageMediaDocument *)[(TL_localMessage *)_previewObject.media media]).document.file_name;
}

- (TLDocument *)document {
    return ((TL_messageMediaDocument *)[(TL_localMessage *)_previewObject.media media]).document;
}

-(NSImage *)previewImage {
    if(!_previewImage) {
        TLPhotoSize *thumb = ((TL_messageMediaDocument *)[(TL_localMessage *)_previewObject.media media]).document.thumb;
        
        if([thumb isKindOfClass:[TL_photoCachedSize class]]) {
            _previewImage = [[NSImage alloc] initWithData:thumb.bytes];
        } else {
            _previewImage = [[ImageCache sharedManager] imageFromMemory:thumb.location];
        }
    }
    
    return _previewImage;
}

-(BOOL)isEqualToItem:(id<TMPreviewItem>)item {
    return _previewObject.msg_id == item.previewObject.msg_id;
}

-(NSURL *)previewItemURL {
    return _url;
}

- (NSString *)fileName {
    return [self previewItemTitle];
}

@end
