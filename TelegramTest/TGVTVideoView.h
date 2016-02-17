
#import "TGImageObject.h"
@interface TGVTVideoView : TMView

@property (nonatomic) CGSize videoSize;

- (void)setPath:(NSString *)path;


@property (nonatomic,strong) TGImageObject *imageObject;

@end
