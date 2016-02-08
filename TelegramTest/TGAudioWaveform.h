//
//  TGAudioWaveform.h
//  Telegram
//
//  Created by keepcoder on 08/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGAudioWaveform : NSObject

@property (nonatomic,strong) NSData *samples;
@property (nonatomic,assign) int32_t peak;

- (instancetype)initWithSamples:(NSData *)samples peak:(int32_t)peak;
- (instancetype)initWithBitstream:(NSData *)bitstream bitsPerSample:(NSUInteger)bitsPerSample;
- (NSData *)bitstream;
@end
