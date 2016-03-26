
//
//  GeneralSettingsRowItem.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "GeneralSettingsRowItem.h"

@interface GeneralSettingsRowItem ()
@end

@implementation GeneralSettingsRowItem



-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(TGGeneralRowItem *item))callback description:(NSString *)description  height:(int)height stateback:(id (^)(TGGeneralRowItem *item))stateback {
    if(self = [super initWithHeight:height]) {
        self.type = type;
        self.callback = callback;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:description withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(14) forRange:attr.range];
        
        
        _desc = attr;
        
        _descSize = [attr coreTextSizeForTextFieldForWidth:INT32_MAX];
        
        self.stateback = stateback;
        _enabled = YES;
    }
    
    return self;
}

-(void)setDescString:(NSString *)desc  {
    NSMutableAttributedString *d = [_desc mutableCopy];
    
    [d replaceCharactersInRange:d.range withString:desc];
    
    _desc = d;
}

-(void)setSubdescString:(NSString *)subdesc {
    NSMutableAttributedString *d = [_subdesc mutableCopy];
    
    [d replaceCharactersInRange:d.range withString:subdesc];
    
    _subdesc = d;
}

-(void)setTextColor:(NSColor *)textColor {
    NSMutableAttributedString *d = [_desc mutableCopy];
    
    [d addAttribute:NSForegroundColorAttributeName value:textColor range:d.range];
    
    _desc = d;
}

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(TGGeneralRowItem *item))callback description:(NSString *)description subdesc:(NSString *)subdesc height:(int)height stateback:(id (^)(TGGeneralRowItem *item))stateback {
    if(self = [self initWithType:type callback:callback description:description height:height stateback:stateback]) {
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:subdesc withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(14) forRange:attr.range];
        
        _subdesc = attr;
        _subdescSize = [attr coreTextSizeForTextFieldForWidth:INT32_MAX];
    }
    
    return self;
}


-(Class)viewClass {
    return NSClassFromString(@"GeneralSettingsRowView");
}

@end
