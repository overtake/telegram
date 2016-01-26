//
//  MegagroupChatFilter.m
//  Telegram
//
//  Created by keepcoder on 06/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MegagroupChatFilter.h"

@implementation MegagroupChatFilter

-(int)type {
    return HistoryFilterChannelMessage | HistoryFilterNone;
}

+(int)type {
    return HistoryFilterChannelMessage | HistoryFilterNone;
}

@end
