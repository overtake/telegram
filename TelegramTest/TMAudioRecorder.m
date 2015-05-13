//
//  TMAudioRecorder.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAudioRecorder.h"
#import "TGOpusAudioPlayerAU.h"
#import <AVFoundation/AVFoundation.h>
#import "TGTimer.h"
#import "HackUtils.h"
#include "opusenc.h"
typedef enum {
    TMAudioRecorderDefault,
    TMAudioRecorderRecord,
    TMAudioRecorderError
} TMAudioRecorderState;

@interface TMAudioRecorder()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) TMAudioRecorderState state;
@property (nonatomic, strong) TGTimer *timer;

@property (nonatomic, strong) NSString *opusEncoderPath;

@end

@implementation TMAudioRecorder

+ (TMAudioRecorder *)sharedInstance {
    static TMAudioRecorder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMAudioRecorder alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.opusEncoderPath = [[NSBundle mainBundle] pathForResource:@"opusenc_telegram" ofType:@""];
    }
    return self;
}

- (BOOL)isRecording {
    return self.recorder.isRecording;
}

- (void)removeFile {
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
}

double mappingRange(double x, double in_min, double in_max, double out_min, double out_max) {
    double slope = 1.0 * (out_max - out_min) / (in_max - in_min);
    return out_min + slope * (x - in_min);
}

- (void)startRecord {
    
    if(self.recorder.isRecording) {
        [self.recorder stop];
        [self removeFile];
    }
    
    
    [self.timer invalidate];
    self.timer = [[TGTimer alloc] initWithTimeout:1.f/10.f repeat:YES completion:^{

        [self.recorder updateMeters];
        [self.recorder setMeteringEnabled:NO];
        [self.recorder setMeteringEnabled:YES];

        float power = 0;
        float average = [self.recorder averagePowerForChannel:0];
        
        if(average > -57) {
            power = mappingRange(average, -60, 0, 0, 1);
        }
        if(power > 1)
            power = 1;
        
        if(self.powerHandler)
            self.powerHandler(power);
        
    } queue:dispatch_get_main_queue()];
    [self.timer start];
    
    self.filePath = [NSString stringWithFormat:@"%@%@.wav",NSTemporaryDirectory(),[NSDate date].description];
    
    NSDictionary *settings = @{AVSampleRateKey:@(48000.0),
                               AVFormatIDKey:@(kAudioFormatLinearPCM),
                               AVNumberOfChannelsKey:@1.0};
    
    
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.filePath] settings:settings error:&error];
    [self.recorder setMeteringEnabled:YES];
    
    if([self.recorder prepareToRecord]) {
        self.state = TMAudioRecorderRecord;
        [self.recorder record];
    }
}

- (void)stopRecord:(BOOL)send {
    [self.timer invalidate];

    if(!self.recorder.isRecording)
        return;
    
    if(self.recorder.currentTime < 0.5)
        send = NO;
    
    [self.recorder stop];
    
    if(!send) {
        [self removeFile];
        return;
    }
    
    [ASQueue dispatchOnStageQueue:^{
        
       	NSString *opusPath = [self.filePath stringByAppendingString:@".opus"];
        
        char *c_op = strdup([opusPath UTF8String]);
        char *c_fp = strdup([self.filePath UTF8String]);
        
        char *argv[] = {"opusenc",c_fp,c_op,"--downmix-mono"};

        opusEncoder(3, argv);
        
        [self removeFile];
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            [[Telegram rightViewController].messagesViewController sendAudio:opusPath forConversation:[Telegram rightViewController].messagesViewController.conversation];
        }];
    }];
}

@end
