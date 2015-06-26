//
//  TGAudioRowItem.h
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@class MessageTableItemAudioDocument;

@interface TGAudioRowItem : TMRowItem

@property (nonatomic,assign) BOOL isSelected;

-(NSString *)trackName;


@property (nonatomic,strong) TGImageObject *imageObject;

-(MessageTableItemAudioDocument *)document;

@end
