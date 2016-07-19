//
//  TGModernSendControlView.h
//  Telegram
//
//  Created by keepcoder on 12/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@protocol TGModernSendControlDelegate <NSObject>

-(void)_performSendAction;

-(void)_startAudioRecord;
-(void)_stopAudioRecord;
-(void)_sendAudioRecord;

@end

@interface TGModernSendControlView : BTRControl


typedef enum {
    TGModernSendControlSendType,
    TGModernSendControlEditType,
    TGModernSendControlRecordType
} TGModernSendControlType;


@property (nonatomic,weak) id<TGModernSendControlDelegate> delegate;

@property (nonatomic,assign) BOOL animates;
@property (nonatomic,assign) TGModernSendControlType type;

-(void)performSendAnimation;
-(void)setVoiceSelected:(BOOL)selected;

@end
