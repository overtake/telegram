//
//  TMBackButton.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/8/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"
#import "TMTextButton.h"
#import "TMViewController.h"
@interface TMBackButton : TMView

typedef enum {
    TMBackButtonClose,
    TMBackButtonBack
} TMBackButtonType;

-(void)setTarget:(id)target selector:(SEL)selector;

@property (nonatomic,weak) TMViewController *controller;
@property (nonatomic,strong) TMTextField *field;
- (id)initWithFrame:(NSRect)frame string:(NSString *)string;

@property (nonatomic, strong) NSImageView *imageView;

-(void)updateBackButton;

@property (nonatomic,assign,getter=isDrawUnreadView) BOOL drawUnreadView;

@end
