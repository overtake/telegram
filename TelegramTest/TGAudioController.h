//
//  TGAudioController.h
//  Telegram
//
//  Created by keepcoder on 04/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableItemAudio.h"
#import "TGTimer.h"
@protocol TGAudioControllerDelegate <NSObject>

@required
-(void)audioControllerUpdateProgress:(int)progress;
-(void)audioControllerSetNeedDisplay;
@end

@interface TGAudioController : NSObject

@property (nonatomic,strong,readonly) TGTimer *progressTimer;
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
@property (nonatomic,assign,readonly) int progress;

@property (nonatomic,strong) NSString *path;

@property (nonatomic,weak) id<TGAudioControllerDelegate> delegate;

-(void)stop;

-(void)playOrPause;

-(AudioState)state;

@end
