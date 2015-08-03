//
//  MainViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MainViewController.h"
#import "TGWindowArchiver.h"
#import "NotSelectedDialogsViewController.h"
#import "TGSplitView.h"


#define MIN_SINGLE_LAYOUT_WIDTH 380
#define MAX_SINGLE_LAYOUT_WIDTH 600

#define MAX_LEFT_WIDTH 300

@interface MainViewController ()
-(void)checkLeftView;
@end

@interface MainViewController ()<TGSplitControllerDelegate> {
    NSSize oldLeftSize,oldRightSize,newLeftSize,newRightSize;
    BOOL _singleLayout;
}
@property (nonatomic,strong) TGSplitView *splitView;

@property (nonatomic,strong) TMView *leftViewContainer;

@end

@implementation MainViewController

- (void)loadView {
    
    [super loadView];
    
    self.splitView = [[TGSplitView alloc] initWithFrame:self.frameInit];
  //  [self.splitView setVertical:YES];
  //  [self.splitView setDividerStyle:NSSplitViewDividerStyleThin];
  //  [self.splitView setDelegate:self];
    
    [self.view.window setMinSize:NSMakeSize( MIN_SINGLE_LAYOUT_WIDTH, 400)];
    [self.splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:self.splitView];
    
    TGWindowArchiver *archiver = [TGWindowArchiver find:@"conversation"];
    
    if(!archiver) {
        archiver = [[TGWindowArchiver alloc] initWithName:@"conversation"];
        archiver.size = NSMakeSize(300, self.view.bounds.size.height);
        archiver.origin = NSMakePoint(0, 0);
    }
    
    if(archiver.size.width == 0)
    {
        archiver.size = NSMakeSize(300, self.view.bounds.size.height);
    }
    
    //LeftController
    self.leftViewController = [[LeftViewController alloc] initWithFrame:NSMakeRect(archiver.origin.x, archiver.origin.y,MIN(archiver.size.width,NSWidth(self.view.frame)), archiver.size.height)];
    
    self.leftViewController.archiver = archiver;

    
    
    
    self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    
    self.rightViewController = [[RightViewController alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width - NSWidth(self.leftViewController.view.frame), self.view.bounds.size.height)];

    
    self.rightViewController.mainViewController = self;
    self.rightViewController.leftViewController = self.leftViewController;
    
    [self.rightViewController loadView];
    
    [self.rightViewController.navigationViewController addDelegate:self.leftViewController];
    
    [_splitView setProportion:(struct TGSplitProportion){MIN_SINGLE_LAYOUT_WIDTH,300+MIN_SINGLE_LAYOUT_WIDTH} forState:TGSplitViewStateSingleLayout];
    [_splitView setProportion:(struct TGSplitProportion){300+MIN_SINGLE_LAYOUT_WIDTH,FLT_MAX} forState:TGSplitViewStateDualLayout];
    
        
    _splitView.delegate = self;
 
    [_splitView update];
    
   // [self layout];
    
   
    
}

-(void)splitViewDidNeedFullsize:(TGViewController<TGSplitViewDelegate> *)controller {
    if([self isMinimisze]) {
        self.splitView.canChangeState = YES;
        [self.splitView updateStartSize:NSMakeSize(300, NSHeight(controller.view.frame)) forController:controller];
        [self.leftViewController updateSize];
        [self.rightViewController.navigationViewController.currentController viewWillAppear:NO];
        [self updateWindowMinSize];
    }
}

-(void)splitViewDidNeedMinimisize:(TGViewController<TGSplitViewDelegate> *)controller {
    if(![self isMinimisze] && self.leftViewController.canMinimisize) {
        self.splitView.canChangeState = NO;
        [self.splitView updateStartSize:NSMakeSize(70, NSHeight(controller.view.frame)) forController:controller];
        [self.leftViewController updateSize];
        [self.rightViewController.navigationViewController.currentController viewWillAppear:NO];
        [self updateWindowMinSize];
    }
}

-(BOOL)splitViewIsMinimisize:(TGViewController *)controller {
    return [self isMinimisze];
}

-(void)splitViewDidNeedSwapToLayout:(TGSplitViewState)state {
    
    [_splitView removeAllControllers];
    
    [self.rightViewController didChangedLayout];
    
    int w = [self isMinimisze] ? 70 : 300;
    
    
    
    switch (state) {
        case TGSplitViewStateSingleLayout:
            
            
            [_splitView addController:_rightViewController proportion:(struct TGSplitProportion){MIN_SINGLE_LAYOUT_WIDTH,FLT_MAX}];
            break;
        case TGSplitViewStateDualLayout:
            [self.leftViewController.view setFrameSize:NSMakeSize(w, NSHeight(self.leftViewController.view.frame))];
            [_splitView addController:_leftViewController proportion:(struct TGSplitProportion){w,w}];
            [_splitView addController:_rightViewController proportion:(struct TGSplitProportion){MIN_SINGLE_LAYOUT_WIDTH,FLT_MAX}];
            break;
        default:
            break;
    }
    
    [_splitView update];
    
    
    [Notification perform:LAYOUT_CHANGED data:nil];

    
    
}

-(void)checkLeftView {
    
    if(![self isSingleLayout] && self.leftViewController.view.superview != self.leftViewContainer) {
        [self.leftViewController.view removeFromSuperview];
        
                
        [self.leftViewController.view setFrame:self.leftViewContainer.bounds];
        
        [self.leftViewContainer addSubview:self.leftViewController.view];
    }
    
}




-(BOOL)isConversationListShown {
    return NO;
}



-(void)minimisize {
   [self splitViewDidNeedMinimisize:self.leftViewController];
}

-(BOOL)isMinimisze {
    return self.leftViewController.view.frame.size.width == 70;
}

-(void)unminimisize {
    [self splitViewDidNeedFullsize:self.leftViewController];
}


-(BOOL)isSingleLayout {
    return self.splitView.state == TGSplitViewStateSingleLayout;
}


-(void)setConnectionState:(ConnectingStatusType)state {
   
}


-(void)updateWindowMinSize {
    MainWindow *window = (MainWindow *)self.view.window;
        
     [window setMinSize:NSMakeSize( [self isMinimisze] ? MIN_SINGLE_LAYOUT_WIDTH + 70 : MIN_SINGLE_LAYOUT_WIDTH, 400)];
    
   // [self layout];
    
  //  [self.rightViewController.view setFrameSize:NSMakeSize(MAX(NSWidth(self.rightViewController.view.frame), MIN_SINGLE_LAYOUT_WIDTH), NSHeight(self.rightViewController.view.frame))];
    
    
    if(window.minSize.width > window.frame.size.width) {
        [window setFrame:NSMakeRect(NSMinX(self.splitView.window.frame), NSMinY(self.splitView.window.frame), window.minSize.width, NSHeight(window.frame)) display:YES];
    }
    
    
}

@end
