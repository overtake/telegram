//
//  MessageTableitemMessagesHole.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableItemHole.h"

@interface MessageTableItemHole ()
@end

@implementation MessageTableItemHole

-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:object.hole.messagesCount != INT32_MAX ? [NSString stringWithFormat:@"+%d messages",object.hole.messagesCount] : @"new messages" withColor:TEXT_COLOR];
        
        _text = [attr copy];
        
        [self makeSizeByWidth:300];
        
    }
    
    return self;
}


-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    
    _textSize = [_text coreTextSizeForTextFieldForWidth:width];
    
    
    self.blockSize = NSMakeSize(width, _textSize.height);
    
    
    return YES;
    
}

@end
