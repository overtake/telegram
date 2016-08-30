#import "TGObserverProxy.h"

@interface TGObserverProxy ()

@property (nonatomic, weak) id target;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id object;
@property (nonatomic) SEL targetSelector;

@end

@implementation TGObserverProxy

- (instancetype)initWithTarget:(id)target targetSelector:(SEL)targetSelector name:(NSString *)name
{
    return [self initWithTarget:target targetSelector:targetSelector name:name object:nil];
}

- (instancetype)initWithTarget:(id)target targetSelector:(SEL)targetSelector name:(NSString *)name object:(id)object
{
    self = [super init];
    if (self != nil)
    {
        self.target = target;
        self.name = name;
        self.object = object;
        self.targetSelector = targetSelector;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:name object:object];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:_object];
}

- (void)notificationReceived:(NSNotification *)notification
{
    __strong id target = self.target;
    if (target != nil)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:_targetSelector withObject:notification];
#pragma clang diagnostic pop
    }
}

@end
