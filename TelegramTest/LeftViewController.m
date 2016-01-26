//
//  LeftViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "LeftViewController.h"
#import "SearchViewController.h"
#import "RBLPopover.h"
#import "TMTabViewController.h"
#import "AccountSettingsViewController.h"
#import "ContactsViewController.h"


@interface LeftView : NSView
@property (assign) NSPoint initialLocation;

@property (nonatomic,strong) void (^willResize)(NSSize newSize);
@end

@implementation LeftView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(self.bounds.size.width - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, self.bounds.size.height));
}

-(void)removeFromSuperview {
    [super removeFromSuperview];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}


-(void)setFrameSize:(NSSize)newSize {
    
    
    
    if(self.willResize)
        self.willResize(newSize);
    
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

@interface LeftViewController ()<TMTabViewDelegate>

@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) AccountSettingsViewController *settingsViewController;
@property (nonatomic, strong) BTRButton *topButton;
@property (nonatomic, strong) TMSimpleTabViewController *tabViewController;
@property (nonatomic, strong) TMTabViewController *tabController;



@property (nonatomic, strong) ContactsViewController *contactsViewController;


@end

@implementation LeftViewController


static const int bottomOffset = 58;

- (void)loadView {
    [super loadView];
    
    LeftView *view = [[LeftView alloc] initWithFrame:self.view.bounds];
    
    self.view = view;
    
    
    self.tabController = [[TMTabViewController alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.bounds), bottomOffset)];
    
    [self.tabController setTopBorderColor:GRAY_BORDER_COLOR];
    
    [self.tabController setAutoresizesSubviews:YES];
    [self.tabController setAutoresizingMask:NSViewWidthSizable];
    
    self.tabController.delegate = self;
    
    TMTabItem *contactsTab = [[TMTabItem alloc] initWithTitle:NSLocalizedString(@"Tab.Contacts",nil) image:[NSImage imageNamed:@"TabIconContacts"] selectedImage:[NSImage imageNamed:@"TabIconContacts_Highlighted"]];
    
    TMTabItem *chatsTab = [[TMTabItem alloc] initWithTitle:NSLocalizedString(@"Tab.Chats",nil) image:[NSImage imageNamed:@"TabIconMessages"] selectedImage:[NSImage imageNamed:@"TabIconMessages_Highlighted"]];
    
    TMTabItem *settingsTab = [[TMTabItem alloc] initWithTitle:NSLocalizedString(@"Tab.Settings",nil) image:[NSImage imageNamed:@"TabIconSettings"] selectedImage:[NSImage imageNamed:@"TabIconSettings_Highlighted"]];
    
    
    contactsTab.textColor = chatsTab.textColor = settingsTab.textColor = NSColorFromRGB(0x888888);
    contactsTab.selectedTextColor = chatsTab.selectedTextColor = settingsTab.selectedTextColor = BLUE_COLOR_SELECT;
    
    [self.tabController addTab:contactsTab];
    [self.tabController addTab:chatsTab];
    [self.tabController addTab:settingsTab];
    
    
    [self.tabController setBackgroundColor:NSColorFromRGB(0xfafafa)];
    
    
    [self.view addSubview:self.tabController];
    
    
    
    self.isNavigationBarHidden = YES;
    
    
    [self.view.window setMovableByWindowBackground:YES];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable];
    
    
    NSRect controllerRect = NSMakeRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - bottomOffset);
    
    self.tabViewController = [[TMSimpleTabViewController alloc] initWithFrame:NSMakeRect(0, bottomOffset, self.view.bounds.size.width, self.view.bounds.size.height - bottomOffset)];
    [self.view addSubview:self.tabViewController.view];
    
    self.contactsViewController = [[ContactsViewController alloc] initWithFrame:controllerRect];
    [self.tabViewController addController:self.contactsViewController];
    
    
    _conversationsViewController = [[TGConversationsViewController alloc] initWithFrame:controllerRect];
    [self.tabViewController addController:_conversationsViewController];
    
    
    self.settingsViewController = [[AccountSettingsViewController alloc] initWithFrame:controllerRect];
    [self.tabViewController addController:self.settingsViewController];
    
    self.contactsViewController.view = self.contactsViewController.view;
    
    self.tabController.selectedIndex = 1;
    

    [self.view.window makeFirstResponder:nil];
    
    [self updateSize];
    
}

-(void)willChangedController:(TMViewController *)controller {
    if(controller == self)
    {
        [self updateForwardActionView];
    }
}


-(void)didChangedLayout:(NSNotification *)notification {
    
    
    [self updateForwardActionView];
}

-(TMViewController *)viewControllerAtTabIndex:(int)index {
    return [self.tabViewController contollerAtIndex:index];
}

-(TMViewController *)currentTabController {
    return [self.tabViewController currentController];
}

-(void)showTabControllerAtIndex:(int)index {
    self.tabController.selectedIndex = index;
}

-(void)showUserSettings {
    [self.tabController setSelectedIndex:2];
    
    if([[Telegram mainViewController] isMinimisze]) {
        
        [[Telegram mainViewController] unminimisize];
    }
}

-(void)updateForwardActionView {
    self.isNavigationBarHidden = ![[Telegram rightViewController] isModalViewActive];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.currentTabController.navigationViewController = self.navigationViewController;
    
    [self.currentTabController viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
     [self.currentTabController viewWillDisappear:animated];
}

-(void)setUnreadCount:(int)count {
    [self.tabController setUnreadCount:count];
}

static TMViewController *changedController;

-(void)tabItemDidChanged:(TMTabItem *)item index:(NSUInteger)index {
    
    if([Telegram mainViewController].isMinimisze && index != 1)
        return;
    
    [self.tabViewController showControllerByIndex:index];
    
    if(![Telegram isSingleLayout]) {
        if([self.tabViewController.currentController isKindOfClass:[AccountSettingsViewController class]]) {
            
            changedController = [Telegram rightViewController].navigationViewController.currentController;
            
            [[Telegram rightViewController] showGeneralSettings];
        } else if([[Telegram rightViewController].navigationViewController.viewControllerStack indexOfObject:changedController] != NSNotFound) {
            
            NSUInteger idx = [[Telegram rightViewController].navigationViewController.viewControllerStack indexOfObject:changedController];
            
            [[Telegram rightViewController].navigationViewController.viewControllerStack removeObjectsInRange:NSMakeRange(idx, [Telegram rightViewController].navigationViewController.viewControllerStack.count - idx)];
            
            [[Telegram rightViewController].navigationViewController pushViewController:changedController animated:changedController != [[Telegram rightViewController] currentEmptyController]];
            changedController = nil;
            
        }
    }
    
    
   
    
    [self setCenterBarViewText:item.title];
}


-(void)updateSize {
    
    BOOL min = NSWidth(self.view.frame) == 70;
    
    [self.tabController setHidden:min];
    
    [self.tabViewController.view setFrame:NSMakeRect(0,min ? 0 : bottomOffset,NSWidth(self.view.frame) , min ? NSHeight(self.view.frame) : (NSHeight(self.view.frame) - bottomOffset))];
    
    [self.tabController setFrameSize:NSMakeSize(NSWidth(self.view.frame), NSHeight(self.tabController.frame))];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationsViewController viewWillAppear:NO];
    });
    
//    
//    self.tabController.selectedIndex = self.tabController.selectedIndex;
}


-(BOOL)canMinimisize {
    return  !_conversationsViewController.isSearchActive && [self isChatOpened];
}

-(BOOL)isChatOpened {
    return self.tabController.selectedIndex == 1;
}

- (BOOL)isSearchActive {
    return self.tabViewController.currentController == self.searchViewController;
}

-(BOOL)becomeFirstResponder {
    return [[self currentTabController] becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    return [[self currentTabController] resignFirstResponder];
}

- (NSResponder *)firstResponder {
    return self.searchTextField;
}


- (void) dealloc {
    [Notification removeObserver:self];
}


- (void) searchFieldBlur {}
- (void) searchFieldFocus {}



@end

