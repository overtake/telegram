//
//  TGModernSearchItem.m
//  Telegram
//
//  Created by keepcoder on 07/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSearchItem.h"

@implementation TGModernSearchItem


-(id)initWithObject:(TL_conversation *)object selectText:(NSString *)selectText {
    if(self = [super initWithObject:object]) {
        _conversation = object;
        _selectText = selectText;
        
        if(selectText.length > 0) {
            
            _status = [[NSMutableAttributedString alloc] init];
            
            NSString *username = _conversation.type == DialogTypeChat || _conversation.type == DialogTypeChannel ? _conversation.chat.username : _conversation.user.username;
            
            [self.status appendString:[NSString stringWithFormat:@"@%@",username] withColor:GRAY_TEXT_COLOR];
            
            [self.status setSelectionColor:NSColorFromRGB(0xfffffe) forColor:GRAY_TEXT_COLOR];
            
            [NSMutableAttributedString selectText:[NSString stringWithFormat:@"@%@",selectText] fromAttributedString:(NSMutableAttributedString *)self.status selectionColor:BLUE_UI_COLOR];
        }
    }
    
    return self;
}

-(NSUInteger)hash {
    return _conversation.peer_id;
}

-(Class)viewClass {
    return NSClassFromString(@"TGModernSearchRowView");
}

-(int)height {
    return 66;
}

@end
