//
//  TMBlueInputTextField.m
//  Messenger for Telegram
//
//  Created by keepcoder on 22.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBlueInputTextField.h"

@implementation TMBlueInputTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setEditable:YES];
    }
    return self;
}

-(void)setPlaceholder:(NSAttributedString *)placeholder {
    self->_placeholder = placeholder;
    [self setNeedsDisplay:YES];
}



@end
