
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



-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(GeneralSettingsRowItem *item))callback description:(NSString *)description  height:(int)height stateback:(id (^)(GeneralSettingsRowItem *item))stateback {
    if(self = [super init]) {
        _type = type;
        _callback = callback;
        _desc = description;
        self.height = height;
        _stateback = stateback;
        _enabled = YES;
    }
    
    return self;
}

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(GeneralSettingsRowItem *item))callback description:(NSString *)description subdesc:(NSString *)subdesc height:(int)height stateback:(id (^)(GeneralSettingsRowItem *item))stateback {
    if(self = [self initWithType:type callback:callback description:description height:height stateback:stateback]) {
        _subdesc = subdesc;
    }
    
    return self;
}


-(Class)viewClass {
    return NSClassFromString(@"GeneralSettingsRowView");
}

@end
