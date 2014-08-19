//
//  TMBackButton.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/8/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMButton.h"

@interface TMBackButton : TMButton
- (id)initWithFrame:(NSRect)frame string:(NSString *)string;

@property (nonatomic, strong) NSImageView *imageView;
- (void)setStringValue:(NSString *)stringValue;
@end
