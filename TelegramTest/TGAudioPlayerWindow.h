//
//  TGAudioPlayerWindow.h
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageTableItemAudioDocument.h"
@interface TGAudioPlayerWindow : NSPanel

@property (nonatomic,strong,readonly) MessageTableItemAudioDocument *currentItem;

+(void)show:(TL_conversation *)conversation;

+(MessageTableItemAudioDocument *)currentItem;

+(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem;

@end
