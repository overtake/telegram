//
//  UserInfoPhoneView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface UserInfoParamsView : TMView

- (int)setString:(NSString *)string;
- (void)setHeader:(NSString *)header;
- (NSString *)string;


@end
