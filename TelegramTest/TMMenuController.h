//
//  TMMenuController.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "TMMenuPopover.h"

@interface TMMenuController : TMViewController

@property (nonatomic, weak) TMMenuPopover *popover;
@property (nonatomic, strong) NSMenu *menuController;
- (id)initWithMenu:(NSMenu *)menu;
- (void)close;

@end
