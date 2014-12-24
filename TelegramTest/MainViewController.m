//
//  MainViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MainViewController.h"
#import "TGWindowArchiver.h"
@interface MainSplitView : NSSplitView
@end

@implementation MainSplitView

- (CGFloat)dividerThickness {
    return 0;
}

- (void)drawDividerInRect:(NSRect)rect {
    [super drawDividerInRect:rect];
}

- (NSColor *)dividerColor {
    return [NSColor redColor];
}

@end


@interface MainViewController ()
@property (nonatomic,strong) MainSplitView *splitView;
@end

@implementation MainViewController

- (void)loadView {
    
    
    
    self.splitView = [[MainSplitView alloc] initWithFrame:self.frameInit];
    [self.splitView setVertical:YES];
    [self.splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [self.splitView setDelegate:self];
    self.view = self.splitView;
    
    
    
    TGWindowArchiver *archiver = [TGWindowArchiver find:@"conversation"];
    
    if(!archiver) {
        archiver = [[TGWindowArchiver alloc] initWithName:@"conversation"];
        archiver.size = NSMakeSize(290, self.view.bounds.size.height);
        archiver.origin = NSMakePoint(0, 0);
    }
    
    
    
    //LeftController
    self.leftViewController = [[LeftViewController alloc] initWithFrame:NSMakeRect(archiver.origin.x, archiver.origin.y, archiver.size.width, archiver.size.height)];
    
    self.leftViewController.archiver = archiver;
    
    [self.leftViewController viewWillAppear:NO];
    [self.view addSubview:self.leftViewController.view];
    [self.leftViewController viewDidAppear:NO];
    
    self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    
    self.rightViewController = [[RightViewController alloc] initWithFrame:NSMakeRect(archiver.size.width, 0, self.view.bounds.size.width - archiver.size.width, self.view.bounds.size.height)];
    [self.rightViewController viewWillAppear:NO];
    [self.view addSubview:self.rightViewController.view];
    [self.rightViewController viewDidAppear:NO];
    
    [((NSSplitView *)self.view) adjustSubviews];
    
   // [self updateWindowMinSize];
}


-(void)minimisize {
    [self.splitView setPosition:70 ofDividerAtIndex:0];
}

-(BOOL)isMinimisze {
    return self.leftViewController.view.frame.size.width == 70;
}

-(void)unminimisize {
    [self.splitView setPosition:300 ofDividerAtIndex:0];
}

-(void)setConnectionState:(ConnectingStatusType)state {
   
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    if(subview == self.leftViewController.view)
        return NO;
    else
        return YES;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 300;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return  ![self.leftViewController canMinimisize] ? 300 : 70;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    if(proposedPosition < 80)
        return self.leftViewController.isChatOpened ? 70 : 270;
    if(proposedPosition < 270)
        return 270;
    
    return roundf(proposedPosition);
}

-(void)splitViewDidResizeSubviews:(NSNotification *)notification {
    LeftViewController *controller = [Telegram leftViewController];
    
    [controller updateSize];
    
    [self updateWindowMinSize];
    
}



-(void)splitViewWillResizeSubviews:(NSNotification *)notification {
    [self updateWindowMinSize];
    
}

-(void)updateWindowMinSize {
    MainWindow *window = (MainWindow *)self.view.window;
        
    [window setMinSize:NSMakeSize(460 + [Telegram leftViewController].view.frame.size.width, 600)];
    
    if(window.minSize.width > window.frame.size.width) {
        [window setFrame:NSMakeRect(NSMinX(self.view.window.frame), NSMinY(self.view.window.frame), window.minSize.width, NSHeight(window.frame)) display:YES];
    }
}

//- (void)showLoginViewController:(BOOL)isShow {
//
//    if(!self.loginViewController) {
//        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle bundleForClass:[self class]]];
//        [self.loginViewController.view setFrame:self.view.bounds];
//        [self.view addSubview:self.loginViewController.view];
//    } else {
//        [self.loginViewController.view removeFromSuperview];
//        self.loginViewController = nil;
//        [self showLoginViewController:isShow];
//        return;
//    }
//    
//    if(isShow) {
//        [self.leftViewController.view setHidden:YES];
////        [self.rightView setHidden:YES];
//        [self.loginViewController.view setHidden:NO];
//        [self.loginViewController initialize];
//    } else {
//        [self.leftViewController.view setHidden:NO];
////        [self.rightView setHidden:NO];
//        [self.loginViewController.view setHidden:YES];
//    }
//}


@end
