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


#define MIN_SINGLE_LAYOUT_WIDTH 460
#define MAX_SINGLE_LAYOUT_WIDTH 670

#define MAX_LEFT_WIDTH 350

@interface MainViewController () {
    NSSize oldLeftSize,oldRightSize,newLeftSize,newRightSize;
}
@property (nonatomic,strong) MainSplitView *splitView;

@end

@implementation MainViewController

- (void)loadView {
    
    [super loadView];
    
    self.splitView = [[MainSplitView alloc] initWithFrame:self.frameInit];
    [self.splitView setVertical:YES];
    [self.splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [self.splitView setDelegate:self];
    
    [self.splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:self.splitView];
    
    TGWindowArchiver *archiver = [TGWindowArchiver find:@"conversation"];
    
    if(!archiver) {
        archiver = [[TGWindowArchiver alloc] initWithName:@"conversation"];
        archiver.size = NSMakeSize(290, self.view.bounds.size.height);
        archiver.origin = NSMakePoint(0, 0);
    }
    
    //LeftController
    self.leftViewController = [[LeftViewController alloc] initWithFrame:NSMakeRect(archiver.origin.x, archiver.origin.y,archiver.size.width, archiver.size.height)];
    
    self.leftViewController.archiver = archiver;
    
    [self.leftViewController viewWillAppear:NO];
    [self.splitView addSubview:self.leftViewController.view];
    [self.leftViewController viewDidAppear:NO];
    
   
    
    self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    
    self.rightViewController = [[RightViewController alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.bounds.size.height)];
    [self.rightViewController viewWillAppear:NO];
    [self.splitView addSubview:self.rightViewController.view];
    [self.rightViewController viewDidAppear:NO];
    
    
    

    [self layout];
    
    
    
}


-(void)layout {
    

    if([self isSingleLayout]) {


        
        
        [self.leftViewController.view setFrameSize:NSMakeSize([self isConversationListShown] ? NSWidth(self.view.frame) : 0,NSHeight(self.leftViewController.view.frame))];
        
        
         [self.rightViewController.view setFrameSize:NSMakeSize([self isConversationListShown] ? 0 : NSWidth(self.view.frame),NSHeight(self.rightViewController.view.frame))];
    } else {
        
        int w = 460;
        
      //  [self.splitView setPosition:NSWidth(self.splitView.frame) - w  ofDividerAtIndex:0];
        
        
        if(NSWidth(self.leftViewController.view.frame) != 70) {
            [self.leftViewController.view setFrameSize:NSMakeSize( NSWidth(self.leftViewController.view.frame) == 0 ?  NSWidth(self.view.frame) - w : MIN(MIN(NSWidth(self.leftViewController.view.frame),MAX_LEFT_WIDTH),NSWidth(self.view.frame) - w),NSHeight(self.leftViewController.view.frame))];
        }
        
        
        [self.rightViewController.view setFrameSize:NSMakeSize(NSWidth(self.view.frame) - NSWidth(self.leftViewController.view.frame),NSHeight(self.rightViewController.view.frame))];
        
        
        //
        
        // NSLog(@"%f:%f", [self.splitView minPossiblePositionOfDividerAtIndex:1],[self.splitView maxPossiblePositionOfDividerAtIndex:1]);
        
        // [self.splitView setPosition:[self.splitView minPossiblePositionOfDividerAtIndex:1] ofDividerAtIndex:1];
        
    }
}

-(void)checkLayout {
    if([self isSingleLayout]) {
       // [self.splitView setPosition:[self isConversationListShown] ? NSWidth(self.view.frame) : 0 ofDividerAtIndex:0];
      //  [self.splitView setPosition:[self isConversationListShown] ? 0 : NSWidth(self.view.frame) ofDividerAtIndex:1];
        
        [self.leftViewController.view setFrameSize:NSMakeSize([self isConversationListShown] ? NSWidth(self.view.frame) : 0,NSHeight(self.leftViewController.view.frame))];
        
        [self.rightViewController.view setFrameSize:NSMakeSize([self isConversationListShown] ? 0 : NSWidth(self.view.frame),NSHeight(self.rightViewController.view.frame))];
        
    }
}

-(BOOL)isConversationListShown {
    return [self.rightViewController.navigationViewController.currentController isKindOfClass:[NotSelectedDialogsViewController class]] || [self.rightViewController isModalViewActive];
}



-(void)minimisize {
    [self.splitView setPosition:0 ofDividerAtIndex:0];
}

-(BOOL)isMinimisze {
    return self.leftViewController.view.frame.size.width == 70;
}

-(void)unminimisize {
    [self.splitView setPosition:300 ofDividerAtIndex:0];
}


-(BOOL)isSingleLayout {
    return ![self isMinimisze] && (self.view.frame.size.width < MAX_SINGLE_LAYOUT_WIDTH);
}


-(void)setConnectionState:(ConnectingStatusType)state {
   
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    
    if(subview == self.leftViewController.view)
        return ![self isMinimisze] && ( ([self isSingleLayout] && [self isConversationListShown]) || (![self isSingleLayout] && ((NSWidth(self.leftViewController.view.frame) <= MAX_LEFT_WIDTH ))) );
    else {        
        return [self isMinimisze] || ((![self isSingleLayout] || ([self isSingleLayout] && ![self isConversationListShown])) && NSWidth(self.rightViewController.view.frame) > MIN_SINGLE_LAYOUT_WIDTH);
    }
    
}



-(BOOL)isResizeToBig {
    return oldLeftSize.width < newLeftSize.width;
}

-(BOOL)isResizeToLittle {
    return oldLeftSize.width > newLeftSize.width;
}


- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return self.splitView.frame.size.width;
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    if(proposedPosition < 80)
        return  [self isSingleLayout] ? 0 : (self.leftViewController.canMinimisize ? 70 : 270);
    if(proposedPosition < 270)
        return 270;
    
    if(proposedPosition > MAX_LEFT_WIDTH && ![self isSingleLayout])
        return MAX_LEFT_WIDTH;
    
    
    if(NSWidth(self.view.frame) - proposedPosition < MIN_SINGLE_LAYOUT_WIDTH )
        return NSWidth(self.view.frame) - MIN_SINGLE_LAYOUT_WIDTH;
    
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
        
    [window setMinSize:NSMakeSize( [self isMinimisze] ? MIN_SINGLE_LAYOUT_WIDTH + 70 : MIN_SINGLE_LAYOUT_WIDTH, 400)];
    
    [self layout];
    
//    [self.rightViewController.view setFrameSize:NSMakeSize(NSWidth(self.view.frame) - NSWidth(self.leftViewController.view.frame), NSHeight(self.rightViewController.view.frame))];
    
    
    if(window.minSize.width > window.frame.size.width) {
        [window setFrame:NSMakeRect(NSMinX(self.splitView.window.frame), NSMinY(self.splitView.window.frame), window.minSize.width, NSHeight(window.frame)) display:YES];
    }
    
}

@end
