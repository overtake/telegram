//
//  MessageTypingView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCell.h"

@interface MessageTypingView : MessageTableCell

- (void) setDialog:(TL_conversation *) dialog;

-(BOOL)isActive;


@end
