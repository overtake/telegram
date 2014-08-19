//
//  CAProgressLayer.h
//  Messenger for Telegram
//
//  Created by keepcoder on 19.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAProgressLayer : CAShapeLayer
-(void)showProgress:(float)progress;
-(void)computePath:(CGRect)r;
@end
