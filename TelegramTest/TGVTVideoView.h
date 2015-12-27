
#import "TGImageObject.h"
@interface TGVTVideoView : TMView

@property (nonatomic) CGSize videoSize;

- (void)setPath:(NSString *)path;


-(void)resume;
-(void)pause;

@property (nonatomic,strong) TGImageObject *imageObject;

@end
