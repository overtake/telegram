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
#import "NSData+Extensions.h"
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
@property (nonatomic,strong) NSMutableArray *powers;
@property (nonatomic, strong) NSString *opusEncoderPath;

@property (nonatomic,strong) ASQueue *audioQueue;

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
        self.audioQueue = [[ASQueue alloc] initWithName:"AudioRecorderQueue"];
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

- (void)startRecordWithController:(MessagesViewController *)messagesViewController {
    
    _messagesViewController = messagesViewController;
    
    if(self.recorder.isRecording) {
        [self.recorder stop];
        [self removeFile];
    }
    
    _powers = [NSMutableArray array];
    
    
    [self.timer invalidate];
    
    
    weak();
    
    self.timer = [[TGTimer alloc] initWithTimeout:1.f/50 repeat:YES completion:^{

        [weakSelf.recorder updateMeters];
        [weakSelf.recorder setMeteringEnabled:NO];
        [weakSelf.recorder setMeteringEnabled:YES];
        
        float power = 0;
        float average = [weakSelf.recorder averagePowerForChannel:0];
        
        if(average > -57) {
            power = mappingRange(average, -60, 0, 0, 1);
        }
        if(power > 1)
            power = 1;
        
        if(weakSelf.powerHandler)
            weakSelf.powerHandler(power);
        
        
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

-(NSTimeInterval)timeRecorded {
    return self.recorder.currentTime;
}

- (void)stopRecord:(BOOL)send {
    [self stopRecord:send askConfirm:NO];
}

- (BOOL)stopRecord:(BOOL)send askConfirm:(BOOL)askConfirm {
    [self.timer invalidate];

    if(!self.recorder.isRecording)
        return NO;
    
    int duration = self.recorder.currentTime;
    
    if(self.recorder.currentTime < 0.5)
        send = NO;
    
    [self.recorder stop];
    
    if(!send) {
        [self removeFile];
        return NO;
    }
    
    TL_conversation *conversation = self.messagesViewController.conversation;
    
    dispatch_block_t send_block = ^{
        NSString *opusPath = [self.filePath stringByAppendingString:@".opus"];
        
        char *c_op = strdup([opusPath UTF8String]);
        char *c_fp = strdup([self.filePath UTF8String]);
        
        char *argv[] = {"opusenc",c_fp,c_op,"--downmix-mono"};
        
        opusEncoder(3, argv);
        
        [self removeFile];
        
        TGAudioWaveform *waveform = [FileUtils waveformForPath:opusPath];
        

        [ASQueue dispatchOnMainQueue:^{
            
            if(askConfirm) {
                TL_documentAttributeAudio *audioAttr = [TL_documentAttributeAudio createWithFlags:0 duration:duration title:nil performer:nil waveform:[waveform bitstream]];
                //[self.messagesViewController.bottomView showQuickRecordedPreview:opusPath audioAttr:audioAttr];
            } else
                [self.messagesViewController sendAudio:opusPath forConversation:conversation waveforms:[waveform bitstream]];
        }];
    };
    
   
    [_audioQueue dispatchOnQueue:send_block];
    
    return YES;
}

static int powerCount = 100;

-(NSData *)prepareWafeForm {
    __block float average = 0;
    
    __block char bytes[63];
    
    NSMutableArray *nPowers = [NSMutableArray array];
    
    //make only 100 waves
    {
        if(_powers.count < powerCount) {
            
            float res = (float)_powers.count/(float)powerCount;
            
            int interval = ceil(1.0f/res);
            
            
            [_powers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [nPowers addObject:obj];
                
                if(idx % interval == 0) {
                    [nPowers addObject:obj];
                }
                
            }];

            
        } else if(_powers.count > powerCount) {
            
            int excess = ceil((float)_powers.count/(float)powerCount);
            
            [_powers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
                if((idx % excess) == 0) {
                    [nPowers addObject:obj];
                }
                
            }];
            
        }
        
    }
    
    if(nPowers.count < powerCount) {
        
        int count = (int)nPowers.count;
        
        for (int i = count; i < powerCount; i++) {
            [nPowers addObject:_powers[_powers.count - 1 - (i - count)]];
        }
        
        assert(nPowers.count == powerCount);
        
    } else {
        nPowers = [[nPowers subarrayWithRange:NSMakeRange(0, powerCount)] mutableCopy];
    }
    
    _powers = nPowers;
    
    int k = 0;
    
    
    for (int j = 0; j < powerCount; j++) {
       
        int val = [_powers[j] intValue];
        
       // NSLog(@"originalVal:%d",val);
        
        NSString *binaryString = @"";
        
        
        
        for (int i = 0; i < 5; i++) {
            
            BOOL value = val % 2;
            
            val = val >> 1;
            
          //  NSLog(@"val:%d res:%d",val,value);
            
            int index = k++;
            
            binaryString = [NSString stringWithFormat:@"%d%@",value,binaryString];
            
            int byteIndex = index / 8;
            int bitIndex = index % 8;
            char mask = (1 << bitIndex);
            
        //    NSLog(@"byteIndex:%d index:%d bitIndex:%d === %d",byteIndex,index,bitIndex,value);
            
            bytes[byteIndex] = (value ? (bytes[byteIndex] | mask) : (bytes[byteIndex] & ~mask));
            
            // SetBit(bytes,,res);
        }
        
        NSLog(@"%@",binaryString);
        
        
        average+=val;
    }
    

    average = average/(float)_powers.count;
    
    
    int count = _powers.count;
    
    NSLog(@"beform encoding:%@",_powers);
    
    
    NSData *data = [NSData dataWithBytes:bytes length:63];
    
    return data;
}

char* SetBit(char bytes[], int index, bool value)
{
    
    return bytes;
}

@end
