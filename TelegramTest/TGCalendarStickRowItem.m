//
//  TGCalendarStickRowItem.m
//  Telegram
//
//  Created by keepcoder on 30/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCalendarStickRowItem.h"

@interface TGCalendarStickRowItem ()
@property (nonatomic,assign) long randKey;
@end

@implementation TGCalendarStickRowItem

@synthesize header = _header;

-(id)initWithObject:(id)object {
    if(self = [super init]) {
        
        _randKey = rand_long();
        
        NSDateFormatter *stickFormatter = [[NSDateFormatter alloc] init];
        stickFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];;
        
        [stickFormatter setDateFormat:@"MMMM"];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        NSRange range = [attr appendString:[stickFormatter stringFromDate:object] withColor:TEXT_COLOR];
        [attr setFont:TGSystemMediumFont(13) forRange:range];
        
        [attr appendString:@" "];
        
        [stickFormatter setDateFormat:@"yyyy"];
        
        range = [attr appendString:[stickFormatter stringFromDate:object] withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:range];
        
        _header = [attr copy];
    }
    
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGCalendarStickRowView");
}

-(int)height {
    return [TGCalendarStickRowItem height];
}

-(NSUInteger)hash {
    return _randKey;
}

+(int)height {
    return 50;
}

@end
