//
//  TLAPIAdd.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApiObject.h"
#import "TLObject.h"




@interface TL_invokeAfter : TLObject
@property (nonatomic,assign) long msg_id;
@property (nonatomic,strong) NSData *query;
+(TL_invokeAfter*)createWithMsg_id:(long)msg_id query:(NSData*)query;
@end