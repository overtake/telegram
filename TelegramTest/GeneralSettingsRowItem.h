//
//  GeneralSettingsRowItem.h
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TGGeneralRowItem.h"
@interface GeneralSettingsRowItem : TGGeneralRowItem





@property (nonatomic,strong) NSColor *textColor;

@property (nonatomic,strong) NSMenu *menu;

@property (nonatomic,assign, getter=isEnabled) BOOL enabled;

@property (nonatomic,strong,readonly,getter=description) NSString *desc;
@property (nonatomic,strong) NSString *subdesc;


@property (nonatomic,assign) BOOL locked;

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(TGGeneralRowItem *item))callback description:(NSString *)description height:(int)height stateback:(id (^)(TGGeneralRowItem *item))stateback;

-(id)initWithType:(SettingsRowItemType)type callback:(void (^)(TGGeneralRowItem *item))callback description:(NSString *)description subdesc:(NSString *)subdesc height:(int)height stateback:(id (^)(TGGeneralRowItem *item))stateback;


@end
