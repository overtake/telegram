//
//  LeftViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "LeftViewController.h"
#import "SearchViewController.h"
#import "NewConversationViewController.h"
#import "RBLPopover.h"
@interface LeftView : NSView
@property (assign) NSPoint initialLocation;
@end

@implementation LeftView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(self.bounds.size.width - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, self.bounds.size.height));
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
}

//- (void)mouseDragged:(NSEvent *)theEvent
//{
//    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
//    NSRect windowFrame = [self.window frame];
//    NSPoint newOrigin = windowFrame.origin;
//    
//    // Get the mouse location in window coordinates.
//    NSPoint currentLocation = [theEvent locationInWindow];
//    // Update the origin with the difference between the new mouse location and the old mouse location.
//    newOrigin.x += (currentLocation.x - self.initialLocation.x);
//    newOrigin.y += (currentLocation.y - self.initialLocation.y);
//    
//    // Don't let window get dragged up under the menu bar
//    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
//        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
//    }
//    
//    // Move the window to the new location
//    [self.window setFrameOrigin:newOrigin];
//}

//-(void)mouseDown:(NSEvent *)theEvent {
//     self.initialLocation = [theEvent locationInWindow];
//}

@end

@interface LeftViewController ()

@property (nonatomic, strong) DialogsViewController *dialogsViewController;
@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) BTRButton *topButton;
@property (nonatomic, strong) TMSimpleTabViewController *tabViewController;




@end

@implementation LeftViewController


- (void)loadView {
    [super loadView];
    
    weakify();
    
    self.view = [[LeftView alloc] initWithFrame:self.view.bounds];
    
    static const int topOffset = 50;
    
    
    [self.view.window setMovableByWindowBackground:YES];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable];
    
    self.tabViewController = [[TMSimpleTabViewController alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - topOffset)];
    [self.view addSubview:self.tabViewController.view];
    
    self.dialogsViewController = [[DialogsViewController alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - topOffset)];
    [self.tabViewController showController:self.dialogsViewController];
    
    self.searchViewController = [[SearchViewController alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - topOffset)];
    [self.tabViewController addController:self.searchViewController];

    
    TMView *topView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height - topOffset, self.view.bounds.size.width - DIALOG_BORDER_WIDTH, topOffset)];
    [topView setBackgroundColor:[NSColor whiteColor]];


    [topView setAutoresizesSubviews:YES];
    [topView setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable];
    [self.view addSubview:topView];
    
    
    self.searchTextField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, 9, 205, 32)];
    
    [self.searchTextField setFrameSize:NSMakeSize(self.view.bounds.size.width-70, 32)];
    
    
    self.searchTextField.delegate = self;
    [self.searchTextField setAutoresizingMask:NSViewWidthSizable];
    [topView addSubview:self.searchTextField];
    
    int buttonX = self.view.frame.size.width == 70 ? 15 : (self.searchTextField.frame.origin.y + self.searchTextField.frame.size.width+11);
    
    
    self.buttonContainer = [[NSView alloc] initWithFrame:NSMakeRect(buttonX, 9, 38, 30)];
    
    self.buttonContainer.wantsLayer = YES;
    
    self.buttonContainer.layer.cornerRadius = 4;
    self.buttonContainer.layer.backgroundColor = NSColorFromRGB(0xf4f4f4).CGColor;
    
    [self.buttonContainer setAutoresizingMask:NSViewMinXMargin];
    
    self.topButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [self.topButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
    [self.topButton setBackgroundImage:image_compose() forControlState:BTRControlStateNormal];
    [self.topButton setFrameSize:image_composeActive().size];
    

    [self.topButton setCenterByView:self.buttonContainer];
    
    [self.buttonContainer addSubview:self.topButton];
    
    
    [topView addSubview:self.buttonContainer];
    

    [self.topButton addBlock:^(BTRControlEvents events) {
        [strongSelf onWriteMessageButtonClick];
    } forControlEvents:BTRControlEventClick];
    
    
    
    [self.topButton addBlock:^(BTRControlEvents events) {
        
        strongSelf.buttonContainer.layer.backgroundColor = NSColorFromRGB(0x6E91BF).CGColor;
        
        [strongSelf.topButton setBackgroundImage:image_composeActive() forControlState:BTRControlStateNormal];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [self.topButton addBlock:^(BTRControlEvents events) {
        
        strongSelf.buttonContainer.layer.backgroundColor = NSColorFromRGB(0xf4f4f4).CGColor;
        
        [strongSelf.topButton setBackgroundImage:image_compose() forControlState:BTRControlStateNormal];
        
    } forControlEvents:BTRControlEventMouseUpInside];
    
    [self.topButton addBlock:^(BTRControlEvents events) {
        
        strongSelf.buttonContainer.layer.backgroundColor = NSColorFromRGB(0xf4f4f4).CGColor;
        [strongSelf.topButton setBackgroundImage:image_compose() forControlState:BTRControlStateNormal];
        
    } forControlEvents:BTRControlEventMouseUpOutside];

   
    

    [self.view.window makeFirstResponder:nil];
}




- (BOOL)isSearchActive {
    return self.tabViewController.currentController == self.searchViewController;
}

-(BOOL)becomeFirstResponder {
    return [self.searchTextField becomeFirstResponder];
}

- (NSResponder *)firstResponder {
    return self.searchTextField;
}

- (void) onWriteMessageButtonClick {
    [self showNewConversationPopover:NewConversationActionWrite];
}

- (IBAction)newMessage:(id)sender {
    [self showNewConversationPopover:NewConversationActionWrite];
}

- (IBAction)newGroup:(id)sender {
    [self showNewConversationPopover:NewConversationActionCreateGroup];
}

- (IBAction)newSecretChat:(id)sender {
    [self showNewConversationPopover:NewConversationActionCreateSecretChat];
}

- (void)showNewConversationPopover:(NewConversationAction)action {
    [self showNewConversationPopover:action toButton:self.topButton];
}

-(void)showNewConversationPopover:(NewConversationAction)action toButton:(id)button {
    [self showNewConversationPopover:action filter:nil target:nil selector:nil toButton:button title:NSLocalizedString(@"Group.AddMembers", nil)];
}

- (void)showNewConversationPopover:(NewConversationAction)action filter:(NSArray *)filter target:(id)target selector:(SEL)selector toButton:(id)button title:(NSString *)title {
    
    if(!self.popover.isShown) {
        
        NewConversationViewController *controller = [[NewConversationViewController alloc] initWithFrame:NSMakeRect(0, 0, 300, action == NewConversationActionChoosePeople ? 400 : 500)];
        [controller setCurrentAction:action];
        
        controller.filter = filter;
        controller.chooseSelector = selector;
        controller.chooseTarget = target;
        [controller setChooseButtonTitle:title];
        
        self.popover = [[TMPopover alloc] initWithViewController:controller];
        [self.popover showRelativeToView:button];

        
    } else {
        NewConversationViewController *controller = (NewConversationViewController *)self.popover.contentViewController;
        if([controller isKindOfClass:[NewConversationViewController class]]) {
            
            if(action == NewConversationActionWrite) {
                [controller actionGoBack];
            }
            if(action == NewConversationActionCreateSecretChat) {
                [controller actionCreateSecretChat];
            }
            
            if(action == NewConversationActionCreateGroup) {
                [controller actionCreateChat];
            }
        }
    }
    
    
}

- (void) dealloc {
    [Notification removeObserver:self];
}


- (void) searchFieldBlur {}
- (void) searchFieldFocus {}
- (void) searchFieldTextChange:(NSString *)searchString {
    
    BOOL hidden = searchString.length > 0 ? YES : NO;
    
    [self.tabViewController showController:hidden ? self.searchViewController : self.dialogsViewController];    
    [self.searchViewController searchByString:searchString ? searchString : @""];
}
@end
