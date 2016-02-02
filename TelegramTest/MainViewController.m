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


@interface TGDisclosureView : TMView

@end

@implementation TGDisclosureView

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.subviews[1] setFrame:NSMakeRect(0, 0, DIALOG_BORDER_WIDTH, NSHeight(frame))];
}

@end


@interface TGDisclosureViewController : TGSplitViewController
@property (nonatomic,strong) NotSelectedDialogsViewController *noSelectedViewController;
@end

@implementation TGDisclosureViewController

@synthesize view = _view;

-(void)loadView {
    
    _view = [[TGDisclosureView alloc] initWithFrame:self.frameInit];
    
    self.navigationViewController = [[TMNavigationController alloc] initWithFrame:self.view.bounds];
    
    _noSelectedViewController = [[NotSelectedDialogsViewController alloc] initWithFrame:self.view.bounds];
    _noSelectedViewController.customTextCap = NSLocalizedString(@"Conversation.SelectConversationToViewChatInfo", nil);
    [self.view addSubview:self.navigationViewController.view];
    
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.view setAutoresizesSubviews:YES];
    
    
    TMView *separator = [[TMView alloc] initWithFrame:self.view.bounds];
    separator.backgroundColor = DIALOG_BORDER_COLOR;
    
    [self.view addSubview:separator];
    
    
    [Notification addObserver:self selector:@selector(notificationDialogSelectionChanged:) name:@"ChangeDialogSelection"];
}

-(void)notificationDialogSelectionChanged:(NSNotification *)notification {
    
    TL_conversation *dialog = [notification.userInfo objectForKey:KEY_DIALOG];
    
    
    
    if(self.rightNavigationController.messagesViewController.conversation) {
        [self.navigationViewController clear];
        [self.navigationViewController pushViewController:_noSelectedViewController animated:NO];
        [self.navigationViewController showInfoPage:self.rightNavigationController.messagesViewController.conversation animated:NO isDisclosureController:YES];
    } else {
        [self.navigationViewController clear];
        [self.navigationViewController pushViewController:_noSelectedViewController animated:NO];
    }
    
}

-(void)dealloc {
    [Notification removeObserver:self];
}

- (TMView *)view {
    if(!_view)
        [self loadView];
    return _view;
}

@end


@interface MainViewController ()
-(void)checkLeftView;
@end

@interface MainViewController ()<TGSplitControllerDelegate> {
    NSSize oldLeftSize,oldRightSize,newLeftSize,newRightSize;
    BOOL _singleLayout;
}
@property (nonatomic,strong) TGSplitView *splitView;

@property (nonatomic,strong) TMView *leftViewContainer;

@property (nonatomic,strong) TGDisclosureViewController *disclosureController;

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
    
    
    
    
    _disclosureController = [[TGDisclosureViewController alloc] initWithFrame:NSMakeRect(0, 0, 300, self.view.bounds.size.height)];
    
    [_splitView setProportion:(struct TGSplitProportion){MIN_SINGLE_LAYOUT_WIDTH,300+MIN_SINGLE_LAYOUT_WIDTH} forState:TGSplitViewStateSingleLayout];
    [_splitView setProportion:(struct TGSplitProportion){MIN_SINGLE_LAYOUT_WIDTH,1200} forState:TGSplitViewStateDualLayout];
    [_splitView setProportion:(struct TGSplitProportion){300,FLT_MAX} forState:TGSplitViewStateTripleLayout];
        
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
        case TGSplitViewStateTripleLayout:
            [self.leftViewController.view setFrameSize:NSMakeSize(w, NSHeight(self.leftViewController.view.frame))];
            [self.rightViewController.view setFrameSize:NSMakeSize(MAX_SINGLE_LAYOUT_WIDTH, NSHeight(self.rightViewController.view.frame))];
            
            [_splitView addController:_leftViewController proportion:(struct TGSplitProportion){w,w}];
            [_splitView addController:_rightViewController proportion:(struct TGSplitProportion){1000,1000}];
            
            [_splitView addController:_disclosureController proportion:(struct TGSplitProportion){300,FLT_MAX}];
            [_disclosureController notificationDialogSelectionChanged:nil];
            

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

-(BOOL)isTripleLayout {
    return self.splitView.state == TGSplitViewStateTripleLayout;
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
