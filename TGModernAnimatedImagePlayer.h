#import <Foundation/Foundation.h>

@interface TGModernAnimatedImagePlayer : NSObject

@property (nonatomic, copy) void (^frameReady)(NSImage *image);

- (instancetype)initWithSize:(CGSize)size path:(NSString *)path;

- (void)play;
- (void)stop;
- (void)pause;

@property (nonatomic,assign) BOOL isPlaying;

-(NSImage *)poster;

@end
