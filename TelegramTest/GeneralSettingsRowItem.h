//
//  GeneralSettingsRowItem.h
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface GeneralSettingsRowItem : TMRowItem

typedef enum
{
    SettingsRowItemTypeSwitch,
    SettingsRowItemTypeChoice,
    SettingsRowItemTypeNext
} SettingsRowItemType;


@property (nonatomic,assign,readonly) SettingsRowItemType type;
@property (nonatomic,strong,readonly) void (^callback)(GeneralSettingsRowItem *item);

@property (nonatomic,strong,readonly) id (^stateback)(GeneralSettingsRowItem *item);


@property (nonatomic,strong,readonly) NSString *description;
@property (nonatomic,strong,readonly) NSString *subdesc;
@property (nonatomic,assign,readonly) int height;

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(GeneralSettingsRowItem *item))callback description:(NSString *)description height:(int)height stateback:(id (^)(GeneralSettingsRowItem *item))stateback;

@end
