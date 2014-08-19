//
//  CALayerCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
@interface CALayer (Category)

- (void)disableActions;
//- (void)setNormalContentScale;
- (void)setFrameSize:(CGSize)size;
- (void)setFrameOrigin:(CGPoint)point;

@end
