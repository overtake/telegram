//
//  TGInlineAudioPlayer.h
//  Telegram
//
//  Created by keepcoder on 26/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGAudioGlobalController.h"
@interface TGInlineAudioPlayer : TMView


@property (nonatomic,strong,readonly) TGAudioGlobalController *audioController;

-(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation;
-(void)setStyle:(TGAudioPlayerGlobalStyle)style animated:(BOOL)animated;
-(id)initWithFrame:(NSRect)frameRect globalController:(TGAudioGlobalController *)globalController;
@end
