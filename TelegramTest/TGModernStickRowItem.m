//
//  TGModernStickRowItem.m
//  Telegram
//
//  Created by keepcoder on 21/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernStickRowItem.h"
#import "TGModernStickRowView.h"

@interface TGModernStickRowItem ()
@property (nonatomic,assign) long randKey;
@end

@implementation TGModernStickRowItem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:object withColor:DARK_GRAY_TEXT_COLOR];
        [attr setFont:TGSystemMediumFont(13) forRange:attr.range];
        
        _header = attr;
        
        _randKey = rand_long();
        
    }
    
    return self;
}

-(int)height {
    return 34;
}

-(NSUInteger)hash {
    return _randKey;
}

-(Class)viewClass {
    return [TGModernStickRowView class];
}

-(BOOL)updateItemHeightWithWidth:(int)width {
    return NO;
}

@end
