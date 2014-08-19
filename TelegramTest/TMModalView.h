//
//  TMBlockedView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TMModalView : TMView

@property (nonatomic, strong) TMTextField *textField;

- (void)setHeaderTitle:(NSString *)titleString text:(NSString *)text;

@end
