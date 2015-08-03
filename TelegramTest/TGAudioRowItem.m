//
//  TGAudioRowItem.m
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioRowItem.h"
#import "MessageTableItemAudioDocument.h"


@interface TGAudioPlayerImageObject : TGImageObject

@end

@implementation TGAudioPlayerImageObject

-(void)_didDownloadImage:(DownloadItem *)item {
    NSImage *image = [[NSImage alloc] initWithData:item.result];
        
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

@end

@interface TGAudioRowItem ()
@property (nonatomic,strong) MessageTableItemAudioDocument *documentItem;
@end

@implementation TGAudioRowItem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _documentItem = object;
        
         _imageObject = [[TGImageObject alloc] initWithLocation:_documentItem.message.media.document.thumb.location placeHolder:image_MusicStandartCover()];
        
        if(![_documentItem.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
            
            _imageObject.imageSize = strongsize(NSMakeSize(_documentItem.message.media.document.thumb.w, _documentItem.message.media.document.thumb.h), 36);
        } else {
            _imageObject.imageSize = image_MusicStandartCover().size;
        
        }
        
        
        
    }
    
    return self;
}

-(MessageTableItemAudioDocument *)document {
    return _documentItem;
}

-(NSString *)trackName {
    return _documentItem.fileName;
}

-(NSUInteger)hash {
    return _documentItem.message.randomId;
}

@end
