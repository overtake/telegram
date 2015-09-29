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
@property (nonatomic,strong) TGImageObject *imageObject;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSString *desc;



@end

@interface TGMessagesHintRowView : TMRowView
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMTextField *descField;
@end



@implementation TGMessagesHintRowItem

-(id)initWithImageObject:(TGImageObject *)imageObject text:(NSString *)text desc:(NSString *)desc {
    if(self = [super init]) {
        _imageObject = imageObject;
        _text = text;
        _desc = desc;
    }
    
    return self;
}

-(NSUInteger)hash {
    return _imageObject != nil ? [_imageObject.location.cacheKey hash] : [_text hash];
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
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(10, 0, 0, 0)];
        
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
    
    int xOffset = item.imageObject == nil ? 10 : item.imageObject.imageSize.width + 20;
    
    [_imageView setHidden:item.imageObject == nil];
    
    _imageView.object = item.imageObject;
    [_imageView setFrameSize:item.imageObject.imageSize];
    
    [_imageView setCenteredYByView:_imageView.superview];
    
    [_descField setHidden:item.desc.length == 0];
    
    
    [_textField setStringValue:item.text];
    [_textField sizeToFit];
    
    
    [_descField setStringValue:item.desc];
    [_descField sizeToFit];
    
    
    [_textField setFrameOrigin:NSMakePoint(xOffset, roundf(NSHeight(self.frame)/2) - (_descField.isHidden ? roundf(NSHeight(_textField.frame)/2) - 3 : 0) )];
    
    [_descField setFrameOrigin:NSMakePoint(xOffset, NSMinY(_textField.frame) - NSHeight(_descField.frame))];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR set];
    
    TGMessagesHintRowItem *item = (TGMessagesHintRowItem *)[self rowItem];
    
    int xOffset = item.imageObject == nil ? 10 : item.imageObject.imageSize.width + 20;
    
    NSRectFill(NSMakeRect(xOffset, 0, NSWidth(dirtyRect) - xOffset, 1));
}

@end



@interface TGMessagesHintView () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGMessagesHintView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(0, NSHeight(dirtyRect) - 1, NSWidth(dirtyRect), 1));
}

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
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGMessagesHintRowItem *) item {
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGMessagesHintRowItem *) item {
    return YES;
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), NSHeight(frameRect) - 1)];
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        _tableView.tm_delegate = self;
        
        [self addSubview:_tableView.containerView];
        
    }
    
    return self;
}




-(void)showCommandsHintsWithQuery:(NSString *)query botInfo:(NSArray *)botInfo choiceHandler:(void (^)(NSString *result))choiceHandler  {
    
    
    
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    
    [botInfo enumerateObjectsUsingBlock:^(TLBotInfo *obj, NSUInteger idx, BOOL *stop) {
        
        TLUser *user = [[UsersManager sharedManager] find:obj.user_id];
        
        [obj.commands enumerateObjectsUsingBlock:^(TL_botCommand *command, NSUInteger idx, BOOL *stop) {
            
            NSString *cmd = command.command;
            
            if([Telegram conversation].type == DialogTypeChat && (user.flags & TGUSERFLAGREADHISTORY) != TGUSERFLAGREADHISTORY) {
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
        
        
        TMAvaImageObject *imageObject = [[TMAvaImageObject alloc] initWithLocation:obj.user.photo.photo_small];
        imageObject.imageSize = NSMakeSize(30, 30);
        
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:imageObject text:obj.command desc:obj.n_description];
        
        [items addObject:item];
    }];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    [self show:YES];
    
}

-(void)showHashtagHintsWithQuery:(NSString *)query peer_id:(int)peer_id choiceHandler:(void (^)(NSString *result))choiceHandler {
    
    
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
        
        [items addObject:[[TGMessagesHintRowItem alloc] initWithImageObject:nil text:[NSString stringWithFormat:@"#%@",obj[@"tag"]] desc:nil]];
        
    }];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    [self show:YES];
   
}

-(void)showMentionPopupWithQuery:(NSString *)query chat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler {
   
    
    
    TLChatFull *fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    
    
    
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    
    if([chat isKindOfClass:[TL_chat class]]) {
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
    
    [users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
        
        TMAvaImageObject *imageObject = [[TMAvaImageObject alloc] initWithLocation:obj.photo.photo_small];
        imageObject.imageSize = NSMakeSize(30, 30);
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:imageObject text:obj.fullName desc:nil];
        
        
        [items addObject:item];
    }];
    
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    [self show:YES];
}

-(void)show:(BOOL)animated {
    if(self.alphaValue == 1.0f && !self.isHidden)
        return;
    
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
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), MIN(self.tableView.count * 40 - 1, 140 - 1))];
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

+(void)selectNext {
    
}
+(void)selectPrev {
    
}

@end
