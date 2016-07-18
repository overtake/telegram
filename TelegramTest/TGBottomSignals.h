//
//  TGBottomSignals.h
//  Telegram
//
//  Created by keepcoder on 13/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSignalKit/SSignal.h>
#import "TGModernSendControlView.h"

@interface TGBottomSignals : NSObject


+(SSignal *)actions:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType;


+(SSignal *)emojiSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType;
+(SSignal *)scretTimerSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType;
+(SSignal *)silentModeSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType;
+(SSignal *)botCommandSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType;
+(SSignal *)botKeyboardSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType;

+(SSignal *)botKeyboardSignal:(TL_conversation *)conversation;


+(SSignal *)textAttachment:(TL_conversation *)conversation;

@end
