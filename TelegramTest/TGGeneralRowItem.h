//
//  TGGeneralRowItem.h
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGGeneralRowItem : TMRowItem

typedef enum
{
    SettingsRowItemTypeSwitch,
    SettingsRowItemTypeChoice,
    SettingsRowItemTypeNext,
    SettingsRowItemTypeSelected,
    SettingsRowItemTypeNone
} SettingsRowItemType;



@property (nonatomic,strong) void (^callback)(TGGeneralRowItem *item);

@property (nonatomic,strong) id (^stateback)(TGGeneralRowItem *item);

@property (nonatomic,assign) SettingsRowItemType type;


@property (nonatomic,assign) int height;
@property (nonatomic,assign) int xOffset;
@property (nonatomic,assign) BOOL drawsSeparator;


-(id)initWithHeight:(int)height;

-(Class)viewClass;

-(BOOL)updateItemHeightWithWidth:(int)width;


@end
