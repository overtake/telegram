#import "NSObject+TGLock.h"

#import <objc/runtime.h>

static const char *lockPropertyKey = "TLObjectLock::lock";

@interface TLObjectLockImpl : NSObject
{
    TG_SYNCHRONIZED_DEFINE(objectLock);
}

- (void)tgTakeLock;
- (void)tgFreeLock;

@end

@implementation TLObjectLockImpl

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        TG_SYNCHRONIZED_INIT(objectLock);
    }
    return self;
}

- (void)tgTakeLock
{
    TG_SYNCHRONIZED_BEGIN(objectLock);
}

- (void)tgFreeLock
{
    TG_SYNCHRONIZED_END(objectLock);
}

@end

@implementation NSObject (TGLock)

- (void)tgLockObject
{
    TLObjectLockImpl *lock = (TLObjectLockImpl *)objc_getAssociatedObject(self, lockPropertyKey);
    if (lock == nil)
    {
        @synchronized(self)
        {
            lock = [[TLObjectLockImpl alloc] init];
            objc_setAssociatedObject(self, lockPropertyKey, lock, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    [lock tgTakeLock];
}

- (void)tgUnlockObject
{
    TLObjectLockImpl *lock = (TLObjectLockImpl *)objc_getAssociatedObject(self, lockPropertyKey);
    if (lock == nil)
    {
        @synchronized(self)
        {
            lock = [[TLObjectLockImpl alloc] init];
            objc_setAssociatedObject(self, lockPropertyKey, lock, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    [lock tgFreeLock];
}

@end
