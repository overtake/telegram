//
//  TMAudioRecorder.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMAudioRecorder : NSObject


typedef void (^TMAudioRecorderPowerHandler)(float power);

double mappingRange(double x, double in_min, double in_max, double out_min, double out_max);


@property (nonatomic,weak) MessagesViewController *messagesViewController;

+ (TMAudioRecorder *)sharedInstance;
- (void)startRecordWithController:(MessagesViewController *)messagesViewController;
- (BOOL)stopRecord:(BOOL)send askConfirm:(BOOL)askConfirm;
- (void)stopRecord:(BOOL)send;
- (BOOL)isRecording;

-(NSTimeInterval)timeRecorded;

@property (nonatomic, copy) TMAudioRecorderPowerHandler powerHandler;

@end
