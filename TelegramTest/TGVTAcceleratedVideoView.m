#import "TGVTAcceleratedVideoView.h"

#import <GLKit/GLKit.h>
#import <OpenGL/OpenGL.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
typedef enum {
    UniformIndex_Y = 0,
    UniformIndex_UV,
    UniformIndex_RotationAngle,
    UniformIndex_ColorConversionMatrix,
    UniformIndex_NumUniforms
} UniformIndex;

typedef enum {
    AttributeIndex_Vertex = 0,
    AttributeIndex_TextureCoordinates,
    AttributeIndex_NumAttributes
} AttributeIndex;

// BT.601, which is the standard for SDTV.
static GLfloat colorConversion601[] = {
    1.164f, 1.164f, 1.164f,
    0.0f, -0.392f, 2.017f,
    1.596f, -0.813f, 0.0f
};

// BT.709, which is the standard for HDTV.
static GLfloat colorConversion709[] = {
    1.164f, 1.164f, 1.164f,
    0.0f, -0.213f, 2.112f,
    1.793f, -0.533f, 0.0f
};

static NSData *fragmentShaderSource() {
    static NSData *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VTPlayer_Shader" ofType:@"fsh"]];
    });
    return value;
}

static NSData *vertexShaderSource() {
    static NSData *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VTPlayer_Shader" ofType:@"vsh"]];
    });
    return value;
}

@interface TGVTAcceleratedVideoFrame : NSObject

@property (nonatomic, readonly) CVImageBufferRef buffer;
@property (nonatomic, readonly) NSTimeInterval timestamp;

@end

@implementation TGVTAcceleratedVideoFrame

- (instancetype)initWithBuffer:(CVImageBufferRef)buffer timestamp:(NSTimeInterval)timestamp {
    self = [super init];
    if (self != nil) {
        if (buffer) {
            CFRetain(buffer);
        }
        _timestamp = timestamp;
        _buffer = buffer;
    }
    return self;
}

- (void)dealloc {
    if (_buffer) {
        CFRelease(_buffer);
    }
}

@end

@interface TGVTAcceleratedVideoFrameQueue : NSObject
{
    SQueue *_queue;
    
    NSUInteger _maxFrames;
    NSUInteger _fillFrames;
    NSTimeInterval _previousFrameTimestamp;
    
    TGVTAcceleratedVideoFrame *(^_requestFrame)();
    void (^_drawFrame)(TGVTAcceleratedVideoFrame *videoFrame, int32_t sessionId);
    
    NSMutableArray *_frames;
    
    STimer *_timer;
    
    int32_t _sessionId;
}

@end

@implementation TGVTAcceleratedVideoFrameQueue

- (instancetype)initWithRequestFrame:(TGVTAcceleratedVideoFrame *(^)())requestFrame drawFrame:(void (^)(TGVTAcceleratedVideoFrame *, int32_t sessionId))drawFrame {
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
        
        TGVTAcceleratedVideoFrame *firstFrame = _frames[0];
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
            TGVTAcceleratedVideoFrame *frame = nil;
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
    
    __weak TGVTAcceleratedVideoFrameQueue *weakSelf = self;
    _timer = [[STimer alloc] initWithTimeout:nextDelay repeat:false completion:^{
        __strong TGVTAcceleratedVideoFrameQueue *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf checkQueue];
        }
    } queue:_queue];
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

@implementation TGVTAcceleratedVideoContext

+ (TGVTAcceleratedVideoContext *)instance {
    static TGVTAcceleratedVideoContext *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[TGVTAcceleratedVideoContext alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        [_queue dispatch:^{
            _uniforms = malloc(sizeof(GLint) * UniformIndex_NumUniforms);
            
            
            _context = [[NSOpenGLContext alloc] initWithFormat:[NSOpenGLView defaultPixelFormat] shareContext:nil];
            
            [_context makeCurrentContext];

            
            
            glDisable(GL_DEPTH_TEST);
            
            glEnableVertexAttribArray(AttributeIndex_Vertex);
            glVertexAttribPointer(AttributeIndex_Vertex, 2, GL_FLOAT, false, 2 * sizeof(GLfloat), NULL);
            
            glEnableVertexAttribArray(AttributeIndex_TextureCoordinates);
            
            glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, false, 2 * sizeof(GLfloat), NULL);
            
            [self _loadShaders];
            
            glUseProgram(_program);
            
            // 0 and 1 are the texture IDs of lumaTexture and chromaTexture respectively.
            glUniform1i(_uniforms[UniformIndex_Y], 0);
            glUniform1i(_uniforms[UniformIndex_UV], 1);
            
            glUniform1f(_uniforms[UniformIndex_RotationAngle], 0.0f);
            
            glUniformMatrix3fv(_uniforms[UniformIndex_ColorConversionMatrix], 1, false, colorConversion709);
            
            
            CGLPixelFormatAttribute attributes[] =
            {
                kCGLPFADepthSize, 16,
                0
            };
            CGLPixelFormatObj pixelFormatObj = NULL;
            GLint numPixelFormats = 0;
            CGLChoosePixelFormat(attributes, &pixelFormatObj, &numPixelFormats);
            
            CVOpenGLTextureCacheCreate(kCFAllocatorDefault, 0, [_context CGLContextObj], [[_context pixelFormat] CGLPixelFormatObj], 0, &_videoTextureCache);
            
        }];
    }
    return self;
}

- (bool)_loadShaders {
    int vertShader;
    int fragShader;
    
    _program = glCreateProgram();
    
    // Create and compile the vertex shader.
    if (![self _compileShaderWithType:GL_VERTEX_SHADER outShader:&vertShader]) {
        MTLog(@"Failed to compile vertex shader");
        return false;
    }
    
    // Create and compile fragment shader.
    if (![self _compileShaderWithType:GL_FRAGMENT_SHADER outShader:&fragShader]) {
        MTLog(@"Failed to compile fragment shader");
        return false;
    }
    
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program, AttributeIndex_Vertex, "position");
    glBindAttribLocation(_program, AttributeIndex_TextureCoordinates, "texCoord");
    
    glLinkProgram(_program);
    
    
    int status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    bool ok = (status != 0);
    if (ok) {
        _uniforms[UniformIndex_Y] = glGetUniformLocation(_program, "SamplerY");
        _uniforms[UniformIndex_UV] = glGetUniformLocation(_program, "SamplerUV");
        _uniforms[UniformIndex_RotationAngle] = glGetUniformLocation(_program, "preferredRotation");
        _uniforms[UniformIndex_ColorConversionMatrix] = glGetUniformLocation(_program, "colorConversionMatrix");
    }
    if (vertShader != 0) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader != 0) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    if (!ok) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    return ok;
}

- (bool)_compileShaderWithType:(int)shaderType outShader:(int *)outShader {
    int shader = 0;
    
    NSData *source = (shaderType == GL_FRAGMENT_SHADER) ? fragmentShaderSource() : vertexShaderSource();
    if (source == nil) {
        return false;
    }
    
    shader = glCreateShader(shaderType);
    GLchar const *bytes = (GLchar const *)source.bytes;
    GLint length = (GLint)source.length;
    glShaderSource(shader, 1, &bytes, &length);
    glCompileShader(shader);
    
    GLsizei logLength = 0;
    glGetShaderInfoLog(shader, 0, &logLength, NULL);
    if (logLength != 0) {
        GLchar *log = malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSString *logString = [[NSString alloc] initWithBytes:log length:logLength encoding:NSUTF8StringEncoding];
        MTLog(@"Shader compile log: %@", logString);
        free(log);
    }
    
    if (outShader != NULL) {
        *outShader = shader;
    }
    
    return true;
}

- (void)dealloc {
    
}

@end

@interface TGVTAcceleratedVideoView () {
    CAOpenGLLayer *_layer;
    
    CVOpenGLTextureRef _lumaTexture;
    CVOpenGLTextureRef _chromaTexture;
    
    bool _buffersInitialized;
    int _backingWidth;
    int _backingHeight;
    uint _frameBufferHandle;
    uint _colorBufferHandle;
    
    GLfloat *_preferredConversion;
    
    int _program;
    
    NSString *_path;
    
    TGVTAcceleratedVideoFrameQueue *_frameQueue;
    
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_output;
    
    int32_t _sessionId;
}

@end

@implementation TGVTAcceleratedVideoView
+ (Class)layerClass {
    return [CAOpenGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        self.wantsLayer = YES;
        
    
        
        _layer = (CAOpenGLLayer *) self.layer;
        
        [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
            _preferredConversion = colorConversion709;
            [self setOpenGLContext:[TGVTAcceleratedVideoContext instance].context];
        }];
        
        __weak TGVTAcceleratedVideoView *weakSelf = self;
        _frameQueue = [[TGVTAcceleratedVideoFrameQueue alloc] initWithRequestFrame:^TGVTAcceleratedVideoFrame *{
            __strong TGVTAcceleratedVideoView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf readNextFrame];
            }
            return nil;
        } drawFrame:^(TGVTAcceleratedVideoFrame *videoFrame, int32_t sessionId) {
            [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
                __strong TGVTAcceleratedVideoView *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_sessionId == sessionId) {
                    [strongSelf displayPixelBuffer:videoFrame.buffer];
                }
            }];
        }];
    }
    return self;
}

- (void)dealloc {
    CVOpenGLTextureRef lumaTexture = _lumaTexture;
    CVOpenGLTextureRef chromaTexture = _chromaTexture;
    
    GLuint frameBufferHandle = _frameBufferHandle;
    GLuint colorBufferHandle = _colorBufferHandle;
    
    [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
        if (lumaTexture) {
            CFRelease(lumaTexture);
        }
        
        if (chromaTexture) {
            CFRelease(chromaTexture);
        }
        
        if (frameBufferHandle) {
            glDeleteFramebuffers(1, &frameBufferHandle);
        }
        
        if (colorBufferHandle) {
            glDeleteRenderbuffers(1, &colorBufferHandle);
        }
    }];
}

- (void)prepareForRecycle {
    [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
        if (_buffersInitialized) {
            if (_frameBufferHandle) {
                glDeleteFramebuffers(1, &_frameBufferHandle);
                _frameBufferHandle = 0;
            }
            
            if (_colorBufferHandle) {
                glDeleteRenderbuffers(1, &_colorBufferHandle);
                _colorBufferHandle = 0;
            }
            
            _buffersInitialized = false;
        }
    }];
}

- (void)setupBuffers {
    glGenFramebuffers(0, &_frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
//
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
//
//    
   glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, NSWidth(self.frame), NSHeight(self.frame));
//    
//   // [[TGVTAcceleratedVideoContext instance].context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
//    
    [self.openGLContext update];
//    
//    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    
    GLenum res = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    char buf[80];
    sprintf( buf, "0x%x", res );
    
    if (res != GL_FRAMEBUFFER_COMPLETE) {
        MTLog(@"Failed to make complete framebuffer object");
    }
    
    _buffersInitialized = true;
}

- (void)cleanupTextures {
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
}

- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer
{
    if (pixelBuffer != NULL) {
        CFRetain(pixelBuffer);
    }
    
    [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
        [[TGVTAcceleratedVideoContext instance].context makeCurrentContext];
        
        
        
        if (!_buffersInitialized) {
            [self setupBuffers];
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
        glViewport(0, 0, _backingWidth, _backingHeight);
        
        if (_backingWidth == 128 && _backingHeight == 128) {
            //int bp = 1;
        }
        
        if (pixelBuffer != NULL) {
            int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
            int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
            
            if ([TGVTAcceleratedVideoContext instance].videoTextureCache == NULL) {
                MTLog(@"No video texture cache");
                return;
            }
            
            [self cleanupTextures];
            
            CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
            if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
                _preferredConversion = colorConversion601;
            } else {
                _preferredConversion = colorConversion709;
            }
            
            glActiveTexture(GL_TEXTURE0);
            
            
           CVReturn res = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [TGVTAcceleratedVideoContext instance].videoTextureCache, pixelBuffer, 0, &_lumaTexture);
            if (_lumaTexture == NULL) {
                MTLog(@"Error at CVOpenGLESTextureCache.TextureFromImage");
            }
            
            glBindTexture(CVOpenGLTextureGetTarget(_lumaTexture), CVOpenGLTextureGetName(_lumaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glActiveTexture(GL_TEXTURE1);
            
            CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [TGVTAcceleratedVideoContext instance].videoTextureCache, pixelBuffer, NULL, &_chromaTexture);
            
            if (_chromaTexture == NULL) {
                MTLog(@"Error at CVOpenGLESTextureCache.TextureFromImage");
            }
            
            glBindTexture(CVOpenGLTextureGetTarget(_chromaTexture), CVOpenGLTextureGetName(_chromaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            CFRelease(pixelBuffer);
        }
        
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glUseProgram([TGVTAcceleratedVideoContext instance].program);
        glUniform1f([TGVTAcceleratedVideoContext instance].uniforms[UniformIndex_RotationAngle], 0.0f);
        glUniformMatrix3fv([TGVTAcceleratedVideoContext instance].uniforms[UniformIndex_ColorConversionMatrix], 1, false, _preferredConversion);
        
        // Set up the quad vertices with respect to the orientation and aspect ratio of the video.
        CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(self.layer.bounds.size, self.layer.bounds);
        
        // Compute normalized quad coordinates to draw the frame into.
        CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
        CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width / self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
        
        // Normalize the quad vertices.
        if (cropScaleAmount.width > cropScaleAmount.height) {
            normalizedSamplingSize.width = 1.0;
            normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
        }
        else {
            normalizedSamplingSize.width = 1.0;
            normalizedSamplingSize.height = cropScaleAmount.width/cropScaleAmount.height;
        }
        
        /*
         The quad vertex data defines the region of 2D plane onto which we draw our pixel buffers.
         Vertex data formed using (-1,-1) and (1,1) as the bottom left and top right coordinates respectively, covers the entire screen.
         */
        GLfloat quadVertexData [] = {
            (GLfloat)(-1 * normalizedSamplingSize.width), (GLfloat)(-1 * normalizedSamplingSize.height),
            (GLfloat)normalizedSamplingSize.width, (GLfloat)(-1 * normalizedSamplingSize.height),
            (GLfloat)(-1 * normalizedSamplingSize.width), (GLfloat)(normalizedSamplingSize.height),
            (GLfloat)(normalizedSamplingSize.width), (GLfloat)(normalizedSamplingSize.height),
        };
        
        // Update attribute values.
        glVertexAttribPointer(AttributeIndex_Vertex, 2, GL_FLOAT, 0, 0, quadVertexData);
        glEnableVertexAttribArray(AttributeIndex_Vertex);
        
        /*
         The texture vertices are set up such that we flip the texture vertically. This is so that our top left origin buffers match OpenGL's bottom left texture coordinate system.
         */
        CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
        GLfloat quadTextureData[] = {
            (GLfloat)CGRectGetMinX(textureSamplingRect), (GLfloat)CGRectGetMaxY(textureSamplingRect),
            (GLfloat)CGRectGetMaxX(textureSamplingRect), (GLfloat)CGRectGetMaxY(textureSamplingRect),
            (GLfloat)CGRectGetMinX(textureSamplingRect), (GLfloat)CGRectGetMinY(textureSamplingRect),
            (GLfloat)CGRectGetMaxX(textureSamplingRect), (GLfloat)CGRectGetMinY(textureSamplingRect)
        };
        
        glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, 0, 0, quadTextureData);
        glEnableVertexAttribArray(AttributeIndex_TextureCoordinates);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
        
        
        [[TGVTAcceleratedVideoContext instance].context flushBuffer];
        
    }];
}

- (void)setPath:(NSString *)path {
    [_frameQueue dispatch:^{
        NSString *realPath = path;
        if (path != nil && [path pathExtension].length == 0) {
            realPath = [path stringByAppendingString:@".mov"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:realPath]) {
                [[NSFileManager defaultManager] createSymbolicLinkAtPath:realPath withDestinationPath:path error:nil];
            }
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:realPath]) {
            realPath = nil;
        }
    
        if (![_path isEqualToString:realPath]) {
            _sessionId++;
            
            _path = realPath;
            [_reader cancelReading];
            _reader = nil;
            _output = nil;
            
            [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
               [[TGVTAcceleratedVideoContext instance].context makeCurrentContext];
                
                glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
                glViewport(0, 0, _backingWidth, _backingHeight);
                
                glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
                glClear(GL_COLOR_BUFFER_BIT);
                
                glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
              //  [[TGVTAcceleratedVideoContext instance].context presentRenderbuffer:GL_RENDERBUFFER];
            }];
            
            if (_path.length == 0) {
                [_frameQueue pauseRequests];
            } else {
                [_frameQueue beginRequests:_sessionId];
            }
        }
    }];
}

- (TGVTAcceleratedVideoFrame *)readNextFrame {
    for (int i = 0; i < 2; i++) {
        if (_reader == nil) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track != nil) {
                _output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange), (id)kCVPixelBufferOpenGLCompatibilityKey: @(true)}];
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
                
                TGVTAcceleratedVideoFrame *videoFrame = [[TGVTAcceleratedVideoFrame alloc] initWithBuffer:imageBuffer timestamp:presentationSeconds];
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

//-(void)layout {
//    [[TGVTAcceleratedVideoContext instance].queue dispatch:^{
//        if ((_backingWidth != (int)self.frame.size.width || _backingHeight != (int)self.frame.size.height)) {
//            [[TGVTAcceleratedVideoContext instance].context makeCurrentContext];
//            
//            if (_buffersInitialized) {
//                if (_frameBufferHandle) {
//                    glDeleteFramebuffers(1, &_frameBufferHandle);
//                    _frameBufferHandle = 0;
//                }
//                
//                if (_colorBufferHandle) {
//                    glDeleteRenderbuffers(1, &_colorBufferHandle);
//                    _colorBufferHandle = 0;
//                }
//                
//                _buffersInitialized = false;
//            }
//            
//            [self setupBuffers];
//        }
//    }];
//}


@end
