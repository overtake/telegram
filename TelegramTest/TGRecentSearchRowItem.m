//
//  TGRecentTableItem.m
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGRecentSearchRowItem.h"
#import "TGRecentSearchRowView.h"
#import "NSNumber+NumberFormatter.h"
@interface TGRecentSearchRowItem ()
@property (nonatomic,assign) long randKey;
@end

@implementation TGRecentSearchRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _conversation = [object copy];
        _conversation.fake = YES;
        _randKey = rand_long();
        
        
        NSString *unreadText;
        NSSize unreadTextSize;
        
        if(_conversation.unread_count > 0) {
            NSString *unreadTextCount;
            
            if(_conversation.unread_count < 1000)
                unreadTextCount = [NSString stringWithFormat:@"%d", _conversation.unread_count];
            else
                unreadTextCount = [@(_conversation.unread_count) prettyNumber];
            
            NSDictionary *attributes =@{
                                        NSForegroundColorAttributeName: [NSColor whiteColor],
                                        NSFontAttributeName: TGSystemBoldFont(10)
                                        };
            unreadText = unreadTextCount;
            NSSize size = [unreadTextCount sizeWithAttributes:attributes];
            size.width = ceil(size.width);
            size.height = ceil(size.height);
            unreadTextSize = size;
            
            
            _unreadText = unreadText;
            
            _unreadTextSize = unreadTextSize;
            
        }
        
    }
    
    return self;
}



-(NSUInteger)hash {
    return _randKey;
}

-(Class)viewClass {
    return [TGRecentSearchRowView class];
}

-(int)height {
    return 50;
}

@end
