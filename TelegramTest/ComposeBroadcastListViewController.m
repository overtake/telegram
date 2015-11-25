//
//  ComposeBroadcastListViewController.m
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeBroadcastListViewController.h"
#import "TGDateUtils.h"


@interface ComposeBroadcastTableItem : TMRowItem
@property (nonatomic,strong) TL_broadcast *broadcast;
@property (nonatomic,strong) NSAttributedString *date;
@end

@interface ComposeBroadcastTableItemView : TMRowView
@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMTextField *descField;
@property (nonatomic, strong) TMTextField *dateTextField;
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@end


@implementation ComposeBroadcastTableItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        self.broadcast = object;
        
        NSMutableAttributedString *date = [[NSMutableAttributedString alloc] init];
        [date setSelectionColor:NSColorFromRGB(0xcbe1f0) forColor:NSColorFromRGB(0xaeaeae)];
        [date setSelectionColor:GRAY_TEXT_COLOR forColor:NSColorFromRGB(0x333333)];
        [date setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];
        
        int time = self.broadcast.date;
        time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
        
        NSString *dateStr = [TGDateUtils stringForMessageListDate:time];
        [date appendString:dateStr withColor:NSColorFromRGB(0xaeaeae)];
        
        self.date = date;

    }
    
    return self;
}


-(NSUInteger)hash {
    return self.broadcast.n_id;
}

@end



@implementation ComposeBroadcastTableItemView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.avatarImageView = [TMAvatarImageView standartTableAvatar];

        [self addSubview:self.avatarImageView];
        
        self.titleTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(68, 33, 0, 0)];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setSelector:@selector(dialogTitle)];
        [self.titleTextField setEncryptedSelector:@selector(dialogTitleEncrypted)];
        [self.titleTextField setDrawsBackground:NO];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self.titleTextField setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.titleTextField];
        
        
        self.descField = [[TMTextField alloc] initWithFrame:NSMakeRect(68, 15, 0, 0)];
        [self.descField setEditable:NO];
        [self.descField setBordered:NO];
        [self.descField setBackgroundColor:[NSColor clearColor]];
        [self.descField setFont:TGSystemFont(12.5)];
        [[self.descField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.descField cell] setTruncatesLastVisibleLine:YES];
        [self.descField setAutoresizingMask:NSViewWidthSizable];
        [self.descField setAlignment:NSLeftTextAlignment];
        [self addSubview:self.descField];
        
        self.dateTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 34, 0, 0)];
        [self.dateTextField setAutoresizingMask:NSViewMinXMargin];
        [self.dateTextField setEditable:NO];
        [self.dateTextField setBordered:NO];
        [self.dateTextField setBackgroundColor:[NSColor clearColor]];
        [self.dateTextField setFont:TGSystemLightFont(11)];
        [self addSubview:self.dateTextField];
        
        [self setSelectedBackgroundColor: NSColorFromRGB(0xfafafa)];
        [self setNormalBackgroundColor:NSColorFromRGB(0xffffff)];

    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    
    TL_broadcast *broadcast = [(ComposeBroadcastTableItem *)[self rowItem] broadcast];
    
    [self.avatarImageView setBroadcast:broadcast];
    
    [self.titleTextField setBroadcast:broadcast];
    
    NSMutableAttributedString *str = [[broadcast statusForMessagesHeaderView] mutableCopy];
    
    [str setAlignment:NSLeftTextAlignment range:str.range];
    
    [self.descField setAttributedStringValue:str];
    
   
    
    NSAttributedString *date = [(ComposeBroadcastTableItem *)[self rowItem] date];
    
    self.dateTextField.attributedStringValue = date;
    
    [self.dateTextField sizeToFit];

    [self.dateTextField setFrameOrigin:NSMakePoint(self.bounds.size.width - self.dateTextField.frame.size.width - 20, self.dateTextField.frame.origin.y)];
    
    
    [self.descField setFrameOrigin:NSMakePoint(68, 15)];
    [self.titleTextField setFrameOrigin:NSMakePoint(68, 33)];
    
    
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
     [self.titleTextField sizeToFit];
    
    [self.descField sizeToFit];
    
    int max_width = (NSWidth(self.frame) - 68 - 20);
    
    if(NSWidth(self.descField.frame) > max_width) {
        [self.descField setFrameSize:NSMakeSize(max_width, NSHeight(self.descField.frame))];
    }
    
    if(NSWidth(self.titleTextField.frame) > max_width) {
        [self.titleTextField setFrameSize:NSMakeSize(max_width, NSHeight(self.titleTextField.frame))];
    }
    
    [GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(68, 0, NSWidth(self.frame) - 68 - 20, 1));
    
}


@end

@interface ComposeBroadcastListViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation ComposeBroadcastListViewController

-(void)loadView {
    [super loadView];
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.tableView.containerView];
    
    self.tableView.tm_delegate = self;
    
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return 66;
}


- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self.tableView cacheViewForClass:[ComposeBroadcastTableItemView class] identifier:@"BroadcastItem" withSize:NSMakeSize(self.view.bounds.size.width, 66)];
}
- (void)selectionDidChange:(NSInteger)row item:(ComposeBroadcastTableItem *) item {
    [appWindow().navigationController showMessagesViewController:item.broadcast.conversation];
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    
    [self.tableView removeAllItems:YES];
    
    NSArray *all = [[BroadcastManager sharedManager] all];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [all enumerateObjectsUsingBlock:^(TL_broadcast *obj, NSUInteger idx, BOOL *stop) {
        [items addObject:[[ComposeBroadcastTableItem alloc] initWithObject:obj]];
    }];
    
    
    [self.tableView insert:items startIndex:0 tableRedraw:NO];
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    self.action.currentViewController = self;
    
    [self.tableView cancelSelection];
    
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
}


@end
