//
//  TMBackButton.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/8/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMButton.h"
#import "TMViewController.h"
@interface TMBackButton : TMButton

typedef enum {
    TMBackButtonClose,
    TMBackButtonBack
} TMBackButtonType;

@property (nonatomic,strong) TMViewController *controller;

- (id)initWithFrame:(NSRect)frame string:(NSString *)string;

@property (nonatomic, strong) NSImageView *imageView;
- (void)setStringValue:(NSString *)stringValue;

-(void)updateBackButton;

@end
