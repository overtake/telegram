//
//  ComposeChatCreateViewController.m
//  Telegram
//
//  Created by keepcoder on 01.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeChatCreateViewController.h"
#import "SelectUserRowView.h"
#import "SelectUserItem.h"
#import "SelectUsersTableView.h"


@interface ComposeChatCreateViewController ()
-(void)updateCompose;
@end


@interface ChatNameTextField : TMTextField<NSTextFieldDelegate>
@property (nonatomic,strong) dispatch_block_t didChangedValue;
@end


@implementation ChatNameTextField


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.placeHolderOnSelf = YES;
        [self placeholderView:[[PlaceholderTextView alloc] initWithFrame:self.bounds]];
        
        self.delegate = self;
    }
    
    return self;
}


-(BOOL)becomeFirstResponder {
    
    BOOL result = [super becomeFirstResponder];
    
 
    return result;
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self controlTextDidChange:nil];
}

-(void)controlTextDidChange:(NSNotification *)obj {
    
    
    if(self.stringValue.length > 0) {
        [self.placeholderView removeFromSuperview];
    } else if(self.stringValue.length == 0) {
        
        [self addSubview:self.placeholderView];
    }
    
    
    if(self.didChangedValue) {
        self.didChangedValue();
    }
}

@end

@interface CreateChatHeaderItem : TMRowItem

@end

@implementation CreateChatHeaderItem

-(NSUInteger)hash {
    return 0;
}

@end


@interface CreateChatHeaderView : TMRowView <NSTextFieldDelegate>
@property (nonatomic,strong) TMTextField *textView;
@property (nonatomic,strong) TLChat *chat;
@property (nonatomic,strong) TMTextField *nameField;

@property (nonatomic,strong) ComposeChatCreateViewController *controller;
@end

@implementation CreateChatHeaderView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.nameField = [TMTextField defaultTextField];
        
        [self.nameField setFrameSize:NSMakeSize(20, 20)];
        
        [self.nameField setTextColor:DARK_GRAY];
        
        
       
        
        [self.nameField setFont:TGSystemFont(15)];
        
        [self.nameField setAlignment:NSCenterTextAlignment];
        
        [self.nameField setFrameOrigin:NSMakePoint(35, 47)];
        
        
        
        TMView *container = [[TMView alloc] initWithFrame:NSMakeRect(20, 30, 50, 50)];
        
        [container addSubview:self.nameField];
        
        
        [self addSubview:container];
        
        
        self.textView = [[TMTextField alloc] initWithFrame:NSMakeRect(90, 45, NSWidth(frameRect) - 110, 23)];
        
        
        [self.textView setFont:TGSystemFont(15)];
        
        [self.textView setEditable:YES];
        [self.textView setBordered:NO];
        [self.textView setFocusRingType:NSFocusRingTypeNone];
        [self.textView setTextOffset:NSMakeSize(0, 5)];
        
        self.textView.delegate = self;
        

        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.GroupNamePlaceHolder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:TGSystemFont(15) forRange:str.range];
        
        [self.textView.cell setPlaceholderAttributedString:str];
        [self.textView setPlaceholderPoint:NSMakePoint(2, 0)];
        
        
        
        
        [self.textView becomeFirstResponder];
        
        
        [self setName:self.textView.stringValue];
        
        [self addSubview:self.textView];
        
        self.chat = [TL_chat createWithFlags:0 n_id:-1 title:@"" photo:[TL_chatPhotoEmpty create] participants_count:0 date:0 version:0 migrated_to:nil];
        
        
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


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.nameField setFrameOrigin:NSMakePoint(0, NSHeight(self.nameField.frame) - 5)];
    
    [self.textView setFrame:NSMakeRect(90, 45, newSize.width - 110, 23)];
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

@interface SelectedUserRowView : SelectUserRowView

@end


@implementation SelectedUserRowView

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(BOOL)isEditable {
    return NO;
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


@end

@interface ComposeChatCreateViewController ()<TMTableViewDelegate, ComposeBehaviorDelegate>
@property (nonatomic,strong) TMTableView *tableView;

@property (nonatomic,strong) CreateChatHeaderView *headerView;
@property (nonatomic,strong) CreateChatHeaderItem *headerItem;

@end

@implementation ComposeChatCreateViewController



-(void)loadView {
    [super loadView];
    
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.tableView.containerView];
    
    
    
    self.tableView.tm_delegate = self;
    
    self.headerItem = [[CreateChatHeaderItem alloc] init];
    
    self.headerView = [[CreateChatHeaderView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), 100)];
    
    self.headerView.controller = self;

    
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
    
    [self.view.window makeFirstResponder:self.headerView.textView];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (TLUser *item in self.action.result.multiObjects) {
        [array addObject:[[SelectUserItem alloc] initWithObject:item]];
    }
    
    [self.tableView removeAllItems:NO];
    
    [self.doneButton setDisable:YES];
    [self.headerView.textView setStringValue:@""];
    
    [self.tableView insert:self.headerItem atIndex:0 tableRedraw:NO];
    
    
    [self.tableView insert:array startIndex:1 tableRedraw:NO];
    
    [self.tableView reloadData];
}


-(void)updateCompose {

    [self.doneButton setDisable:self.headerView.textView.stringValue.length == 0];
    
    self.action.result.singleObject = self.headerView.chat.title;
}

-(BOOL)becomeFirstResponder {
    return [self.headerView becomeFirstResponder];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? 100 : 60;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? self.headerView : [self.tableView cacheViewForClass:[SelectedUserRowView class] identifier:@"AcceptUser" withSize:NSMakeSize(NSWidth(self.view.frame), 60)];
}

-(void)selectionDidChange:(NSInteger)row item:(TMRowItem *)item {
    
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

@end
