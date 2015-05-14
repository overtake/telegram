//
//  TGAttachObject.m
//  Telegram
//
//  Created by keepcoder on 20.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAttachObject.h"
#import "ASQueue.h"
#import "ImageAttachSenderItem.h"
@interface TGAttachObject ()
@property (nonatomic,strong) NSString *generatedPath;
@property (nonatomic,strong) NSString *file;
@property (nonatomic,strong) NSData *data;

@end

@implementation TGAttachObject


static ASQueue *queue;

-(NSString *)generatedPath {
    
    __block NSString *p;
    
    [queue dispatchOnQueue:^{
        
        if(isPathExists(_generatedPath)) {
            p = _generatedPath;
        }
        
    } synchronous:YES];
    
    
    return p;
}


+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[ASQueue alloc] initWithName:"generateAttachImage"];
    });
}


-(void)prepareImage:(NSString *)file orData:(NSData *)data {
    
    [queue dispatchOnQueue:^{
        
        NSImage *originImage;
        
        if(data) {
            originImage = [[NSImage alloc] initWithData:data];
        } else {
            originImage = imageFromFile(file);
        }
        
        if(originImage) {
            originImage = prettysize(originImage);
            
            
            originImage = strongResize(originImage, 1280);
            
            
            NSData *imageData = jpegNormalizedData(originImage);
            
            _generatedPath = exportPath(_unique_id, @"jpg");
            
            [imageData writeToFile:_generatedPath atomically:YES];
            
            
            
            
            _thumb = cropCenterWithSize(originImage, NSMakeSize(70, 70));
            
            [self generateImages:originImage];
            
            [TGCache cacheImage:_thumb forKey:[NSString stringWithFormat:@"_attach_thumb:%lu",_unique_id] groups:@[THUMBCACHE]];
            
            [ASQueue dispatchOnMainQueue:^{
                [_delegate didSuccessGeneratedThumb:_thumb];
                
                [_delegate didSuccessGenerateAttach];
            }];
            
            
            [self startUploader];
           
        } else {
            [ASQueue dispatchOnMainQueue:^{
                [_delegate didFailGenerateAttach];
            }];
            
        }
        
    }];
    
}

-(void)startUploader {
    
    if(!_uploader) {
        
         id uploadedFile = [[Storage manager] fileInfoByPathHash:fileMD5(_generatedPath)];
        
        if(!uploadedFile) {
            _uploader = [[UploadOperation alloc] init];
            
            [_uploader setFilePath:_generatedPath];
            [_uploader setFileName:@"photo.jpeg"];
            [_uploader ready:UploadImageType];
            
            weak();
            
            [_uploader setUploadComplete:^(UploadOperation *uploader, id input) {
                
                _uploader = nil;
                
                dispatch_after_seconds(0.3, ^{
                    [weakSelf.delegate didEndUploading:uploader];
                });
                
            }];
            
            [ASQueue dispatchOnMainQueue:^{
                [self.delegate didStartUploading:_uploader];
            }];
        }
        
    }
    
}


-(void)generateThumb {
    
    if(_thumb) {
        [ASQueue dispatchOnMainQueue:^{
            [_delegate didSuccessGeneratedThumb:_thumb];
        }];
        
        return;
    }
    
    [queue dispatchOnQueue:^{
        
        NSImage *image = imageFromFile(_generatedPath);
        
         _thumb = cropCenterWithSize(image, NSMakeSize(70, 70));
        
        [TGCache cacheImage:_thumb forKey:[self thumbKey] groups:@[THUMBCACHE]];
        
        [self generateImages:image];
        
        [ASQueue dispatchOnMainQueue:^{
            [_delegate didSuccessGeneratedThumb:_thumb];
        }];
        
        [self startUploader];
        
    }];
}


-(void)generateImages:(NSImage *)image {
    
    
    _imageSize = image.size;
    
    NSSize maxSize = strongsize(_imageSize, 250);
    
    
    if(_imageSize.width > MIN_IMG_SIZE.width && _imageSize.height > MIN_IMG_SIZE.height && maxSize.width == MIN_IMG_SIZE.width && maxSize.height == MIN_IMG_SIZE.height) {
        
        int difference = roundf( (_imageSize.width - maxSize.width) /2);
        
        _image = cropImage(image,maxSize, NSMakePoint(difference, 0));
        
    }
    
    _image = renderedImage(image, maxSize);
    
    
    _previewData = compressImage(jpegNormalizedData(renderedImage(image, strongsize(maxSize, 90))), 0.1);
}

-(void)prepare {
    if(_file || _data) {
        if(!isPathExists(_generatedPath))
            [self prepareImage:_file orData:_data];
        else  {
            [self generateThumb];
        }
    } else {
        [_delegate didFailGenerateAttach];
    }
    
    
}

-(id)initWithOriginFile:(NSString *)file orData:(NSData *)data peer_id:(int)peer_id {
    if(self = [super init]) {
        _file = file;
        _data = data;
        _unique_id = rand_long();
        _peer_id = peer_id;
        _caption = @"";
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_file forKey:@"file"];
    [aCoder encodeInt64:_unique_id forKey:@"unique_id"];
    [aCoder encodeInt:_peer_id forKey:@"peer_id"];
    [aCoder encodeObject:_caption forKey:@"caption"];
    [aCoder encodeObject:_data forKey:@"data"];
}

-(NSString *)thumbKey {
    return [NSString stringWithFormat:@"_attach_thumb:%lu",_unique_id];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _file = [aDecoder decodeObjectForKey:@"file"];
        _unique_id = [aDecoder decodeInt64ForKey:@"unique_id"];
        _generatedPath = exportPath(_unique_id, @"jpg");
        _peer_id = [aDecoder decodeIntForKey:@"peer_id"];
        _caption = [aDecoder decodeObjectForKey:@"caption"];
        _data = [aDecoder decodeObjectForKey:@"data"];
        _thumb = [TGCache cachedImage:[self thumbKey] group:@[THUMBCACHE]];
    }
    
    return self;
}

-(void)dealloc {
    [_uploader cancel];
    _uploader = nil;
}

-(BOOL)isEqualTo:(TGAttachObject *)object {
    return object.unique_id == _unique_id;
}

-(Class)senderClass {
    return [ImageAttachSenderItem class];
}

-(void)save {
    
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        
        NSString *key = [NSString stringWithFormat:@"peer_id:%d",_peer_id];
        
        NSMutableArray *attachments = [transaction objectForKey:key inCollection:ATTACHMENTS];
        
        [transaction setObject:attachments forKey:key inCollection:ATTACHMENTS];
        
    }];
    
}


-(void)changeCaption:(NSString *)caption needSave:(BOOL)needSave {
    _caption = caption;
    if(needSave)
        [self save];
}

@end
