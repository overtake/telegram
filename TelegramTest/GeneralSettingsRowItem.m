
//
//  GeneralSettingsRowItem.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "GeneralSettingsRowItem.h"

@interface GeneralSettingsRowItem ()
@property (nonatomic,assign) int rand;
@end

@implementation GeneralSettingsRowItem


-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(GeneralSettingsRowItem *item))callback description:(NSString *)description  height:(int)height stateback:(id (^)(GeneralSettingsRowItem *item))stateback {
    if(self = [super init]) {
        _type = type;
        _callback = callback;
        _desc = description;
        _height = height;
        _rand = arc4random();
        _stateback = stateback;
    }
    
    return self;
}

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(GeneralSettingsRowItem *item))callback description:(NSString *)description subdesc:(NSString *)subdesc height:(int)height stateback:(id (^)(GeneralSettingsRowItem *item))stateback {
    if(self = [self initWithType:type callback:callback description:description height:height stateback:stateback]) {
        _subdesc = subdesc;
    }
    
    return self;
}


-(NSUInteger)hash {
    return _rand;
}

@end
