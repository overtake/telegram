//
//  TGSharedMediaCap.h
//  Telegram
//
//  Created by keepcoder on 03.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGSharedMediaCap : TMView

@property (nonatomic,assign, getter=isProgress) BOOL progress;


-(instancetype)initWithFrame:(NSRect)frameRect cap:(NSImage *)cap text:(NSString *)text;
-(void)updateCap:(NSImage *)cap text:(NSString *)text;


@end
