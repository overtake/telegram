//
//  TGBottomAudioRecordView.m
//  Telegram
//
//  Created by keepcoder on 19/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomAudioRecordView.h"
#import "TMAudioRecorder.h"
#import "TGTextLabel.h"
#import "TGTimer.h"
#import "POPLayerExtras.h"
#import "TGSendTypingManager.h"


@interface TGBottomAudioRecordView ()
@property (nonatomic,weak) MessagesViewController *messagesController;
@property (nonatomic,strong) TGTextLabel *durationLabel;
@property (nonatomic,strong) TMCircleLayer *waveLayer;
@property (nonatomic,strong) TGTimer *timer;

@property (nonatomic,strong) TGTextLabel *descLabel;
@end

@implementation TGBottomAudioRecordView


-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        
        self.backgroundColor = [NSColor whiteColor];
        
        _durationLabel = [[TGTextLabel alloc] init];
        [self addSubview:_durationLabel];
        
        _descLabel = [[TGTextLabel alloc] init];
        [_descLabel setTruncateInTheMiddle:YES];
        [self addSubview:_descLabel];
        
        
        [_descLabel setCenterByView:self];
        
        _waveLayer = [TMCircleLayer layer];
        [_waveLayer setFillColor:RED_COLOR];
        [_waveLayer setRadius:20];
        [_waveLayer setFrameOrigin:NSMakePoint(20, roundf((NSHeight(frameRect) - 20.0)/2.0f))];
        [_waveLayer setNeedsDisplay];
        
        [self.layer addSublayer:_waveLayer];
        
        
        [_durationLabel setFrameOrigin:NSMakePoint(NSMaxX(_waveLayer.frame) + 10, 0)];

        
        _messagesController = messagesController;
        
    }
    
    return self;
}

-(NSAttributedString *)desc:(BOOL)inView {
    NSMutableAttributedString *attr;
    attr = [[NSMutableAttributedString alloc] init];
    [attr appendString:NSLocalizedString(@"Audio.ReleaseOut", nil) withColor:inView ? TEXT_COLOR : RED_COLOR];
    [attr setFont:TGSystemFont(14) forRange:attr.range];

    return attr;
}



-(void)stopRecord:(BOOL)send {
    [_timer invalidate];
    [[TMAudioRecorder sharedInstance] stopRecord:send];
}

-(void)updateDesc:(BOOL)inView {
    [_descLabel setText:[self desc:inView] maxWidth:NSWidth(self.frame) - NSMaxX(_durationLabel.frame) - 100];
    [_descLabel setFrameOrigin:NSMakePoint(roundf(((NSWidth(self.frame) + 60) - NSWidth(_descLabel.frame))/2.0f), NSMinY(_descLabel.frame))];
    [_descLabel setCenteredYByView:self];
}

-(void)startRecord {
    
    
    [_timer invalidate];
    
    
    _timer = [[TGTimer alloc] initWithTimeout:0.01 repeat:YES completion:^{
        
        
        [TGSendTypingManager addAction:[TL_sendMessageRecordAudioAction create] forConversation:_messagesController.conversation];
        
        NSTimeInterval time = [[TMAudioRecorder sharedInstance] timeRecorded];
        
        float ms = time - ((int)time);
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:[NSString stringWithFormat:@"%@,%d",[NSString durationTransformedValue:time],(int)(ms*100)] withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(14) forRange:attr.range];
        
        [_durationLabel setText:attr maxWidth:INT32_MAX];
        [_durationLabel setCenteredYByView:self];
        
        
    } queue:dispatch_get_main_queue()];
   
    [_timer start];

    
    [self updateDesc:YES];
    
    TMAudioRecorder *recorder = [TMAudioRecorder sharedInstance];
    [recorder setPowerHandler:^(float power) {
        power = mappingRange(power, 0, 1, 0.5, 1);
        POPLayerSetScaleXY(_waveLayer, CGPointMake(power, power));
    }];
    
    
    [recorder startRecordWithController:_messagesController];

    
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
}

@end
