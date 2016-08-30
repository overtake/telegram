#import "TGInvocationLogger.h"

@interface TGInvocationLogger ()

@property (nonatomic, strong) NSObject *target;

@end

@implementation TGInvocationLogger

@synthesize target = _target;

- (id)initWithTarget:(NSObject *)target
{
    _target = target;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    MTLog(@"InvocationLogger: %@", NSStringFromSelector(selector));
    return [_target methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:_target];
}

@end
