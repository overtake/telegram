//
//  TGGLVideoPlayer.m
//  Telegram
//
//  Created by keepcoder on 12/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGLVideoPlayer.h"
#import "TGTimer.h"

#import "TGGLVideoFrame.h"
#import <AVFoundation/AVFoundation.h>
#import "SpacemanBlocks.h"

@interface TGAVSampleBufferDisplayLayer : AVSampleBufferDisplayLayer
@property (nonatomic,assign) int sessionId;
@end


@implementation TGAVSampleBufferDisplayLayer



@end

@interface TGGLVideoFrameQueue : NSObject
{
    SQueue *_queue;
    
    NSUInteger _maxFrames;
    NSUInteger _fillFrames;
   @public NSTimeInterval _previousFrameTimestamp;
    
    TGGLVideoFrame *(^_requestFrame)();
    void (^_drawFrame)(TGGLVideoFrame *videoFrame, int32_t sessionId);
    @public NSMutableArray *_frames;
    
    @public TGTimer *_timer;
    
    int32_t _sessionId;
    BOOL _stopAndWaitDone;
}

@end

@implementation TGGLVideoFrameQueue

- (instancetype)initWithRequestFrame:(TGGLVideoFrame *(^)())requestFrame drawFrame:(void (^)(TGGLVideoFrame *, int32_t sessionId))drawFrame {
    self = [super init];
    if (self != nil) {
        
        static int k = 0;
        static NSMutableArray *queues;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            queues = [[NSMutableArray alloc] init];
            for (int i = 0; i < 4; i++) {
                [queues addObject:[[SQueue alloc] init]];
            }
        });
        
        _queue = queues[k];
        
        if(++k == 4)
            k = 0;
        
        
        _maxFrames = 3;
        _fillFrames = 1;
        
        _requestFrame = [requestFrame copy];
        _drawFrame = [drawFrame copy];
        
        _frames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dispatch:(void (^)())block {
    [_queue dispatch:block];
}

- (void)beginRequests:(int32_t)sessionId {
    [_queue dispatch:^{
        _sessionId = sessionId;
        [_timer invalidate];
        _timer = nil;
        
        [self checkQueue];
    }];
}

- (void)pauseRequests {
    [_queue dispatch:^{
        [_timer invalidate];
        _timer = nil;
        _previousFrameTimestamp = 0.0;
        [_frames removeAllObjects];
    }];
}

- (void)checkQueue {
    [_timer invalidate];
    _timer = nil;
    
    NSTimeInterval nextDelay = 0.0;
    bool initializedNextDelay = false;
    
    if (_frames.count != 0) {
        
        nextDelay = 1.0;
        initializedNextDelay = true;
        
        TGGLVideoFrame *firstFrame = _frames[0];
        [_frames removeObjectAtIndex:0];
        
        if (firstFrame.timestamp <= _previousFrameTimestamp) {
            nextDelay = 0.05;
        } else {
            nextDelay = MIN(5.0, firstFrame.timestamp - _previousFrameTimestamp);
        }
        
        _previousFrameTimestamp = firstFrame.timestamp;
        
        if (firstFrame.timestamp <= DBL_EPSILON) {
            nextDelay = 0.0;
        } else {
            
            if (_drawFrame) {
                _drawFrame(firstFrame, _sessionId);
            }
        }
    } else if(_stopAndWaitDone) {
        _stopAndWaitDone = NO;
    }
    
    if (_frames.count <= _fillFrames && !_stopAndWaitDone) {
        while (_frames.count < _maxFrames) {
            TGGLVideoFrame *frame = nil;
            if (_requestFrame) {
                frame = _requestFrame();
            }
            
            if (frame == nil) {
                if (!initializedNextDelay) {
                    nextDelay = 1.0;
                    initializedNextDelay = true;
                }
                _stopAndWaitDone = YES;
                break;
            } else {
                [_frames addObject:frame];
            }
        }
    }
    
    
    
    
    __weak TGGLVideoFrameQueue *weakSelf = self;
    _timer = [[TGTimer alloc]  initWithTimeout:nextDelay repeat:NO completion:^{
    
        __strong TGGLVideoFrameQueue *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf checkQueue];
        }
        
    } queue:_queue._dispatch_queue];
    
    if(nextDelay == 0.0)
        [_timer fire];
    else
        [_timer start];
    
}

@end

@interface TGVTAcceleratedVideoContext : NSObject {
}

@property (nonatomic, strong, readonly) SQueue *queue;
@property (nonatomic, readonly) NSOpenGLContext *context;
@property (nonatomic, readonly) CVOpenGLTextureCacheRef videoTextureCache;
@property (nonatomic, readonly) GLint *uniforms;
@property (nonatomic, readonly) GLint program;


@end




@interface TGGLVideoPlayer () <TGImageObjectDelegate>
{
    
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_output;
    int32_t _sessionId;
    TGGLVideoFrameQueue *_frameQueue;
    CMVideoFormatDescriptionRef _videoInfo;
    BOOL _paused;
    BOOL _pollingFirstFrame;
    SMDelayedBlockHandle _resumeHandle;
    SMDelayedBlockHandle _pauseHandle;
}

@property (nonatomic,strong) TGAVSampleBufferDisplayLayer *videoLayer;

@end

@implementation TGGLVideoPlayer


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        [self setWantsLayer:YES];
        [self clear];
        
        __weak TGGLVideoPlayer *weakSelf = self;
        _frameQueue = [[TGGLVideoFrameQueue alloc] initWithRequestFrame:^TGGLVideoFrame *{
            __strong TGGLVideoPlayer *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf readNextFrame];
            }
            return nil;
        } drawFrame:^(TGGLVideoFrame *videoFrame, int32_t sessionId) {
            __strong TGGLVideoPlayer *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_sessionId == sessionId) {
                [strongSelf displayPixelBuffer:videoFrame.buffer sessionId:sessionId flush:videoFrame.firstFrame];
                
            }
        }];

    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_videoLayer setBounds:self.bounds];
}


-(void)setImageObject:(TGImageObject *)imageObject {
    
     if(_imageObject.delegate == self)
        imageObject.delegate = nil;
    
    
    self->_imageObject = imageObject;
    
    NSImage *image = [self cachedImage:[_imageObject cacheKey]];
    if(image) {
        self.videoLayer.contents = image;
        return;
    }
    
    self.videoLayer.contents = [self cachedThumb:[_imageObject cacheKey]];
    
    _imageObject.delegate = self;
    
    [_imageObject initDownloadItem];
    
}

-(NSImage *)cachedImage:(NSString *)key {
    return [TGCache cachedImage:key group:@[IMGCACHE]];
}


-(NSImage *)cachedThumb:(NSString *)key {
    return _imageObject.placeholder;
}


-(void)didDownloadImage:(NSImage *)newImage object:(TGImageObject *)imageObject {
    if([[imageObject cacheKey] isEqualToString:[_imageObject cacheKey]]) {
        
        if(_paused)
            self.videoLayer.contents = newImage;
    }
}

-(void)clear {
    
    self.videoLayer = [[TGAVSampleBufferDisplayLayer alloc] init];
    self.videoLayer.bounds = self.bounds;
    self.videoLayer.sessionId = _sessionId;
    self.videoLayer.backgroundColor = NSColorFromRGB(0xb6b6b6).CGColor;
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self setLayer:self.videoLayer];
    
}

-(void)setPath:(NSString *)path {
     _paused = YES;
    _sessionId++;
  
    [self clear];
    
    [_frameQueue dispatch:^{
        _path = path;
        [_reader cancelReading];
        _reader = nil;
        _output = nil;
        
        if(_path == nil) {
            [_frameQueue pauseRequests];
        }
    }];
    
}



-(void)resume {
    
    _paused = NO;
    
    [_frameQueue dispatch:^{
        
        if(_frameQueue->_timer == nil) {
            [self cleanup];
            [_frameQueue beginRequests:_sessionId];
        }
        
    }];
    
   
    
}

-(void)pause {
    
    _paused = YES;
    
    [_frameQueue dispatch:^{
        
        
        [self cleanup];
        
        
        [_frameQueue pauseRequests];
        
        
    }];
    
    
}

-(void)viewDidMoveToWindow {
    if(self.window == nil) {
        [_videoLayer flush];
        [_frameQueue dispatch:^{
            [_frameQueue pauseRequests];
        }];
    }
}

-(void)displayPixelBuffer:(CMSampleBufferRef)sampleBuffer sessionId:(int)sessionId flush:(BOOL)flush {
    
    
     CFRetain(sampleBuffer);
    
    [ASQueue dispatchOnMainQueue:^{
        
        
        if(self.videoLayer.sessionId == sessionId) {
            if(flush) {
                [self.videoLayer flush];
            }
            
            if(sampleBuffer != NULL) {
                
                if (self.videoLayer.readyForMoreMediaData) {
                    
                    [self.videoLayer enqueueSampleBuffer:sampleBuffer];
                }
                
            }
        }
        
        
        CFRelease(sampleBuffer);
    }];
    
    
}


- (TGGLVideoFrame *)readNextFrame {
    for (int i = 0; i < 2; i++) {
        
        
        if (_reader == nil && _path.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:_path isDirectory:nil]) {
            
            _pollingFirstFrame = YES;
            
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track != nil) {
                _output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)}];
                _output.alwaysCopiesSampleData = true;
                
                _reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
                [_reader addOutput:_output];
                
                if (![_reader startReading]) {
                    MTLog(@"Failed to begin reading video frames");
                    _reader = nil;
                }
                

            }
            
        }
        
        if (_reader != nil) {
            
            CMSampleBufferRef sampleVideo = NULL;
            if (([_reader status] == AVAssetReaderStatusReading) && (sampleVideo = [_output copyNextSampleBuffer])) {
                CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleVideo);
                NSTimeInterval presentationSeconds = CMTimeGetSeconds(presentationTime);
                
                
                TGGLVideoFrame *videoFrame = [[TGGLVideoFrame alloc] initWithBuffer:sampleVideo timestamp:presentationSeconds];
                videoFrame.outTime = presentationTime;
                
                if(_pollingFirstFrame &&  presentationSeconds > DBL_EPSILON) {
                    videoFrame.firstFrame = YES;
                    _pollingFirstFrame = NO;
                }
                
                CFRelease(sampleVideo);
                
                return videoFrame;
            } else {
                
                
                [self cleanup];
                
                return nil;
                
                
                
            }
        }
    }
    
    return nil;
}

-(void)cleanup {
    //[_reader cancelReading];
    _reader = nil;
    _output = nil;
    
}

@end
