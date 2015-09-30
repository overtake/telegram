#import "TGModernAnimatedImagePlayer.h"

#import "FLAnimatedImage.h"
#import "TGTimerTarget.h"


@interface TGModernAnimatedImagePlayer ()
{
    FLAnimatedImage *_image;
    NSTimer *_timer;
    NSInteger _currentFrame;
}

@end

@implementation TGModernAnimatedImagePlayer

- (instancetype)initWithSize:(CGSize)size path:(NSString *)path
{
    self = [super init];
    if (self != nil)
    {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSDataReadingMappedIfSafe error:nil];
        _image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data imageDrawingBlock:^NSImage *(NSImage *image)
        {
            return image;
        }];
    }
    return self;
}

- (void)dealloc
{
    [_timer invalidate];
}

- (void)play
{
    [_timer invalidate];
    _timer = nil;
    
    _isPlaying = YES;
    
    [self _pollNextFrame];
}

- (void)_pollNextFrame
{
    NSImage *image = [_image imageLazilyCachedAtIndex:_currentFrame];
    bool gotFrame = false;
    if (image != nil)
    {
        gotFrame = true;
        _currentFrame++;
        if (_currentFrame >= (NSInteger)_image.delayTimes.count)
            _currentFrame = 0;
        
        if (_frameReady)
            _frameReady(image);
    }
    
    if ((NSInteger)[_image delayTimes].count > _currentFrame)
    {
        _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_pollNextFrame) interval:gotFrame ? [_image.delayTimes[_currentFrame] doubleValue] : (1.0f / 80.0f) repeat:false runLoopModes:NSDefaultRunLoopMode];
    }
}

- (void)stop
{
    [_timer invalidate];
    _timer = nil;
    _currentFrame = 0;
    _isPlaying = NO;
}

- (void)pause
{
    [_timer invalidate];
    _timer = nil;
    
    _isPlaying = NO;
}

-(NSImage *)poster {
    return _image.posterImage;
}

@end
