#import "TGActor.h"


@implementation TGActor

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        self.cancelToken = nil;
    }
    
    if (self.multipleCancelTokens != nil)
    {
        
        
        self.multipleCancelTokens = nil;
    }
    
    [super cancel];
}

@end
