
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
        _desc = description;
        self.stateback = stateback;
        _enabled = YES;
    }
    
    return self;
}

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(TGGeneralRowItem *item))callback description:(NSString *)description subdesc:(NSString *)subdesc height:(int)height stateback:(id (^)(TGGeneralRowItem *item))stateback {
    if(self = [self initWithType:type callback:callback description:description height:height stateback:stateback]) {
        _subdesc = subdesc;
    }
    
    return self;
}


-(Class)viewClass {
    return NSClassFromString(@"GeneralSettingsRowView");
}

@end
