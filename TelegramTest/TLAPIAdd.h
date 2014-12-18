//
//  TLAPIAdd.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApiObject.h"


@interface TL_initConnection : TLObject
@property int api_id;
@property (nonatomic, strong) NSString *device_model;
@property (nonatomic, strong) NSString *system_version;
@property (nonatomic, strong) NSString *app_version;
@property (nonatomic, strong) NSString *lang_code;
@property (nonatomic, strong) id query;
@end




@interface TL_invokeAfter : TLObject
@property (nonatomic,assign) long msg_id;
@property (nonatomic,strong) NSData *query;
+(TL_invokeAfter*)createWithMsg_id:(long)msg_id query:(NSData*)query;
@end