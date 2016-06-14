//
//  TGRecentMoreItem.m
//  Telegram
//
//  Created by keepcoder on 27/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGRecentMoreItem.h"
#import "TGRecentMoreView.h"

@interface TGRecentMoreItem ()
@property (nonatomic,assign) long randhash;
@end

@implementation TGRecentMoreItem

-(id)initWithObject:(id)object {
    if(self = [super init]) {
        
        _randhash = rand_long();
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:NSLocalizedString(@"Recent.More", nil) withColor:LINK_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        _attrHeader = attr;
        
        
        _otherItems = object;
    }
    
    return self;

}

-(NSUInteger)hash {
    return _randhash;
}


-(int)height {
    return 40;
}

-(Class)viewClass {
    return [TGRecentMoreView class];
}

@end
