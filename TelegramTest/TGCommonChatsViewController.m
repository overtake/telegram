//
//  TGCommonChatsViewController.m
//  Telegram
//
//  Created by keepcoder on 04/11/2016.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCommonChatsViewController.h"
#import "TGSettingsTableView.h"
@interface TGCommonChatItem : TMRowItem
@property (nonatomic,strong) TLChat *chat;
@end

@interface TGCommonChatView : TMRowView

@property (nonatomic,strong) TMAvatarImageView *imageView;
@property (nonatomic,strong) TMNameTextField *nameField;
@property (nonatomic,strong) TMView *animatedBackground;

@end


@implementation TGCommonChatItem

-(id)initWithObject:(id)object {
    if (self = [super initWithObject:object]) {
        self.chat = object;
    }
    
    return self;
}

-(Class)viewClass {
    return [TGCommonChatView class];
}

-(int)height {
    return 50;
}

-(NSUInteger)hash {
    return self.chat.n_id;
}

@end


@implementation TGCommonChatView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        
        _animatedBackground = [[TMView alloc] initWithFrame:self.bounds];
        _animatedBackground.backgroundColor = LIGHT_GRAY_BORDER_COLOR;
        [_animatedBackground setHidden:YES];
        [self addSubview:_animatedBackground];
        
        _imageView = [TMAvatarImageView standartNewConversationTableAvatar];
        [self addSubview:_imageView];
        
        _nameField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(70, 33, 0, 0)];
        [_nameField setEditable:NO];
        [_nameField setBordered:NO];
        [_nameField setSelector:@selector(dialogTitle)];
        [_nameField setEncryptedSelector:@selector(dialogTitleEncrypted)];
        [_nameField setDrawsBackground:NO];
        [[_nameField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[_nameField cell] setTruncatesLastVisibleLine:YES];
        [_nameField setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:_nameField];
        
        
    }
    
    return self;
}

-(void)setItem:(TGCommonChatItem *)item selected:(BOOL)isSelected {
    [super setItem:item selected:isSelected];
    [_imageView setChat:item.chat];
    [_nameField setChat:item.chat];
    
    [_imageView setCenteredYByView:self];
    
    
}

-(void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    
    [self.animatedBackground setHidden:NO];
    
    [self.animatedBackground setAlphaValue:0];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        
        [context setDuration:0.1];
        [[_animatedBackground animator] setAlphaValue:1.0];
        
    } completionHandler:^{
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [[_animatedBackground animator] setAlphaValue:0];
            
        } completionHandler:^{
            [[_animatedBackground animator] setAlphaValue:0];
            [_animatedBackground setHidden:YES];
        }];
        
    }];
    
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR setFill];
    NSRectFill(NSMakeRect(70.0, 0, NSWidth(self.frame) - 80, DIALOG_BORDER_WIDTH));
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_nameField setFrameSize:NSMakeSize(newSize.width - 80, 20)];
    [_nameField setCenteredYByView:self];
}

@end

@interface TGCommonChatsViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGCommonChatsViewController


-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"CommonGroups.Header", nil)];
    _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    _tableView.tm_delegate = self;
    [self.view addSubview:_tableView.containerView];
}

-(void)updateWithChats:(NSArray *)chats users:(NSArray *)users {
    [_tableView removeAllItems:true];
    
    NSArray *sorted = [chats sortedArrayUsingComparator:^NSComparisonResult(TLChat *obj1, TLChat *obj2) {
        return obj1.date > obj2.date ? NSOrderedAscending : obj1.date < obj2.date ? NSOrderedDescending : NSOrderedSame;
    }];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [sorted enumerateObjectsUsingBlock:^(TLChat *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:[[TGCommonChatItem alloc] initWithObject:obj]];
    }];
    
    [_tableView insert:items startIndex:1 tableRedraw:true];
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TGCommonChatItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TGCommonChatItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TGCommonChatItem *) item {
    return [_tableView cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(_tableView.frame), [item height])];
}


-(void)dealloc {
    [_tableView clear];
}

-(void)_didStackRemoved {
    [_tableView clear];
}

- (void)selectionDidChange:(NSInteger)row item:(TGCommonChatItem *) item {
    [self.navigationViewController showMessagesViewController:item.chat.dialog];
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGCommonChatItem *) item {
    return true;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGCommonChatItem *) item {
    return true;
}


@end
