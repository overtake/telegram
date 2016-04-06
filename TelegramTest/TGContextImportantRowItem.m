//
//  TGContextImportantItem.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGContextImportantRowItem.h"

@interface TGContextImportantRowItem ()


@property (nonatomic,assign) long h;
@end

@implementation TGContextImportantRowItem

-(id)initWithObject:(TL_inlineBotSwitchPM *)object bot:(TLUser *)bot {
    if(self = [super initWithObject:object]) {
        _botResult = object;
        _bot = bot;
        _h = rand_long();
        
        NSMutableAttributedString *header = [[NSMutableAttributedString alloc] init];
        
        [header appendString:priorityString(object.text,@"Switch PM",[NSNull class]) withColor:LINK_COLOR];
        
        [header setFont:TGSystemFont(13) forRange:header.range];
        
        _header = header;
        
    }
    
    return self;
}

-(BOOL)updateItemHeightWithWidth:(int)width {

    return NO;
}

-(Class)viewClass {
    return NSClassFromString(@"TGContextImportantRowView");
}

-(int)height {
    return 40;
}

-(NSUInteger)hash {
    return _h;
}

@end
