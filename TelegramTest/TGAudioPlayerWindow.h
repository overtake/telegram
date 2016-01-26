//
//  TGAudioPlayerWindow.h
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageTableItemAudioDocument.h"

typedef enum {
    TGAudioPlayerStatePlaying = 0,
    TGAudioPlayerStatePaused = 1,
    TGAudioPlayerStateForcePaused = 2
} TGAudioPlayerState;

@protocol TGAudioPlayerWindowDelegate <NSObject>

-(void)playerDidChangedState:(MessageTableItemAudioDocument *)item playerState:(TGAudioPlayerState)state;

@end


@interface TGAudioPlayerWindow : NSPanel

typedef enum {
    TGAudioPlayerWindowStateMini,
    TGAudioPlayerWindowStatePlayList
} TGAudioPlayerWindowState;

@property (nonatomic,strong,readonly) MessageTableItemAudioDocument *currentItem;

+(void)show:(TL_conversation *)conversation;
+(void)show:(TL_conversation *)conversation playerState:(TGAudioPlayerWindowState)state;
+(void)hide;
+(MessageTableItemAudioDocument *)currentItem;

+(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem;

+(TGAudioPlayerState)playerState;

+(void)pause;
+(void)resume;

+(BOOL)autoStart;

+(void)addEventListener:(id<TGAudioPlayerWindowDelegate>)delegate;
+(void)removeEventListener:(id<TGAudioPlayerWindowDelegate>)delegate;

@end
