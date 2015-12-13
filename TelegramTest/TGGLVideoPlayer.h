//
//  TGGLVideoPlayer.h
//  Telegram
//
//  Created by keepcoder on 12/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoLayer.h"
@interface TGGLVideoPlayer : NSOpenGLView

@property (nonatomic,strong) VideoLayer *videoLayer;
@property (nonatomic,strong) NSString *path;

@end
