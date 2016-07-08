//
//  TGModernSearchSignals.h
//  Telegram
//
//  Created by keepcoder on 07/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGModernSearchSignals : NSObject

+(SSignal *)messagesSignal:(NSString *)search;
+(SSignal *)globalUsersSignal:(NSString *)search;
+(SSignal *)usersAndChatsSignal:(NSString *)search;
+(SSignal *)hashtagSignal:(NSString *)search;
@end
