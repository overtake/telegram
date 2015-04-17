//
//  TGRaceEmoji.h
//  Telegram
//
//  Created by keepcoder on 17.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "EmojiViewController.h"
@interface TGRaceEmoji : TMViewController

@property (nonatomic,strong,readonly) NSString *emoji;

-(BOOL)makeWithEmoji:(NSString *)emoji;
@property (nonatomic,weak) EmojiViewController *controller;

-(id)initWithFrame:(NSRect)frame emoji:(NSString *)emoji;
@end
