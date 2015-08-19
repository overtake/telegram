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


@interface ComposeCreateChannelViewController ()
-(void)updateCompose;
@end



@interface CreateChannelHeaderView : TMRowView <NSTextFieldDelegate>
@property (nonatomic,strong) TMTextField *textView;
@property (nonatomic,strong) TLChat *chat;
@property (nonatomic,strong) TMTextField *nameField;

@property (nonatomic,strong) ComposeCreateChannelViewController *controller;
@end

@implementation CreateChannelHeaderView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.nameField = [TMTextField defaultTextField];
        
        [self.nameField setFrameSize:NSMakeSize(20, 20)];
        
        [self.nameField setTextColor:DARK_GRAY];
        
        
        
        
        [self.nameField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
        
        [self.nameField setAlignment:NSCenterTextAlignment];
        
        [self.nameField setFrameOrigin:NSMakePoint(35, 47)];
        
        
        
        TMView *container = [[TMView alloc] initWithFrame:NSMakeRect(20, 30, 50, 50)];
        
        [container addSubview:self.nameField];
        
        
        [self addSubview:container];
        
        
        self.textView = [[TMTextField alloc] initWithFrame:NSMakeRect(90, 45, NSWidth(frameRect) - 110, 23)];
        
        
        [self.textView setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
        
        [self.textView setEditable:YES];
        [self.textView setBordered:NO];
        [self.textView setFocusRingType:NSFocusRingTypeNone];
        [self.textView setTextOffset:NSMakeSize(0, 5)];
        
        self.textView.delegate = self;
        
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.ChannelTitle", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:15] forRange:str.range];
        
        [self.textView.cell setPlaceholderAttributedString:str];
        [self.textView setPlaceholderPoint:NSMakePoint(2, 0)];
        
        
        
        
        [self.textView becomeFirstResponder];
        
        
        [self setName:self.textView.stringValue];
        
        [self addSubview:self.textView];
        
        self.chat = [TL_chat createWithN_id:-1 title:@"" photo:[TL_chatPhotoEmpty create] participants_count:0 date:0 left:NO version:1];
        
        
    }
    
    return self;
}

-(BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}


-(void)controlTextDidChange:(NSNotification *)obj {
    [self setName:self.textView.stringValue];
}

-(void)setName:(NSString *)name {
    self.chat.title = self.textView.stringValue;
    
    NSString *holder = self.textView.stringValue.length > 0 ? [self.textView.stringValue substringToIndex:1] : [[self.textView.cell placeholderAttributedString].string substringToIndex:1];
    [self.nameField setStringValue:holder];
    [self.nameField sizeToFit];
    
    [self.nameField setFrameSize:NSMakeSize(50, NSHeight(self.nameField.frame))];
    
    
    [self.nameField setFrameOrigin:NSMakePoint(0, NSHeight(self.nameField.frame) - 5)];
    
    
    [self.controller updateCompose];
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path appendBezierPathWithArcWithCenter: NSMakePoint(45, 55)
                                     radius: 25
                                 startAngle: 0
                                   endAngle: 360 clockwise:NO];
    
    [GRAY_BORDER_COLOR set];
    [path stroke];
    
    NSRectFill(NSMakeRect(92, 38, NSWidth(self.frame) - 114, 1));
}



@end



@interface ComposeCreateChannelViewController ()<ComposeBehaviorDelegate>

@property (nonatomic,strong) CreateChannelHeaderView *headerView;

@end

@implementation ComposeCreateChannelViewController



-(void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;

    self.headerView = [[CreateChannelHeaderView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), 100)];
    
    self.headerView.controller = self;
    
    
    [self.view addSubview:self.headerView];
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
    
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
}


-(void)updateCompose {
    
    [self.doneButton setDisable:self.headerView.textView.stringValue.length == 0];
    
    self.action.result.singleObject = self.headerView.chat.title;
}

-(BOOL)becomeFirstResponder {
    return [self.headerView becomeFirstResponder];
}



@end
