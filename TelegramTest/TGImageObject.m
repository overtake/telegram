//
//  TGImageObject.m
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGImageObject.h"
#import "DownloadPhotoItem.h"
#import "ImageCache.h"
#import "TGImageView.h"
#import "ImageUtils.h"

@implementation TGImageObject

-(id)initWithLocation:(TGFileLocation *)location {
    if(self = [self initWithLocation:location placeHolder:nil sourceId:0 size:0]) {
        _location = location;
    }
    
    return self;
}

-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder {
    if(self = [self initWithLocation:location placeHolder:placeHolder sourceId:0 size:0]) {
        _location = location;
    }
    
    return self;
}


-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId {
    if(self = [self initWithLocation:location placeHolder:placeHolder sourceId:sourceId size:0]) {
        _location = location;
    }
    
    return self;
}

-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size {
    if(self = [super init]) {
        _location = location;
        _placeholder = placeHolder;
        _sourceId = sourceId;
        _size = size;
    }
    
    return self;
}


-(void)initDownloadItem {
    if(_downloadItem) {
        [_downloadItem cancel];
    }
    
    _downloadItem = [[DownloadPhotoItem alloc] initWithObject:_location size:_size];
    
    _downloadItem.reservedObject = self;
    
    _downloadListener = [[DownloadEventListener alloc] initWithItem:_downloadItem];

    [_downloadItem addEvent:_downloadListener];

    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        TGImageObject *object = item.reservedObject;
        
        object.isLoaded = YES;
        
        NSImage *image = [[NSImage alloc] initWithData:item.result];
        
        [object.delegate didDownloadImage:image object:object];
        
        item.object = nil;
        
    }];
    
    [_downloadItem start];
}




@end