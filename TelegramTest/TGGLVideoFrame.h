//
//  TGGLVideoFrame.h
//  Telegram
//
//  Created by keepcoder on 13/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGGLVideoFrame : NSObject
@property (nonatomic, readonly) CVImageBufferRef buffer;
@property (nonatomic, readonly) NSTimeInterval timestamp;

- (instancetype)initWithBuffer:(CVImageBufferRef)buffer timestamp:(NSTimeInterval)timestamp;

@end
