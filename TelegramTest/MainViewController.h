//
//  MainViewController.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LeftViewController.h"
#import "RightViewController.h"
#import "SettingsWindowController.h"
@interface MainViewController : TMViewController
@property (nonatomic, strong) SettingsWindowController *settingsWindowController;
@property (nonatomic, strong) LeftViewController *leftViewController;
@property (nonatomic, strong) RightViewController *rightViewController;



-(void)updateWindowMinSize;
-(void)minimisize;
-(BOOL)isMinimisze;
-(void)unminimisize;


// layout methods

-(BOOL)isSingleLayout;

@end
