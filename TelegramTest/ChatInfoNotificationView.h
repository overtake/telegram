//
//  CHatInfoNotificationView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "ITSwitch.h"

@interface ChatInfoNotificationView : TMView
@property (nonatomic, strong) ITSwitch *switchControl;
@property (nonatomic) BOOL noBorder;
@end
