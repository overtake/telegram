//
//  TypingController.h
//  Telegram
//
//  Created by keepcoder on 06.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypingController : NSObject
@property (nonatomic,strong) NSView *viewToHidden;
-(id)initWithImageView:(NSImageView *)imageView;
-(void)startAnimation;
-(void)stopAnimation;
@end
