//
//  StandartViewController.m
//  Telegram
//
//  Created by keepcoder on 27.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "StandartViewController.h"
#import "ComposeActionGroupBehavior.h"
#import "ComposeActionSecretChatBehavior.h"
#import "ComposeActionBroadcastBehavior.h"

@interface StandartViewController ()<TMSearchTextFieldDelegate>
@property (nonatomic, strong) BTRButton *topButton;
@property (nonatomic, strong) TMSearchTextField *searchTextField;
@property (nonatomic,strong) TMMenuPopover *menuPopover;
@end

@interface ExtendView : TMView
@property (nonatomic,strong) StandartViewController *controller;
@end

@implementation ExtendView


-(void)removeFromSuperview {
    [super removeFromSuperview];
    
    
}

-(void)setFrameSize:(NSSize)newSize {
    
    
    
    [super setFrameSize:newSize];
    
    [self.controller.searchTextField setFrameSize:NSMakeSize(self.frame.size.width-70, 31)];
        
    [self.controller.topButton setFrameOrigin:NSMakePoint(self.frame.size.width == 70 ? 15 : (self.controller.searchTextField.frame.origin.y + self.controller.searchTextField.frame.size.width+11), 9)];
    
    TMView *topView = self.subviews[0];
    
    
    
    [topView setFrame:NSMakeRect(0, self.bounds.size.height - 48, self.bounds.size.width , 48)];
  
    
     if(newSize.width == 70)
    {
        [self.controller.topButton setFrameOrigin:NSMakePoint(15, NSMinY(self.controller.topButton.frame))];
    } else if(NSWidth(self.controller.view.frame) == 200) {
        [self.controller.topButton setFrameOrigin:NSMakePoint(self.controller.searchTextField.frame.origin.y + self.controller.searchTextField.frame.size.width+11, NSMinY(self.controller.topButton.frame))];
    }

}

@end



@implementation StandartViewController

-(void)loadView {
    
    ExtendView *exView = [[ExtendView alloc] initWithFrame: self.frameInit];
    
    
    self.view = exView;
    
    [exView setController:self];
    
    int topOffset = 48;
    
    
    TMView *topView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height - topOffset, self.view.bounds.size.width , topOffset)];
    [topView setBackgroundColor:[NSColor whiteColor]];
    
    
    [topView setAutoresizesSubviews:YES];
    [topView setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable];
    
    dispatch_block_t block = ^{
        [DIALOG_BORDER_COLOR setFill];
        NSRectFill(NSMakeRect(NSWidth(topView.frame)-DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, NSHeight(topView.frame)));
    };
    
    [topView setDrawBlock:block];
    
    [self.view addSubview:topView];
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    
    self.searchTextField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, 8 , 205, 29)];
    
    
    
    
     self.searchTextField.delegate = self;
    [self.searchTextField setAutoresizingMask:NSViewWidthSizable];
    [topView addSubview:self.searchTextField];
    
    int buttonX = self.view.frame.size.width == 70 ? 15 : (self.searchTextField.frame.origin.y + self.searchTextField.frame.size.width+11);
    
    
    NSImage *compose = [NSImage imageNamed:@"ComposeNewMsg"];
    NSImage *composeActive = [NSImage imageNamed:@"ComposeNewMsgActive"];
    
    self.topButton = [[BTRButton alloc] initWithFrame:NSMakeRect(buttonX, 9, 38, 29)];
    
    [self.topButton setBackgroundImage:compose forControlState:BTRControlStateNormal];
    [self.topButton setBackgroundImage:composeActive forControlState:BTRControlStateSelected];
    [self.topButton setBackgroundImage:composeActive forControlState:BTRControlStateSelected | BTRControlStateHover];
    [self.topButton setBackgroundImage:composeActive forControlState:BTRControlStateHighlighted];
    [self.topButton setFrameSize:compose.size];
    
    
    [self.topButton setAutoresizingMask:NSViewMinXMargin];
    
    [topView addSubview:self.topButton];
    
    weakify();
    
    
    [self.topButton addBlock:^(BTRControlEvents events) {
        [strongSelf showComposeMenu];
        
    } forControlEvents:BTRControlEventClick];
    

    

    if(!self.menuPopover) {
        self.menuPopover = [[TMMenuPopover alloc] initWithMenu:[StandartViewController attachMenu]];
        [self.menuPopover setHoverView:self.topButton];
    }
    
    _searchViewController = [[SearchViewController alloc] initWithFrame:self.view.bounds];
    
    self.searchView = _searchViewController.view;
    
}

-(BOOL)becomeFirstResponder {
    return [self.searchTextField becomeFirstResponder];
}

-(void)showComposeMenu {
    
    [self.topButton setSelected:YES];
   
    if(!self.menuPopover.isShown) {
        NSRect rect = self.topButton.bounds;
        weakify();
        
        
        [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {
            [strongSelf.topButton setSelected:NO];
        }];
        [self.menuPopover showRelativeToRect:rect ofView:self.topButton preferredEdge:CGRectMinYEdge];
    }

}

+(NSMenu *)attachMenu {
    NSMenu *theMenu = [[NSMenu alloc] init];
    
    NSMenuItem *createGropup = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"ComposeMenu.CreateGroup", nil) withBlock:^(id sender) {
        
    
        ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionGroupBehavior class]];
        
        [[Telegram rightViewController] showComposeWithAction:action];
        
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        
    }];
    
    [createGropup setImage:[NSImage imageNamed:@"ComposeMenuNewGroup"]];
    [createGropup setHighlightedImage:[NSImage imageNamed:@"ComposeMenuNewGroupActive"]];
    [theMenu addItem:createGropup];
    
    
    
    
    NSMenuItem *broadcast = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"ComposeMenu.Broadcast", nil) withBlock:^(id sender) {
        ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBroadcastBehavior class]];
        
        if([[BroadcastManager sharedManager] all].count == 0) {
             [[Telegram rightViewController] showComposeWithAction:action];
        } else {
             [[Telegram rightViewController] showComposeBroadcastList:action];
        }
        
       [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        
    }];

    [broadcast setImage:[NSImage imageNamed:@"ComposeMenuNewBroadcast"]];
    [broadcast setHighlightedImage:[NSImage imageNamed:@"ComposeMenuNewBroadcastActive"]];
    [theMenu addItem:broadcast];
    
   
    
    NSMenuItem *secretChat = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"ComposeMenu.SecretChat", nil) withBlock:^(id sender) {
        
        ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionSecretChatBehavior class]];
        
        [[Telegram rightViewController] showComposeWithAction:action];
        
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        
    }];
    [secretChat setImage:[NSImage imageNamed:@"ComposeMenuNewSecret"]];
    [secretChat setHighlightedImage:[NSImage imageNamed:@"ComposeMenuNewSecretActive"]];
    
    
    
    [theMenu addItem:secretChat];
    
    return theMenu;
}

- (void) searchFieldBlur {}
- (void) searchFieldFocus {}


-(BOOL)isSearchActive {
    return self.searchView.superview != nil;
}

- (void) searchFieldTextChange:(NSString *)searchString {
    
    BOOL hidden = searchString.length > 0 ? YES : NO;
    
    [self hideSearch:!hidden];
    
    [self.searchViewController searchByString:searchString ? searchString : @""];
    
    
}

-(void)searchByString:(NSString *)searchString {
    
    [self.searchTextField setStringValue:searchString];
    
    if(searchString.length > 0) {
        [self.searchTextField becomeFirstResponder];
    } else {
        [self.searchTextField resignFirstResponder];
    }
}


-(void)hideSearch:(BOOL)hide {
   
    NSRect tableRect = NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.view.frame) - 48);
    
    
    [self.searchView setFrame:tableRect];
    [self.mainView setFrame:tableRect];
    
    if(hide) {
        [self.searchView removeFromSuperview];
        [self.view addSubview:self.mainView];
    } else {
        [self.mainView removeFromSuperview];
        [self.view addSubview:self.searchView];
    }
    
    
    if(hide) {
        [self.searchViewController viewDidDisappear:NO];
        [self viewDidAppear:NO];
    } else {
        [self.searchViewController viewDidAppear:NO];
        [self viewDidDisappear:NO];
    }

}

@end
