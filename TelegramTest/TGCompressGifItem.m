//
//  TGCompressGifItem.m
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGCompressGifItem.h"
#import "TGGifConverter.h"
#import "TGTimer.h"
#import "SerializedData.h"
@interface TGCompressGifItem ()
{
    TGTimer *_timer;
    TLDocument *_document;
}
@end

@implementation TGCompressGifItem

@synthesize progress = _progress;

@synthesize outputPath = _outputPath;

-(id)initWithPath:(NSString *)path conversation:(TL_conversation *)conversation {
    if(self = [super initWithPath:path conversation:conversation]) {
        
        
        self.size = [TGGifConverter gifDimensionSize:path];
        
        if(self.size.width == 0 || self.size.height == 0)
            return nil;
       
    }
    
    return self;
}

-(void)start {
    
    if(self.state == TGCompressItemStateCompressingCancel)
        return;
    
    self.state = TGCompressItemStateCompressing;
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didStartCompressing:self];
    }];
    
    
    _timer = [[TGTimer alloc] initWithTimeout:0.2 repeat:YES completion:^{
        
        _progress+=10.0f;
        
        [self.delegate didProgressUpdate:self progress:_progress];
        
        if(_progress >= 50.0f) {
            [_timer invalidate];
            _timer = nil;
        }
        
    } queue:dispatch_get_main_queue()];
    
    [_timer start];
    [_timer fire];
    
    [TGGifConverter convertGifToMp4:[[NSData alloc] initWithContentsOfFile:self.path] completionHandler:^(NSString *path) {
        
        
        if(self.state == TGCompressItemStateCompressingCancel)
            return;
        
        
        long randomId = rand_long();
        
        NSString *nPath = exportPath(randomId, extensionForMimetype(self.mime_type));
        
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:nPath error:nil];
        
        path = nPath;
        
        _outputPath = path;
        
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform=TRUE;
        CMTime thumbTime = CMTimeMakeWithSeconds(0,1);
        
        NSSize thumbSize = strongsize([asset naturalSize], 90);
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            }
            
            NSImage *_thumbImage;
            
            if(im != NULL) {
                _thumbImage = [[NSImage alloc] initWithCGImage:im size:thumbSize];
            }
            
            
            TLPhotoSize *photoSize = _thumbImage != nil ? [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:randomId local_id:0 secret:0] w:_thumbImage.size.width h:_thumbImage.size.height bytes:jpegNormalizedData(_thumbImage)] : [TL_photoSizeEmpty createWithType:@"x"];
            
            
            NSArray *attributes = @[[TL_documentAttributeAnimated create],[TL_documentAttributeFilename createWithFile_name:[self.path lastPathComponent]],[TL_documentAttributeVideo createWithDuration:CMTimeGetSeconds([asset duration]) w:self.size.width h:self.size.height]];
            
            _document = [TL_document createWithN_id:randomId access_hash:0 date:[[MTNetwork instance] getTime] mime_type:[self mime_type] size:(int)fileSize(path) thumb:photoSize dc_id:0 attributes:[attributes mutableCopy]];
            
            
            self.state = TGCompressItemStateCompressingSuccess;
            
            [ASQueue dispatchOnMainQueue:^{
                
                _progress = 100.0;
                [_timer invalidate];
                _timer = nil;
                [self.delegate didProgressUpdate:self progress:_progress];
                
                dispatch_after_seconds(0.2, ^{
                    [self.delegate didEndCompressing:self success:YES];
                });
                
            }];
            
        };
        
        self.size = [asset naturalSize];
        
        
        generator.maximumSize = thumbSize;
        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
        
    } errorHandler:^{
        self.state = TGCompressItemStateCompressingFail;
        
        [ASQueue dispatchOnMainQueue:^{
            _progress = 100.0;
            [self.delegate didProgressUpdate:self progress:_progress];
            
            [self.delegate didEndCompressing:self success:NO];
        }];
    } cancelHandler:^BOOL{
        return self.state == TGCompressItemStateCompressingCancel;
    }];
    
}

-(NSArray *)attributes {
   return @[[TL_documentAttributeAnimated create],[TL_documentAttributeFilename createWithFile_name:[self.path lastPathComponent]],[TL_documentAttributeVideo createWithDuration:0 w:self.size.width h:self.size.height]];
}



-(NSString *)mime_type {
    return mimetypefromExtension(@"mp4");
}

-(void)cancel {
    
    self.state = TGCompressItemStateCompressingCancel;
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didCancelCompressing:self];
    }];
    
}

@end
