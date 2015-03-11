//
//  TGReplayMessage.h
//  Telegram
//
//  Created by keepcoder on 05.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGReplayMessage : TMView


-(id)initWithFrame:(NSRect)frameRect message:(TL_localMessage *)message;

@end
