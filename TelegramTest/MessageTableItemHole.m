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
    if(self = [super init]) {
        self.message = object;
        [self updateWithHole:object.hole];
        
    }
    
    return self;
}

-(void)updateWithHole:(TGMessageHole *)hole {
    
    self.message.hole = hole;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    if([hole isKindOfClass:[TGMessageGroupHole class]]) {
        NSRange range = [attr appendString: (self.message.hole.messagesCount == 1 ? [NSString stringWithFormat:NSLocalizedString(@"Channel.oneComment", nil),self.message.hole.messagesCount] : [NSString stringWithFormat:NSLocalizedString(@"Channel.manyComments", nil),self.message.hole.messagesCount]) withColor:LINK_COLOR];
        
        [attr addAttribute:NSLinkAttributeName value:@"showComments" range:range];
        
    } else {
        NSRange range = [attr appendString:NSLocalizedString(@"Channel.GotoNewMessages", nil) withColor:LINK_COLOR];
        [attr addAttribute:NSLinkAttributeName value:@"showNewMessages" range:range];
    }
    
    _text = [attr copy];
    
    [self makeSizeByWidth:self.blockWidth];

}


-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    
    _textSize = [_text coreTextSizeForTextFieldForWidth:width];
    
    
    self.blockSize = NSMakeSize(width, _textSize.height);
    
    
    return YES;
    
}

@end
