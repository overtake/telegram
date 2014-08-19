//
//  ProfileSharedMediaView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 09.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface ProfileSharedMediaView : TMView

@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,assign) BOOL needBorder;

@end
