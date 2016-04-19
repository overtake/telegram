//
//  TGModernESGViewController.m
//  Telegram
//
//  Created by keepcoder on 19/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernEmojiViewController.h"
#import "EmojiButton.h"
#import "TGRaceEmoji.h"
#import "TGTextLabel.h"


@interface TGModernSegmentRowView : TMRowView
@property (nonatomic,strong) TGTextLabel *textLabel;
@end

@interface TGModernEmojiRowView : TMRowView
@property (nonatomic, strong) RBLPopover *racePopover;
@end

@interface TGModernSegmentItem : TMRowItem
@property (nonatomic,strong) NSAttributedString *header;
@end

@implementation TGModernSegmentItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:object withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        _header = attr;
        
    }
    
    return self;
}

-(int)height {
    return 34;
}

-(NSUInteger)hash {
    return [_header.string hash];
}

-(Class)viewClass {
    return [TGModernSegmentRowView class];
}

@end



@implementation TGModernSegmentRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] initWithFrame:NSMakeRect(5, 0, 0, 0)];
        [self addSubview:_textLabel];
        self.backgroundColor = NSColorFromRGBWithAlpha(0xffffff, 0.9);
    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    TGModernSegmentItem *item = (TGModernSegmentItem *)self.rowItem;
    
    [_textLabel setText:item.header maxWidth:NSWidth(self.frame) - 20];
    
    [_textLabel setCenteredYByView:self];
}

@end

@interface TGModernEmojiBottomButton : BTRButton
@property (nonatomic) int index;
@property (nonatomic,weak) id stickItem;
@end

@implementation TGModernEmojiBottomButton

- (void)handleStateChange {
    [super handleStateChange];
    
    if(self.state & BTRControlStateHover || self.state & BTRControlStateSelected || self.state & BTRControlStateHighlighted) {
        [self.backgroundImageView setAlphaValue:1];
    } else {
        [self.backgroundImageView setAlphaValue:0.7];
    }
    
}

@end


@interface TGModernEmojiRowItem : TMRowItem
@property (nonatomic,strong) NSArray *list;
@property (nonatomic,assign) NSUInteger nhash;
@property (nonatomic, weak) TGModernEmojiViewController *controller;

@end

@implementation TGModernEmojiRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _list = object;
        _nhash = [[_list componentsJoinedByString:@" "] hash];
        
    }
    
    return self;
}

-(int)height {
    return 34;
}

-(NSUInteger)hash {
    return _nhash;
}

-(Class)viewClass {
    return [TGModernEmojiRowView class];
}

@end




@implementation TGModernEmojiRowView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        [self setWantsLayer:YES];
        
    }
    return self;
}

- (void)emojiClick:(BTRButton *)button {
    
    TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) self.rowItem;
    if(!item.controller.epopover.lockHoverClose) {
        [item.controller insertEmoji:button.titleLabel.stringValue];
    }
    
}

-(void)emojiLongClick:(BTRButton *)button {
    
    TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) self.rowItem;
    
    static TGRaceEmoji *e_race_controller;
    static RBLPopover *race_popover;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        e_race_controller = [[TGRaceEmoji alloc] initWithFrame:NSMakeRect(0, 0, 208, 38) emoji:nil];
        
        race_popover = [[RBLPopover alloc] initWithContentViewController:(NSViewController *) e_race_controller];
        
        [race_popover setDidCloseBlock:^(RBLPopover *popover){
            [item.controller.epopover setLockHoverClose:NO];
        }];
        
        [e_race_controller loadView];
        
        
    });
    
    e_race_controller.popover = race_popover;
    e_race_controller.controller = item.controller;
    e_race_controller.ebutton = button;
    
    [race_popover setHoverView:button];
    [race_popover close];
    
    if([e_race_controller makeWithEmoji:[button.titleLabel.stringValue getEmojiFromString:YES][0]]) {
        
        [item.controller.epopover setLockHoverClose:YES];
        
        NSRect frame = button.bounds;
        frame.origin.y += 4;
        
        
        if(!race_popover.isShown) {
            [race_popover showRelativeToRect:frame ofView:button preferredEdge:CGRectMaxYEdge];
            
        }
    } else {
        [race_popover setHoverView:nil];
    }
    
    
}

-(void)redrawRow {
    [super redrawRow];
    
    TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) self.rowItem;
    
    while (item.list.count < self.subviews.count) {
        [[self.subviews lastObject] removeFromSuperview];
    }
    
    [item.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setEmoji:obj atIndex:idx];
    }];
    
}


- (void)setEmoji:(NSString *)string atIndex:(NSUInteger)index {
    
    TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) self.rowItem;
    
    if(self.subviews.count < index+1) {
        EmojiButton *button = [[EmojiButton alloc] initWithFrame:NSMakeRect(item.height * index, 0, item.height, item.height)];
        [button setTitleFont:TGSystemFont(17) forControlState:BTRControlStateNormal];
        [button addTarget:self action:@selector(emojiClick:) forControlEvents:BTRControlEventMouseUpInside];
        
        if(floor(NSAppKitVersionNumber) >= 1347 ) {
            [button addTarget:self action:@selector(emojiLongClick:) forControlEvents:BTRControlEventLongLeftClick];
        }
        
        [self addSubview:button];
    }
    
    EmojiButton *button = [self.subviews objectAtIndex:index];
    if(string) {
        [button setHidden:NO];
        
        NSString *modifier = [item.controller emojiModifier:string];
        
        if(modifier) {
            string = [string emojiWithModifier:modifier emoji:string];
        }
        
        [button setTitle:string forControlState:BTRControlStateNormal];
    } else {
        [button setHidden:YES];
    }
    
    
    [button setHighlighted:NO];
    [button setHovered:NO];
    [button setSelected:NO];
}


@end


@interface TGModernEmojiViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) TMView *bottomView;

@end

@implementation TGModernEmojiViewController

static NSArray *segment_list;


-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

-(void)loadView {
    [super loadView];
    
    _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(5, 42, NSWidth(self.view.frame) - 10, NSHeight(self.view.frame) - 42)];
    [self.view addSubview:_tableView.containerView];
    
    _tableView.tm_delegate = self;
    
    
    self.bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 42)];
    for(int i = 1; i <= 6; i++) {
        BTRButton *button = [self createButtonForIndex:i];//20
        [button setFrameOrigin:NSMakePoint(i * 12 + 30 * (i - 1), 12)];
        [self.bottomView addSubview:button];
    }
    
    [self.view addSubview:self.bottomView];
    
    [self addScrollEvent];

}

-(void)addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showPopovers {
    
    int rowCount = floor(NSWidth(_tableView.frame) / 34.0f);
    
    
    NSArray *segments = @[@"Emoji.Recent",@"Emoji.People",@"Emoji.Nature",@"Emoji.Food",@"Emoji.TravelAndPlaces",@"Emoji.Symbols"];
    
    NSMutableArray *stickyItems = [NSMutableArray array];
    
    [segment_list enumerateObjectsUsingBlock:^(NSArray *list, NSUInteger idx, BOOL * _Nonnull stop) {
        
         NSMutableArray *items = [NSMutableArray array];
        
        id stickyItem = [[TGModernSegmentItem alloc] initWithObject:NSLocalizedString(segments[idx], nil)];
        [stickyItems addObject:stickyItem];
        [_tableView addItem:stickyItem tableRedraw:NO];
        
        [self.bottomView.subviews[idx] setStickItem:stickyItem];
        
        
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            [items addObject:obj];
            
            if(items.count == rowCount) {
                TGModernEmojiRowItem *item = [[TGModernEmojiRowItem alloc] initWithObject:[items copy]];
                item.controller = self;
                
                [_tableView addItem:item tableRedraw:NO];
                [items removeAllObjects];
            }
            
        }];
        
        if(items.count > 0) {
            TGModernEmojiRowItem *item = [[TGModernEmojiRowItem alloc] initWithObject:[items copy]];
            item.controller = self;

            [_tableView addItem:item tableRedraw:NO];
        }
        
    }];
    
    [self.tableView setStickClass:[TGModernSegmentItem class]];
    
    [self.tableView reloadData];
}

- (void)close {
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}


+(void)initialize {
   
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path;
        
        if(NSAppKitVersionNumber >= 1404)
            path = [[NSBundle mainBundle] pathForResource:@"emoji1404" ofType:@"txt"];
        else if(floor(NSAppKitVersionNumber) >= 1347)
             path = [[NSBundle mainBundle] pathForResource:@"emoji1347" ofType:@"txt"];
        else
             path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"txt"];
        
        NSError *error;
        
        NSString *emoji = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:&error];
        
        NSArray *list = [emoji componentsSeparatedByString:@"\n\n"];
        
        NSMutableArray *separated = [NSMutableArray array];
        
        [list enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [separated addObject:[obj componentsSeparatedByString:@" "]];
        }];
        
        segment_list = [separated copy];
        
    });
    
}

-(void)saveModifier:(NSString *)modifier forEmoji:(NSString *)emoji {
    
    NSUserDefaults *s = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *modifiers = [s objectForKey:@"emojiModifiers"];
    
    if(!modifiers) {
        modifiers = [[NSMutableDictionary alloc] init];
        
    } else {
        modifiers = [modifiers mutableCopy];
    }
    
    if(modifier) {
        modifiers[emoji] = modifier;
    } else {
        [modifiers removeObjectForKey:emoji];
    }
    
    
    
    [s setObject:modifiers forKey:@"emojiModifiers"];
    
}

-(NSString *)emojiModifier:(NSString *)emoji {
    NSUserDefaults *s = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *modifiers = [s objectForKey:@"emojiModifiers"];
    
    
    return modifiers[emoji];
}

- (void)insertEmoji:(NSString *)emoji {
    if(self.insertEmoji)
        self.insertEmoji(emoji);
}

- (void)saveEmoji:(NSArray *)array {
    
}

- (TGModernEmojiBottomButton *)createButtonForIndex:(int)index {
    
    NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"emojiContainer%d",index]];
    NSImage *imageSelected = [NSImage imageNamed:[NSString stringWithFormat:@"emojiContainer%dHighlighted",index]];
    
    
    TGModernEmojiBottomButton *button = [[TGModernEmojiBottomButton alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [button setBackgroundImage:image forControlState:BTRControlStateNormal];
    [button setBackgroundImage:image forControlState:BTRControlStateHover];
    [button setBackgroundImage:imageSelected forControlState:BTRControlStateHover | BTRControlStateSelected];
    [button setBackgroundImage:imageSelected forControlState:BTRControlStateHighlighted];
    [button setBackgroundImage:imageSelected forControlState:BTRControlStateSelected];
    [button setIndex:index];
    [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:BTRControlEventLeftClick];
    return button;
}

-(void)bottomButtonClick:(TGModernEmojiBottomButton *)button {
    
    __block id currentStick;
    
    __block int currentStickIdx = 0;
    
    [self.tableView.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TGModernSegmentItem class]]) {
            currentStickIdx ++;
            
            if(button.index == currentStickIdx) {
                currentStick = obj;
                *stop = YES;
            }
        }
        
    }];
    
    NSRect rect = [self.tableView rectOfRow:[self.tableView indexOfItem:currentStick]];
    
    [self.tableView.scrollView.clipView scrollRectToVisible:NSMakeRect(0, NSMaxY(rect) + 8, NSWidth(rect), NSHeight(_tableView.containerView.frame)) animated:YES];
    
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    __block id currentStick;
    
    
    if(self.tableView.list.count > 0) {
        NSRange range = [self.tableView rowsInRect:[self.tableView visibleRect]];
        
        if(range.location != NSNotFound) {
            [self.tableView.list enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, range.location + 1)] options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if([obj isKindOfClass:[TGModernSegmentItem class]]) {
                    currentStick = obj;
                    *stop = YES;
                }
                
            }];
            
            
            [self.bottomView.subviews enumerateObjectsUsingBlock:^(TGModernEmojiBottomButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [obj setSelected:obj.stickItem == currentStick];
                
            }];
        }
        
       
    }
    
    
}

-(void)dealloc {
    [self removeScrollEvent];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TGModernEmojiRowItem *) item {
    return item.height;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TGModernEmojiRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TGModernEmojiRowItem *) item {
    return [_tableView cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(_tableView.frame), item.height)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGModernEmojiRowItem *) item {
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TGModernEmojiRowItem *) item {
    return NO;
}
- (BOOL)isSelectable:(NSInteger)row item:(TGModernEmojiRowItem *) item {
    return NO;
}


@end
