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
   return @[[TL_documentAttributeAnimated create],[TL_documentAttributeFilename createWithFile_name:[[self.path lastPathComponent] stringByAppendingPathExtension:@"mp4"]],[TL_documentAttributeVideo createWithDuration:0 w:self.size.width h:self.size.height]];
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
