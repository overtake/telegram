//
//  TGAudioGlobalController.h
//  Telegram
//
//  Created by keepcoder on 27/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableItemAudioDocument.h"
#import "TGAudioPlayerListView.h"
#import "TGAudioProgressView.h"
typedef enum {
    TGAudioPlayerGlobalStatePlaying = 0,
    TGAudioPlayerGlobalStatePaused = 1,
    TGAudioPlayerGlobalStateForcePaused = 2
} TGAudioPlayerGlobalState;

typedef enum {
    TGAudioPlayerGlobalStyleMini,
    TGAudioPlayerGlobalStyleList
} TGAudioPlayerGlobalStyle;

@protocol TGAudioPlayerGlobalDelegate <NSObject>

-(void)playerDidChangedState:(MessageTableItemAudioDocument *)item playerState:(TGAudioPlayerGlobalState)state;
-(void)playerDidChangeItem:(MessageTableItemAudioDocument *)item;
-(void)playerDidChangeTime:(NSTimeInterval)currentTime;

@optional
-(void)playerNeedDisableProgressChanges:(BOOL)disable;

@end

@interface TGAudioGlobalController : NSObject
@property (nonatomic,strong,readonly) TL_conversation *conversation;
@property (nonatomic,weak) TGAudioPlayerListView *playerList;
@property (nonatomic,weak) TGAudioProgressView *progressView;

@property (nonatomic,assign) BOOL autoStart;



@property (nonatomic,strong,readonly) MessageTableItemAudioDocument *currentItem;
@property (nonatomic,weak,readonly) TMNavigationController *navigationController;

-(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation;
-(void)show:(TL_conversation *)conversation playerState:(TGAudioPlayerGlobalState)state navigation:(TMNavigationController *)navigation;;
-(void)hide;
-(MessageTableItemAudioDocument *)currentItem;

-(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem;

-(TGAudioPlayerGlobalState)pState;


-(void)pause;
-(void)resume;
-(void)nextTrack;
-(void)prevTrack;
-(void)playOrPause;

-(void)addEventListener:(id<TGAudioPlayerGlobalDelegate>)delegate;
-(void)removeEventListener:(id<TGAudioPlayerGlobalDelegate>)delegate;


@end
