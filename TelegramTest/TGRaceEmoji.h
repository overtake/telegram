//
//  TGRaceEmoji.h
//  Telegram
//
//  Created by keepcoder on 17.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "TGModernEmojiViewController.h"
@interface TGRaceEmoji : TMViewController

@property (nonatomic,strong,readonly) NSString *emoji;

-(BOOL)makeWithEmoji:(NSString *)emoji;
@property (nonatomic,weak) TGModernEmojiViewController *controller;
@property (nonatomic,weak) BTRButton *ebutton;

-(id)initWithFrame:(NSRect)frame emoji:(NSString *)emoji;
@end
