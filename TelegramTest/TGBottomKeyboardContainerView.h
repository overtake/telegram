//
//  TGBottomKeyboardContainerVIew.h
//  Telegram
//
//  Created by keepcoder on 16/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGBottomKeyboardContainerView : TMView

-(SSignal *)resignalKeyboard:(MessagesViewController *)messagesController forceShow:(BOOL)forceShow changeState:(BOOL)changeState;
@end
