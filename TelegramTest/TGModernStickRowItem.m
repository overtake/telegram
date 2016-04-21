//
//  TGModernStickRowItem.m
//  Telegram
//
//  Created by keepcoder on 21/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernStickRowItem.h"
#import "TGModernStickRowView.h"
@implementation TGModernStickRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:object withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        _header = attr;
        
    }
    
    return self;
}

-(int)height {
    return 34;
}

-(NSUInteger)hash {
    return [_header.string hash];
}

-(Class)viewClass {
    return [TGModernStickRowView class];
}

@end
