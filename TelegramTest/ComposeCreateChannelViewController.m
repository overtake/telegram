//
//  ComposeChatCreateViewController.m
//  Telegram
//
//  Created by keepcoder on 01.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeCreateChannelViewController.h"
#import "SelectUserRowView.h"
#import "SelectUserItem.h"
#import "SelectUsersTableView.h"
#import "ITSwitch.h"
#import "TGSettingsTableView.h"


@interface CreateChannelHeaderItem : TGGeneralRowItem
@property (nonatomic,strong) NSString *channelName;
@property (nonatomic,strong) NSString *channelAbout;
@property (nonatomic,assign) BOOL discussion;
@property (nonatomic,weak) ComposeCreateChannelViewController *controller;
@end

@interface ComposeCreateChannelViewController ()
-(void)updateComposeWithHeight:(int)height;
@end



@interface CreateChannelHeaderView : TMRowView <NSTextFieldDelegate>
@property (nonatomic,strong) TMTextField *nameTextView;
@property (nonatomic,strong) TMTextField *aboutTextView;


@property (nonatomic,strong) TMTextField *aboutDescription;





@end

@implementation CreateChannelHeaderView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.aboutTextView = [[TMTextField alloc] initWithFrame:NSMakeRect(30, 24, NSWidth(frameRect) - 60, 23)];
        
        
        [self.aboutTextView setFont:TGSystemFont(15)];
        
        [self.aboutTextView setEditable:YES];
        [self.aboutTextView setBordered:NO];
        [self.aboutTextView setFocusRingType:NSFocusRingTypeNone];
        [self.aboutTextView setTextOffset:NSMakeSize(0, 5)];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:TGSystemFont(15) forRange:str.range];
        
        [self.aboutTextView.cell setPlaceholderAttributedString:str];
        [self.aboutTextView setPlaceholderPoint:NSMakePoint(2, 0)];
        
        
        [self addSubview:self.aboutTextView];
        
        
        
        _aboutDescription = [TMTextField defaultTextField];
        [_aboutDescription setFont:TGSystemFont(13)];
        [_aboutDescription setTextColor:GRAY_TEXT_COLOR];
        
        [_aboutDescription setStringValue:NSLocalizedString(@"Compose.ChannelAboutDescription", nil)];
        
        
        [_aboutDescription sizeToFit];
        
        
        [_aboutDescription setFrameOrigin:NSMakePoint(30, 0)];
        
        [self addSubview:_aboutDescription];
        
        
        self.nameTextView = [[TMTextField alloc] initWithFrame:NSMakeRect(92, 90, NSWidth(frameRect) - 122, 23)];
        
        
        [self.nameTextView setFont:TGSystemFont(15)];
    
        [self.nameTextView setEditable:YES];
        [self.nameTextView setBordered:NO];
        [self.nameTextView setFocusRingType:NSFocusRingTypeNone];
        [self.nameTextView setTextOffset:NSMakeSize(0, 5)];
        
         str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.ChannelTitlePlaceholder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:TGSystemFont(15) forRange:str.range];
        
        [self.nameTextView.cell setPlaceholderAttributedString:str];
        [self.nameTextView setPlaceholderPoint:NSMakePoint(2, 0)];
        
        
        
        [self.nameTextView becomeFirstResponder];
        
        
        [self addSubview:self.nameTextView];

        
        
        [self.nameTextView setDelegate:self];
        [self.aboutTextView setDelegate:self];
        
        
        
    }
    
    return self;
}

-(void)redrawRow {
    [super redrawRow];
    
    CreateChannelHeaderItem *item = (CreateChannelHeaderItem *) [self rowItem];
    
    [self.aboutTextView setStringValue:item.channelAbout];
    [self.nameTextView setStringValue:item.channelName];
    

}



-(void)controlTextDidChange:(NSNotification *)obj {
    
    [self.aboutTextView setStringValue:[self.aboutTextView.stringValue substringToIndex:MIN(200,self.aboutTextView.stringValue.length)]];
    
    CreateChannelHeaderItem *item = (CreateChannelHeaderItem *) [self rowItem];
    
    item.channelAbout = self.aboutTextView.stringValue;
    item.channelName = self.nameTextView.stringValue;
    
     NSSize size = [self.aboutTextView.attributedStringValue sizeForTextFieldForWidth:NSWidth(self.frame) - 60];
    
    size.height = MAX(21, size.height);
    
    int nh = 139 + size.height;
    
    [item.controller updateComposeWithHeight:nh];
    
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize size = [self.aboutTextView.attributedStringValue sizeForTextFieldForWidth:newSize.width - 60];
    size.width = newSize.width - 60;
    size.height = MAX(21, size.height);
    
    [self.aboutTextView setFrameSize:size];
    
    [self.aboutTextView setFrame:NSMakeRect(30, 22, size.width, size.height)];
    
    [self.aboutDescription setFrameOrigin:NSMakePoint(30, 0)];
    [self.nameTextView setFrameOrigin:NSMakePoint(92, newSize.height - 70)];
    
    [self.nameTextView setFrameSize:NSMakeSize(newSize.width - 92 - 30, 20)];
}

-(BOOL)becomeFirstResponder {
    return [self.nameTextView becomeFirstResponder];
}



-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path appendBezierPathWithArcWithCenter: NSMakePoint(55,NSHeight(dirtyRect) - 60)
                                     radius: 25
                                 startAngle: 0
                                   endAngle: 360 clockwise:NO];
    
    
    [image_Camera() drawInRect:NSMakeRect(40,NSHeight(dirtyRect) - 70, image_Camera().size.width, image_Camera().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
    
    [GRAY_BORDER_COLOR set];
    [path stroke];
    
    NSRectFill(NSMakeRect(92, NSHeight(self.frame) - 84, NSWidth(self.frame) - 122, 1));
    
    
    
    NSRectFill(NSMakeRect(30, 20, NSWidth(self.frame) - 60, 1));
}



@end




@implementation CreateChannelHeaderItem

-(Class)viewClass {
    return [CreateChannelHeaderView class];
}

@end


@interface ComposeCreateChannelViewController ()<ComposeBehaviorDelegate>

@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) CreateChannelHeaderItem *headerItem;

@end

@implementation ComposeCreateChannelViewController



-(void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;

    
    
    self.tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    
    [self.view addSubview:self.tableView.containerView];
    
    
    _headerItem = [[CreateChannelHeaderItem alloc] initWithHeight:160];
    _headerItem.controller = self;
    
    [self.tableView addItem:_headerItem tableRedraw:NO];
    
    
    
//    
//    GeneralSettingsRowItem *discussionItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
//        
//        _headerItem.discussion = !_headerItem.discussion;
//        
//        [self updateCompose];
//        
//    } description:NSLocalizedString(@"Channel.Discussion", nil) height:60 stateback:^id(TGGeneralRowItem *item) {
//        
//        return @(_headerItem.discussion);
//        
//    }];
//    
//    
//    discussionItem.xOffset = 30;
//    
//    [self.tableView addItem:discussionItem tableRedraw:NO];
//    
//    
//    GeneralSettingsBlockHeaderItem *discussionDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.DiscussionEnableDescription", nil) height:62 flipped:YES];
//    
//    discussionDescription.xOffset = 30;
//    
//    
//    [self.tableView addItem:discussionDescription tableRedraw:NO];
    
    
    [self.tableView reloadData];
    
    
    
   // [self.view addSubview:self.headerView];
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    action.behavior.delegate = self;
}

-(void)behaviorDidEndRequest:(id)response {
    [self hideModalProgress];
}


-(void)behaviorDidStartRequest {
    [self showModalProgress];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.action.behavior composeDidCancel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.action.currentViewController = self;
    
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    if(self.action.result.stepResult.count > 0) {
        
        self.headerItem.channelName = ((NSArray *)self.action.result.stepResult[0]).count > 0 ? [self.action.result.stepResult[0] firstObject] : @"";
        self.headerItem.channelAbout = ((NSArray *)self.action.result.stepResult[0]).count == 2 ? [self.action.result.stepResult[0] lastObject] : @"";
        
        self.headerItem.discussion = [self.action.result.stepResult[1] intValue];
        
    } else {
        self.headerItem.channelName  = @"";
        self.headerItem.channelAbout = nil;
    }
    
    [self.tableView reloadData];
    
    
    [self.doneButton setDisable:self.headerItem.channelName.length == 0];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
}


-(void)updateComposeWithHeight:(int)height {
    
    [self.doneButton setDisable:self.headerItem.channelName.length == 0];
    
    NSArray *result = [NSArray array];
    
    if(self.headerItem.channelName.length > 0)
        result = [result arrayByAddingObject:self.headerItem.channelName];
    if(self.headerItem.channelAbout.length > 0)
        result = [result arrayByAddingObject:self.headerItem.channelAbout];
    
    
    
    NSArray *allSteps = self.action.result.stepResult;
    
    result = [@[result,@(self.headerItem.discussion)] arrayByAddingObjectsFromArray:[allSteps subarrayWithRange:NSMakeRange(MIN(1,allSteps.count), MIN(allSteps.count,abs((int)allSteps.count - 1)))]];
    
    if(!self.action.result) {
        self.action.result = [[ComposeResult alloc] initWithStepResult:result];
    } else {
        self.action.result.stepResult = result;
    }
    
    self.headerItem.height = height;
    
  //  id responder = self.view.window.firstResponder;
    
    [[NSAnimationContext currentContext] setDuration:0];
    [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
    
    CreateChannelHeaderView *header = [self.tableView viewAtColumn:0 row:0 makeIfNecessary:NO];
    
    if(header) {
        [header setFrameSize:NSMakeSize(NSWidth(header.frame), height)];
    }
    
 //   [responder becomeFirstResponder];
    
}

-(BOOL)becomeFirstResponder {
    
    return YES;
}



@end
