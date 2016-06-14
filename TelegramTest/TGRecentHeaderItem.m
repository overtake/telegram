//
//  TGRecentHeaderItem.m
//  Telegram
//
//  Created by keepcoder on 27/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGRecentHeaderItem.h"
#import "TGRecentHeaderView.h"

@interface TGRecentHeaderItem ()
@property (nonatomic,assign) long randhash;
@end

@implementation TGRecentHeaderItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
        _randhash = rand_long();
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:object withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        _attrHeader = attr;
        
        NSMutableAttributedString *sm = [[NSMutableAttributedString alloc] init];
        
        [sm appendString:NSLocalizedString(@"Recent.More", nil) withColor:LINK_COLOR];
        [sm setFont:TGSystemFont(12) forRange:sm.range];
        
        _showMore = sm;
        
        NSMutableAttributedString *sl = [[NSMutableAttributedString alloc] init];
        
        [sl appendString:NSLocalizedString(@"Recent.Less", nil) withColor:LINK_COLOR];
        [sl setFont:TGSystemFont(12) forRange:sl.range];
        
        _showLess = sl;
    }
    
    return self;
}

-(int)height {
    return 20;
}

-(Class)viewClass {
    return [TGRecentHeaderView class];
}

-(NSUInteger)hash {
    return _randhash;
}


@end
