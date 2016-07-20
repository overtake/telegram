//
//  TGBottomTextAttachment.h
//  Telegram
//
//  Created by keepcoder on 14/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGBottomTextAttachment : TMView


-(SSignal *)resignal:(TL_conversation *)conversation animateSignal:(SSignal *)animateSignal template:(TGInputMessageTemplate *)template;

@end
