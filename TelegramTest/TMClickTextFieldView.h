//
//  TMClickTextFieldView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 31.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMClickTextFieldView : NSTextField
@property (nonatomic,copy) void (^callback)(void);
@end
