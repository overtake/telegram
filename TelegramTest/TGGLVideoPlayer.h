//
//  TGGLVideoPlayer.h
//  Telegram
//
//  Created by keepcoder on 12/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGGLVideoPlayer : TMView

@property (nonatomic,strong) NSString *path;


-(void)pause;
-(void)resume;



@end
