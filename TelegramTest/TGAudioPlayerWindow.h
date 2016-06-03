//
//  TGAudioPlayerWindow.h
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageTableItemAudioDocument.h"
#import "TGMessagesNavigationController.h"
#import "TGAudioGlobalController.h"


@interface TGAudioPlayerWindow : NSPanel




-(MessageTableItemAudioDocument *)currentItem;

@property (nonatomic,weak,readonly) TMNavigationController *navigationController;

+(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation;
+(void)show:(TL_conversation *)conversation playerState:(TGAudioPlayerGlobalStyle)state navigation:(TMNavigationController *)navigation;
+(void)showWithController:(TGAudioGlobalController *)controller;
+(void)hide;
+(MessageTableItemAudioDocument *)currentItem;

+(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem;

+(TGAudioPlayerGlobalState)playerState;

+(void)pause;
+(void)resume;
+(void)nextTrack;
+(void)prevTrack;

+(BOOL)isShown;

+(BOOL)autoStart;

+(void)addEventListener:(id<TGAudioPlayerGlobalDelegate>)delegate;
+(void)removeEventListener:(id<TGAudioPlayerGlobalDelegate>)delegate;

@end
