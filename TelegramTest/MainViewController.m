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



#define MIN_SINGLE_LAYOUT_WIDTH 380
#define MAX_SINGLE_LAYOUT_WIDTH 600

#define MAX_LEFT_WIDTH 300

@interface MainViewController ()
-(void)checkLeftView;
@end

@interface MainView : TMView

@end


@implementation MainView

-(void)setFrame:(NSRect)frame {
    
    
    MainViewController *controller = [Telegram mainViewController];
    
    BOOL currentLayout = ![controller isMinimisze] && (self.frame.size.width < MAX_SINGLE_LAYOUT_WIDTH);
    
    [super setFrame:frame];
    
    BOOL nextLayout = ![controller isMinimisze] && (self.frame.size.width < MAX_SINGLE_LAYOUT_WIDTH);
    
    if(currentLayout != nextLayout) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Telegram mainViewController] layout];
            [[Telegram rightViewController] didChangedLayout];
            [[Telegram mainViewController] checkLeftView];
        });
        
   //     [Notification perform:LAYOUT_CHANGED data:nil];
        //
        
    }
}

@end

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



@interface MainViewController () {
    NSSize oldLeftSize,oldRightSize,newLeftSize,newRightSize;
    BOOL _singleLayout;
}
@property (nonatomic,strong) MainSplitView *splitView;

@property (nonatomic,strong) TMView *leftViewContainer;

@end

@implementation MainViewController

- (void)loadView {
    
    self.view = [[MainView alloc] initWithFrame:self.frameInit];
    
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
    
    
    self.leftViewContainer = [[TMView alloc] initWithFrame:self.leftViewController.frameInit];
    
    self.leftViewContainer.backgroundColor = NSColorFromRGB(0x000000);
    
    self.leftViewController.view.autoresizingMask = self.leftViewContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self.leftViewContainer setAutoresizesSubviews:YES];
    
    self.leftViewController.archiver = archiver;
    
    [self.leftViewController viewWillAppear:NO];
    [self.leftViewContainer addSubview:self.leftViewController.view];
    [self.leftViewController viewDidAppear:NO];
    
    
    [self.splitView addSubview:self.leftViewContainer];
   
    
    self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    
    self.rightViewController = [[RightViewController alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.bounds.size.height)];
    [self.rightViewController viewWillAppear:NO];
    [self.splitView addSubview:self.rightViewController.view];
    [self.rightViewController viewDidAppear:NO];
    

    

    [self layout];
    
   
    
}


-(void)checkLeftView {
    
    if(![self isSingleLayout] && self.leftViewController.view.superview != self.leftViewContainer) {
        [self.leftViewController.view removeFromSuperview];
        
                
        [self.leftViewController.view setFrame:self.leftViewContainer.bounds];
        
        [self.leftViewContainer addSubview:self.leftViewController.view];
    }
    
}


-(void)layout {
    

    _singleLayout = ![self isMinimisze] && (self.view.frame.size.width < MAX_SINGLE_LAYOUT_WIDTH);
    
    if([self isSingleLayout]) {

        

        [self.leftViewContainer setFrameSize:NSMakeSize([self isConversationListShown] ? NSWidth(self.view.frame) : 0,NSHeight(self.leftViewContainer.frame))];
        
         [self.leftViewController.view setFrame:self.leftViewContainer.bounds];
        
        [self.rightViewController.view setFrameSize:NSMakeSize([self isConversationListShown] ? 0 : NSWidth(self.view.frame),NSHeight(self.rightViewController.view.frame))];
    
    } else {
        
        
        
        int w = MIN_SINGLE_LAYOUT_WIDTH + 30;
        
      //  [self.splitView setPosition:NSWidth(self.splitView.frame) - w  ofDividerAtIndex:0];
        
        
        if(NSWidth(self.leftViewContainer.frame) != 70) {
            
            [self.leftViewContainer setFrameSize:NSMakeSize( NSWidth(self.leftViewContainer.frame) == 0 ?  MIN(NSWidth(self.view.frame) - w, MAX_LEFT_WIDTH) : MIN(MIN(NSWidth(self.leftViewContainer.frame),MAX_LEFT_WIDTH),NSWidth(self.view.frame) - w),NSHeight(self.leftViewContainer.frame))];
        }
        
        
        [self.leftViewController.view setFrame:self.leftViewContainer.bounds];
        
        [self.rightViewController.view setFrameSize:NSMakeSize(NSWidth(self.view.frame) - NSWidth(self.leftViewContainer.frame),NSHeight(self.rightViewController.view.frame))];
        
        
        
        //
        
        // MTLog(@"%f:%f", [self.splitView minPossiblePositionOfDividerAtIndex:1],[self.splitView maxPossiblePositionOfDividerAtIndex:1]);
        
        // [self.splitView setPosition:[self.splitView minPossiblePositionOfDividerAtIndex:1] ofDividerAtIndex:1];
        
    }
}

-(void)checkLayout {
    if([self isSingleLayout]) {
       // [self.splitView setPosition:[self isConversationListShown] ? NSWidth(self.view.frame) : 0 ofDividerAtIndex:0];
      //  [self.splitView setPosition:[self isConversationListShown] ? 0 : NSWidth(self.view.frame) ofDividerAtIndex:1];
        
      //  [self.leftViewContainer setFrameSize:NSMakeSize([self isConversationListShown] ? NSWidth(self.view.frame) : 0,NSHeight(self.leftViewContainer.frame))];
        
       // [self.rightViewController.view setFrameSize:NSMakeSize([self isConversationListShown] ? 0 : NSWidth(self.view.frame),NSHeight(self.leftViewContainer.frame))];
        
    }
}

-(BOOL)isConversationListShown {
    return NO;
}



-(void)minimisize {
    [self.splitView setPosition:0 ofDividerAtIndex:0];
}

-(BOOL)isMinimisze {
    return self.leftViewContainer.frame.size.width == 70;
}

-(void)unminimisize {
    [self.splitView setPosition:300 ofDividerAtIndex:0];
}


-(BOOL)isSingleLayout {
    return _singleLayout;
}


-(void)setConnectionState:(ConnectingStatusType)state {
   
}

//-(BOOL)shouldAdjustSizeOfSubview:(NSView *)subview {
//    BOOL res = NO;
//    
//    if(subview == self.rightViewController.view) {
//        res = [self isMinimisze] || ([self isSingleLayout] ||  NSWidth(self.rightViewController.view.frame) > MIN_SINGLE_LAYOUT_WIDTH); // ![self isMinimisze] && ( [self isSingleLayout] || NSWidth(self.leftViewContainer.frame) <= MAX_LEFT_WIDTH );
//        
//    }
//
//    
//    return res;
//}
//
//- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
//    
//    if(subview == self.leftViewContainer)
//        return ![self isMinimisze] && ( ([self isSingleLayout] && [self isConversationListShown]) || (![self isSingleLayout] && ((NSWidth(self.leftViewContainer.frame) <= MAX_LEFT_WIDTH ))) );
//    else {
//        return [self isMinimisze] || ((![self isSingleLayout] || ([self isSingleLayout] && ![self isConversationListShown])) && NSWidth(self.rightViewController.view.frame) > MIN_SINGLE_LAYOUT_WIDTH);
//    }
//    
//}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}


- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {

    if(subview == self.leftViewContainer) {
        
        if([self isMinimisze] || [self isSingleLayout]) {
            return NO;
        } else {
            return NSWidth(self.leftViewContainer.frame) < MAX_LEFT_WIDTH;
        }
        
        
        
    } else {
        
        if([self isMinimisze] || [self isSingleLayout]) {
            return YES;
        } else {
            return NSWidth(self.rightViewController.view.frame) > MIN_SINGLE_LAYOUT_WIDTH;
        }
        
      //  return [self isMinimisze] || ((![self isSingleLayout] || ([self isSingleLayout] && ![self isConversationListShown])) && NSWidth(self.rightViewController.view.frame) > MIN_SINGLE_LAYOUT_WIDTH);
    }

}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMaximumPosition;
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



-(BOOL)isResizeToBig {
    return oldLeftSize.width < newLeftSize.width;
}

-(BOOL)isResizeToLittle {
    return oldLeftSize.width > newLeftSize.width;
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
    
   // [self layout];
    
  //  [self.rightViewController.view setFrameSize:NSMakeSize(MAX(NSWidth(self.rightViewController.view.frame), MIN_SINGLE_LAYOUT_WIDTH), NSHeight(self.rightViewController.view.frame))];
    
    
    if(window.minSize.width > window.frame.size.width) {
        [window setFrame:NSMakeRect(NSMinX(self.splitView.window.frame), NSMinY(self.splitView.window.frame), window.minSize.width, NSHeight(window.frame)) display:YES];
    }
    
    
}

@end
