//
//  TGMessagesHintView.m
//  Telegram
//
//  Created by keepcoder on 29.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMessagesHintView.h"
#import "TGImageView.h"


@interface TL_botCommand (BotCommandCategory2)

-(void)setUser:(TLUser *)user;
-(TLUser *)user;

@end

@implementation TL_botCommand (BotCommandCategory2)

DYNAMIC_PROPERTY(DUser);

-(void)setUser:(TLUser *)user {
    [self setDUser:user];
}

-(TLUser *)user {
    return [self getDUser];
}

@end

@interface TGMessagesHintRowItem : TMRowItem
@property (nonatomic,strong) id imageObject;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,assign) NSUInteger h;

@property (nonatomic,strong) NSString *result;


@end

@interface TGMessagesHintRowView : TMRowView
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TMAvatarImageView *imageView;
@property (nonatomic,strong) TMTextField *descField;

@end



@implementation TGMessagesHintRowItem

-(id)initWithImageObject:(id)imageObject text:(NSString *)text desc:(NSString *)desc  {
    if(self = [super init]) {
        _imageObject = imageObject;
        _text = text;
        _desc = desc;
        _h = rand_long();
    }
    
    return self;
}

-(NSUInteger)hash {
    return _h;
}

@end


@implementation TGMessagesHintRowView



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [TMTextField defaultTextField];
        _descField = [TMTextField defaultTextField];
        
        [_textField setFont:TGSystemFont(13)];
        [_textField setTextColor:TEXT_COLOR];
        
        
        [_descField setFont:TGSystemFont(12)];
        [_descField setTextColor:GRAY_TEXT_COLOR];
        
        
        [_textField setStringValue:@"test"];
        [_descField setStringValue:@"test"];
        
        [_textField sizeToFit];
        [_descField sizeToFit];
        
        _imageView = [TMAvatarImageView standartHintAvatar];
        [_imageView setFrameOrigin:NSMakePoint(10,5)];
        
        //self.backgroundColor = [NSColor redColor];
        
        [self addSubview:_textField];
        [self addSubview:_descField];
        [self addSubview:_imageView];
        
        
    }
    
    return self;
}

-(void)redrawRow {
    [super redrawRow];
    
    TGMessagesHintRowItem *item = (TGMessagesHintRowItem *)[self rowItem];
    
    int xOffset = item.imageObject == nil ? 10 : 30 + 15;
    
    [_imageView setHidden:item.imageObject == nil];
    
    if([item.imageObject isKindOfClass:[TLUser class]]) {
        [_imageView setUser:item.imageObject];
    } else if([item.imageObject isKindOfClass:[TLChat class]]) {
        [_imageView setChat:item.imageObject];
    }
    
    
    [_descField setHidden:item.desc.length == 0];
    
    
    [_textField setStringValue:item.text];
    
    
    [_descField setStringValue:item.desc];
    
    [_textField setTextColor:self.isSelected ? [NSColor whiteColor] : TEXT_COLOR];
    [_descField setTextColor:self.isSelected ? [NSColor whiteColor] : GRAY_TEXT_COLOR];
    
    [_textField setFrameOrigin:NSMakePoint(xOffset, roundf(NSHeight(self.frame)/2) - (_descField.isHidden ? roundf(NSHeight(_textField.frame)/2) - 3 : -1) )];
    
    [_descField setFrameOrigin:NSMakePoint(xOffset, NSMinY(_textField.frame) - NSHeight(_descField.frame) + 2)];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR set];
    
    TGMessagesHintRowItem *item = (TGMessagesHintRowItem *)[self rowItem];
    
    int xOffset = item.imageObject == nil ? 10 : 30 + 15;
    
   
    
    if(self.isSelected) {
        
        [BLUE_COLOR_SELECT set];
        
         NSRectFill(NSMakeRect(0, 0, NSWidth(dirtyRect) , NSHeight(dirtyRect)));
    } else {
        
        TMTableView *table = item.table;
        
        if([table indexOfItem:item] != table.count - 1) {
            NSRectFill(NSMakeRect(xOffset, 0, NSWidth(dirtyRect) - xOffset, 1));
        }
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textField setFrameSize:NSMakeSize(newSize.width - NSMinX(_textField.frame) - 10, NSHeight(_textField.frame))];
    [_descField setFrameSize:NSMakeSize(newSize.width - NSMinX(_descField.frame) - 10, NSHeight(_descField.frame))];
}

@end




@interface TGMessagesHintView () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,copy) void (^choiceHandler)(NSString *result);
@property (nonatomic,strong) TMView *separator;
@end

@implementation TGMessagesHintView



- (CGFloat)rowHeight:(NSUInteger)row item:(TGMessagesHintRowItem *) item {
    return 40;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TGMessagesHintRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TGMessagesHintRowItem *) item {
    return [_tableView cacheViewForClass:[TGMessagesHintRowView class] identifier:NSStringFromClass([TGMessagesHintRowView class]) withSize:NSMakeSize(NSWidth(self.frame), 40)];
}

- (void)selectionDidChange:(NSInteger)row item:(TGMessagesHintRowItem *) item {
    [self performSelected];
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGMessagesHintRowItem *) item {
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGMessagesHintRowItem *) item {
    return YES;
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), NSHeight(frameRect))];
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        _tableView.tm_delegate = self;
        
        [self addSubview:_tableView.containerView];
        
        
        self.autoresizingMask = NSViewWidthSizable;
        
        
        _separator = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - DIALOG_BORDER_WIDTH, NSWidth(frameRect), DIALOG_BORDER_WIDTH)];
        
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        
         _separator.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
        
        [self addSubview:_separator];
        
    }
    
    return self;
}




-(void)showCommandsHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation botInfo:(NSArray *)botInfo choiceHandler:(void (^)(NSString *result))choiceHandler  {
    
    _choiceHandler = choiceHandler;
    
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    
    [botInfo enumerateObjectsUsingBlock:^(TLBotInfo *obj, NSUInteger idx, BOOL *stop) {
        
        TLUser *user = [[UsersManager sharedManager] find:obj.user_id];
        
        [obj.commands enumerateObjectsUsingBlock:^(TL_botCommand *command, NSUInteger idx, BOOL *stop) {
            
            NSString *cmd = command.command;
            
            if((conversation.type == DialogTypeChat || conversation.type == DialogTypeChannel) && (user.flags & TGUSERFLAGREADHISTORY) != TGUSERFLAGREADHISTORY) {
                cmd = [cmd stringByAppendingString:[NSString stringWithFormat:@"@%@",user.username]];
            }
            
            TL_botCommand *c = [TL_botCommand createWithCommand:cmd n_description:command.n_description];
            [c setUser:user];
            [commands addObject:c];
            
        }];
        
    }];
    
    
    commands = query.length > 0 ? [[commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.command BEGINSWITH[c] %@",query]] mutableCopy] : commands;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    [commands enumerateObjectsUsingBlock:^(TL_botCommand *obj, NSUInteger idx, BOOL *stop) {
        
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:obj.user text:obj.command desc:obj.n_description];
        
        item.result = obj.command;
        
        [items addObject:item];
    }];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO];
    else
        [self hide];
    
}

-(void)showHashtagHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation peer_id:(int)peer_id choiceHandler:(void (^)(NSString *result))choiceHandler {
    
    _choiceHandler = choiceHandler;
    
    __block NSMutableDictionary *tags;
    
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        tags = [[transaction objectForKey:@"htags" inCollection:@"hashtags"] mutableCopy];
        
        NSMutableDictionary *prs = [transaction objectForKey:[NSString stringWithFormat:@"htags_%d",peer_id] inCollection:@"hashtags"];
        
        [tags addEntriesFromDictionary:prs];
        
    }];
    
    
    NSArray *list = [[tags allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return obj1[@"count"] < obj2[@"count"];
        
    }];
    
    
    if(query.length > 0)
    {
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag BEGINSWITH[c] %@",query]];
    }

    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:nil text:[NSString stringWithFormat:@"#%@",obj[@"tag"]]desc:nil];
                                       
        item.result = obj[@"tag"];
        
        [items addObject:item];
        
    }];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO];
    else
        [self hide];
   
}

-(void)showMentionPopupWithQuery:(NSString *)query conversation:(TL_conversation *)conversation chat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler {
   
    _choiceHandler = choiceHandler;
    
    TLChatFull *fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    
    if(fullChat.participants.participants) {
        [fullChat.participants.participants enumerateObjectsUsingBlock:^(TLChatParticipant * obj, NSUInteger idx, BOOL *stop) {
            [uids addObject:@(obj.user_id)];
            
        }];
    } else {
        
        NSArray *contacts = [[NewContactsManager sharedManager] all];
        
        [contacts enumerateObjectsUsingBlock:^(TLContact *obj, NSUInteger idx, BOOL *stop) {
            
            [uids addObject:@(obj.user_id)];
            
        }];
    }
    
    
    
    NSArray *users = [UsersManager findUsersByMention:query withUids:uids];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    NSArray *chats = [ChatsManager findChatsByName:query];
    
    [chats enumerateObjectsUsingBlock:^(TLChat *obj, NSUInteger idx, BOOL *stop) {
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:obj text:obj.title desc:[NSString stringWithFormat:@"@%@",obj.username]];
        
        item.result = obj.username;
        
        [items addObject:item];
    }];
    
    
    [users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:obj text:obj.fullName desc:[NSString stringWithFormat:@"@%@",obj.username]];
        
        item.result = obj.username;
        
        [items addObject:item];
    }];
    
    
    

    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO];
    else
        [self hide];
}

-(void)show:(BOOL)animated {
    if(self.alphaValue == 1.0f && !self.isHidden) {
        [self updateFrames:YES];
        [self selectNext];
        return;
    }
    
    self.hidden = NO;
    
    if(animated) {
        self.alphaValue = 0.f;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [[self animator] setAlphaValue:1.0f];
            
        } completionHandler:^{
            
        }];
    } else {
        self.alphaValue = 1.0f;
    }
    
    [self updateFrames:NO];
    
    [self selectNext];
}

-(void)updateFrames:(BOOL)animated {
    if(animated) {
        
        NSUInteger height = MIN(self.tableView.count * 40, 140 );
        
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [[self animator] setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
            
            
        } completionHandler:^{
        }];
        
        
    } else {
        [self setFrameSize:NSMakeSize(NSWidth(self.frame), MIN(self.tableView.count * 40, 140 ))];
        [self.tableView.containerView setFrameSize:NSMakeSize(NSWidth(self.frame), NSHeight(self.frame) )];
        
        [_separator setFrame:NSMakeRect(0, NSHeight(self.frame) - DIALOG_BORDER_WIDTH, NSWidth(self.frame), DIALOG_BORDER_WIDTH)];
        [self.tableView scrollToBeginningOfDocument:self];
    }
    
    
}

-(void)hide {
        
    [self hide:NO];
}

-(void)hide:(BOOL)animated {
    
    
    if(self.alphaValue == 0.f || self.isHidden)
        return;
    
    if(animated) {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [[self animator] setAlphaValue:0.f];
            
        } completionHandler:^{
            self.hidden = YES;
        }];
    } else {
        self.alphaValue = 0;
        self.hidden = YES;
    }
}

-(void)performSelected {
    if(_choiceHandler != nil)
    {
        TGMessagesHintRowItem *item = (TGMessagesHintRowItem *) _tableView.selectedItem;
        
        if(item != nil) {
            _choiceHandler(item.result);
        }
        
        
    }
}

-(void)selectNext {
    
    NSUInteger selectedIndex = _tableView.selectedItem == nil ? -1 : [_tableView indexOfItem:_tableView.selectedItem];
    
    selectedIndex++;
    
    if(selectedIndex == _tableView.count) {
        selectedIndex = 0;
    }
    
    [_tableView setSelectedObject:[_tableView itemAtPosition:selectedIndex]];
    
    [_tableView.scrollView.clipView scrollRectToVisible:[_tableView rectOfRow:selectedIndex] animated:NO];

    
}
-(void)selectPrev {
    NSUInteger selectedIndex = _tableView.selectedItem == nil ? _tableView.count : [_tableView indexOfItem:_tableView.selectedItem];
    
    selectedIndex--;
    
    if(selectedIndex == -1) {
        selectedIndex = _tableView.count-1;
    }
    
    [_tableView setSelectedObject:[_tableView itemAtPosition:selectedIndex]];
    
    [_tableView.scrollView.clipView scrollRectToVisible:[_tableView rectOfRow:selectedIndex] animated:NO];
}

@end
