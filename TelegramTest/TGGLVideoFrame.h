//
//  TGGLVideoFrame.h
//  Telegram
//
//  Created by keepcoder on 13/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGGLVideoFrame : NSObject
@property (nonatomic, readonly) CMSampleBufferRef buffer;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic) CMTime outTime;
@property (nonatomic) BOOL firstFrame;
@property (nonatomic) CMSampleBufferRef sampleVideo;

- (instancetype)initWithBuffer:(CMSampleBufferRef)buffer timestamp:(NSTimeInterval)timestamp;

@end
