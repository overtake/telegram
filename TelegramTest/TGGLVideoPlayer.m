//
//  TGGLVideoPlayer.m
//  Telegram
//
//  Created by keepcoder on 12/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGLVideoPlayer.h"
#import "VideoLayer.h"
#import "TGTimer.h"

#import "TGGLVideoFrame.h"

@interface TGGLVideoFrameQueue : NSObject
{
    SQueue *_queue;
    
    NSUInteger _maxFrames;
    NSUInteger _fillFrames;
    NSTimeInterval _previousFrameTimestamp;
    
    TGGLVideoFrame *(^_requestFrame)();
    void (^_drawFrame)(TGGLVideoFrame *videoFrame, int32_t sessionId);
    
    NSMutableArray *_frames;
    
    TGTimer *_timer;
    
    int32_t _sessionId;
}

@end

@implementation TGGLVideoFrameQueue

- (instancetype)initWithRequestFrame:(TGGLVideoFrame *(^)())requestFrame drawFrame:(void (^)(TGGLVideoFrame *, int32_t sessionId))drawFrame {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        
        _maxFrames = 5;
        _fillFrames = 2;
        
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
    }
    
    if (_frames.count <= _fillFrames) {
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




@interface TGGLVideoPlayer ()
{
    
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_output;
    int32_t _sessionId;
    TGGLVideoFrameQueue *_frameQueue;
}

@end

@implementation TGGLVideoPlayer


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        self.layer = _videoLayer = [[VideoLayer alloc] init];
        _videoLayer.frame = self.bounds;
        
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
                [strongSelf displayPixelBuffer:videoFrame.buffer];
            }
        }];

    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_videoLayer setFrameSize:newSize];
}

-(void)setPath:(NSString *)path {
    
    [_frameQueue dispatch:^{
        _path = path;
        _sessionId++;
        
        [_reader cancelReading];
        _reader = nil;
        _output = nil;
        
        if (_path.length == 0) {
            [_frameQueue pauseRequests];
        } else {
            [_frameQueue beginRequests:_sessionId];
        }
        
        
    }];
    
}

-(void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer {
    
    _videoLayer.pixelBuffer = pixelBuffer;
    
    [ASQueue dispatchOnMainQueue:^{
        [_videoLayer setNeedsDisplay];
    }];
    
}


- (TGGLVideoFrame *)readNextFrame {
    for (int i = 0; i < 2; i++) {
        if (_reader == nil) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track != nil) {
                _output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_422YpCbCr8FullRange), (id)kCVPixelBufferOpenGLCompatibilityKey: @(true)}];
                _output.alwaysCopiesSampleData = false;
                
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
                
                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleVideo);
                
                TGGLVideoFrame *videoFrame = [[TGGLVideoFrame alloc] initWithBuffer:imageBuffer timestamp:presentationSeconds];
                CFRelease(sampleVideo);
                
                return videoFrame;
            } else {
                [_reader cancelReading];
                _reader = nil;
                _output = nil;
            }
        }
    }
    
    return nil;
}

@end
