//
//  TGMessagesHintView.m
//  Telegram
//
//  Created by keepcoder on 29.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMessagesHintView.h"
#import "TGImageView.h"
#import "SpacemanBlocks.h"
#import "TGContextBotTableView.h"
#import "TGMediaContextTableView.h"
#import "TLBotInlineResult+Extension.h"
#import "TGLocationRequest.h"
#import "TGContextImportantRowView.h"
#import "TGModalMessagesViewController.h"
#import "ComposeActionCustomBehavior.h"
#import "TGContextMessagesvViewController.h"
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

@property (nonatomic,strong) id object;

@property (nonatomic,strong) NSDictionary *emojiHint;
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

-(id)initWithEmojiData:(NSDictionary *)emojiData {
    if(self = [super init]) {
        _emojiHint = emojiData;
        _text = [NSString stringWithFormat:@"%@   %@",emojiData[@"obj"],emojiData[@"key"]];
        _h = rand_long();
        _result = emojiData[@"obj"];
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
    
    [_textField setFrameOrigin:NSMakePoint(xOffset, roundf(NSHeight(self.frame)/2) - (_descField.isHidden ? roundf(NSHeight(_textField.frame)/2) - 2 : -1) )];
    
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




@interface TGMessagesHintView () <TMTableViewDelegate> {
    SMDelayedBlockHandle _handle;
    RPCRequest *_contextRequest;
}
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,copy) void (^choiceHandler)(NSString *result,id object);
@property (nonatomic,strong) TMView *separator;
@property (nonatomic,strong) TGContextBotTableView *contextTableView;

@property (nonatomic,weak) TMTableView *currentTableView;
@property (nonatomic,strong) TGMediaContextTableView *mediaContextTableView;

@property (nonatomic,strong) TGLocationRequest *locationRequest;

@property (nonatomic,strong) TGModalMessagesViewController *messagesModalView;

@property (nonatomic,assign) BOOL isLockedWithRequest;
@property (nonatomic,strong) NSTrackingArea *trackingArea;


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
        
        self.alphaValue = 0.0f;
        
        _tableView = [[TMTableView alloc] initWithFrame:self.bounds];
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        _tableView.tm_delegate = self;
        
        [self addSubview:_tableView.containerView];
        
        _mediaContextTableView = [[TGMediaContextTableView alloc]  initWithFrame:self.bounds];
        
        [self addSubview:_mediaContextTableView.containerView];
        
        _contextTableView = [[TGContextBotTableView alloc]  initWithFrame:self.bounds];
        
        [self addSubview:_contextTableView.containerView];
        
        
        
        
        
        weak();
        
        [_contextTableView setDidSelectedItem:^{
            
            __strong TGMessagesHintView *strongSelf = weakSelf;
            
            if(strongSelf != nil) {
                [strongSelf performSelected];
            }
            
            
        }];
        
        
        self.autoresizingMask = NSViewWidthSizable;
        
        
        
        
        _separator = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - DIALOG_BORDER_WIDTH, NSWidth(frameRect), DIALOG_BORDER_WIDTH)];
        
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        
        _separator.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
        
        [self addSubview:_separator];
        
        
        
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_mediaContextTableView setFrameSize:NSMakeSize(newSize.width, NSHeight(_mediaContextTableView.frame))];
}


-(void)showCommandsHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation botInfo:(NSArray *)botInfo choiceHandler:(void (^)(NSString *result,id object))choiceHandler  {
    
    _choiceHandler = choiceHandler;
    cancel_delayed_block(_handle);
    [_contextRequest cancelRequest];
    
    if(self.messagesViewController.state != MessagesViewControllerStateNone)
        return;
    
    if(conversation.type == DialogTypeSecretChat)
        return;
    
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    
    [botInfo enumerateObjectsUsingBlock:^(TLBotInfo *obj, NSUInteger idx, BOOL *stop) {
        
        TLUser *user = [[UsersManager sharedManager] find:obj.user_id];
        
        [obj.commands enumerateObjectsUsingBlock:^(TL_botCommand *command, NSUInteger idx, BOOL *stop) {
            
            NSString *cmd = command.command;
            
            if((conversation.type == DialogTypeChat || conversation.type == DialogTypeChannel) ) {
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
        item.object = obj;
        
        [items addObject:item];
    }];
    
    [self setCurrentTableView:_tableView];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO];
    else
        [self hide];
    
}

-(void)showHashtagHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation peer_id:(int)peer_id choiceHandler:(void (^)(NSString *result,id object))choiceHandler {
    
    _choiceHandler = choiceHandler;
    cancel_delayed_block(_handle);
    [_contextRequest cancelRequest];
    
    if(self.messagesViewController.state != MessagesViewControllerStateNone)
        return;
    
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
        item.object = obj;
        
        [items addObject:item];
        
    }];
    
    [self setCurrentTableView:_tableView];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO];
    else
        [self hide];
    
}


-(void)showEmojiHintsWithQuery:(NSString *)query conversation:(TL_conversation *)conversation choiceHandler:(void (^)(NSString *result,id object))choiceHandler {
    
    _choiceHandler = choiceHandler;
    cancel_delayed_block(_handle);
    [_contextRequest cancelRequest];
    
    if(self.messagesViewController.state != MessagesViewControllerStateNone)
        return;
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSDictionary *emoji = [NSString emojiReplaceDictionary];

    NSArray *recent = [Storage emoji];
    
    NSMutableDictionary *recentKeys = [NSMutableDictionary dictionary];
    
    [recent enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        recentKeys[obj] = obj;
    }];
        
    if (query.length == 0) {
        // We only show recently used emojis when the query length is 0,
        // aka when the input is only a colon `:`.
        NSMutableArray *recentlyUsed = [NSMutableArray array];
        [emoji enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:recentKeys[obj]]) {
                [recentlyUsed addObject:@{@"key":key, @"obj":obj}];
            }
        }];
        [recentlyUsed sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSUInteger index1 = [recent indexOfObject:obj1[@"obj"]];
            NSUInteger index2 = [recent indexOfObject:obj2[@"obj"]];
            return index1 > index2 ? NSOrderedDescending : index1 < index2 ? NSOrderedAscending : NSOrderedSame;
        }];
        [recentlyUsed enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [items addObject:[[TGMessagesHintRowItem alloc] initWithEmojiData:obj]];
        }];
    } else if (query.length >= 2) {
        // Filter the list of emojis to extract out those that match a query 
        // that is at least 2 characters.
        NSMutableArray *queryMatches = [NSMutableArray array];
        [emoji enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key rangeOfString:[query lowercaseString]].location != NSNotFound) {
                [queryMatches addObject:@{@"key":key, @"obj":obj}];
            } 
        }];
        // Sort emojis that contain the query according to the starting index of the matching query within the emoji.
        [queryMatches sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSUInteger index1 = [obj1[@"key"] rangeOfString:[query lowercaseString]].location;
            NSUInteger index2 = [obj2[@"key"] rangeOfString:[query lowercaseString]].location;
            return index1 > index2 ? NSOrderedDescending : index1 < index2 ? NSOrderedAscending : NSOrderedSame;
        }];
        [queryMatches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [items addObject:[[TGMessagesHintRowItem alloc] initWithEmojiData:obj]];
        }];
    }
    
    [self setCurrentTableView:_tableView];
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO selectNext:NO];
    else
        [self hide];
    
}

-(void)showMentionPopupWithQuery:(NSString *)query conversation:(TL_conversation *)conversation chat:(TLChat *)chat allowInlineBot:(BOOL)allowInlineBot allowUsernameless:(BOOL)allowUsernameless choiceHandler:(void (^)(NSString *result,id object))choiceHandler {
    
    _choiceHandler = choiceHandler;
    cancel_delayed_block(_handle);
    [_contextRequest cancelRequest];
    
    
    if(conversation.type == DialogTypeSecretChat && conversation.encryptedChat.encryptedParams.layer < 45)
        return;
    
    if(self.messagesViewController.state != MessagesViewControllerStateNone && self.messagesViewController.state != MessagesViewControllerStateEditMessage)
        return;
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    
    if(chat) {
        TLChatFull *fullChat = [[ChatFullManager sharedManager] find:chat.n_id];
        
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
        
    }
    
    NSArray *users = chat ? [UsersManager findUsersByMention:query withUids:uids acceptContextBots:NO acceptNonameUsers:allowUsernameless && ( self.messagesViewController.state != MessagesViewControllerStateEditMessage || (self.messagesViewController.editTemplate.editMessage.media == nil || [self.messagesViewController.editTemplate.editMessage.media isKindOfClass:[TL_messageMediaWebPage class]]))] : nil;
    
    
    __block NSMutableArray *botUsers = [[NSMutableArray alloc] init];
    
    if(allowInlineBot && self.messagesViewController.templateType != TGInputMessageTemplateTypeEditMessage) {
        
        __block NSMutableArray *top;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            top = [[transaction objectForKey:@"categories" inCollection:TOP_PEERS] mutableCopy];
            
        }];
        
        
        [top enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger cidx, BOOL * _Nonnull stop) {
            
            if([obj.category isKindOfClass:[TL_topPeerCategoryBotsInline class]]) {
                
                [obj.peers enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger idx, BOOL *stop) {
                    
                    TLUser *user = [[UsersManager sharedManager] find:peer.peer.user_id];
                    
                    if(user && ([[user.username lowercaseString] hasPrefix:[query lowercaseString]] || query.length == 0))
                        [botUsers addObject:user];
                    
                }];
                
                *stop = YES;
            }
            
        }];
        
        
        
        users = [botUsers arrayByAddingObjectsFromArray:users];
        
    }
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    
    [users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
        
        if(conversation.type == DialogTypeSecretChat && !obj.isBotInlinePlaceholder)
            return;
        
        TGMessagesHintRowItem *item = [[TGMessagesHintRowItem alloc] initWithImageObject:obj text:obj.fullName desc:obj.username.length > 0 ? [NSString stringWithFormat:@"@%@",obj.username] : @""];
        
        item.result = obj.username.length > 0 ? obj.username : [NSString stringWithFormat:@"[%@|%d]",obj.first_name,obj.n_id];
        item.object = obj;
        
        [items addObject:item];
    }];
    
    
    [self setCurrentTableView:_tableView];
    
    
    [_tableView removeAllItems:YES];
    
    [_tableView insert:items startIndex:0 tableRedraw:YES];
    
    if(items.count > 0)
        [self show:NO];
    else
        [self hide];
}

-(void)showMentionPopupWithQuery:(NSString *)query conversation:(TL_conversation *)conversation chat:(TLChat *)chat allowInlineBot:(BOOL)allowInlineBot choiceHandler:(void (^)(NSString *result,id object))choiceHandler {
    [self showMentionPopupWithQuery:query conversation:conversation chat:chat allowInlineBot:allowInlineBot allowUsernameless:YES choiceHandler:choiceHandler];
}


static NSMutableDictionary *inlineBotsExceptions;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inlineBotsExceptions = [NSMutableDictionary dictionary];
    });
}

-(void)cancel {
    [_contextRequest cancelRequest];
    cancel_delayed_block(_handle);
}


-(SSignal *)showContextPopupWithQuery:(NSString *)bot query:(NSString *)query conversation:(TL_conversation *)conversation acceptHandler:(void (^)(TLUser *user))acceptHandler  {
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [self cancel];
        
        //|| self.messagesViewController.class == [TGContextMessagesvViewController class]
        
        if(inlineBotsExceptions[bot] || self.messagesViewController.state != MessagesViewControllerStateNone || !conversation.canSendMessage)
            return nil;
        
        
        if(self.messagesViewController.templateType == TGInputMessageTemplateTypeEditMessage || (conversation.type == DialogTypeSecretChat && conversation.encryptedChat.encryptedParams.layer < 45))
            return nil;
        
        __block TLUser *user = [UsersManager findUserByName:bot];
        
        
        
        if(user && (!user.isBot || !user.isBotInlinePlaceholder)) {
            return nil;
        }
        
        if(user.access_hash == 0)
            user = nil;
        
        if(user && acceptHandler)
            acceptHandler(user);
        
        
        
        
        __block NSString *offset = @"";
        
        __block int k = 0;
        
        _choiceHandler = nil;
        
        [_mediaContextTableView clear];
        [_contextTableView removeAllItems:YES];
        [self hide];
        
        cancel_delayed_block(_handle);
        
        
        _handle = perform_block_after_delay(0.4, ^{
            
            __block BOOL forceNextLoad = NO;
            
            __block TL_inputGeoPoint *geo = nil;
            
            dispatch_block_t performQuery = ^{
                
                
                dispatch_block_t block = ^{
                    [_contextRequest cancelRequest];
                    
                    [subscriber putNext:@(offset.length == 0)];
                    
                    
                    _isLockedWithRequest = YES;
                    
                    _contextRequest = [RPCRequest sendRequest:[TLAPI_messages_getInlineBotResults createWithFlags:geo ? (1 << 0) : 0 bot:user.inputUser peer:conversation.inputPeer geo_point:geo query:query offset:offset] successHandler:^(id request, TL_messages_botResults *response) {
                        
                        [subscriber putNext:@(NO)];
                        
                        if(self.messagesViewController.conversation == conversation && request == _contextRequest) {
                            
                            forceNextLoad = offset.length == 0 && response.next_offset.length > 0 && response.results.count <=3;
                            
                            offset = ![offset isEqualToString:response.next_offset] &&  response.next_offset.length > 0 && response.results.count > 0 ? response.next_offset : nil;
                            
                            NSMutableArray *items = [NSMutableArray array];
                            
                            if(!response.isGallery) {
                                
                                if(response.switch_pm != nil && _contextTableView.count == 0) {
                                    TGContextImportantRowItem *important = [[TGContextImportantRowItem alloc] initWithObject:response.switch_pm bot:user];
                                    
                                    [items addObject:important];
                                }
                                
                                [response.results enumerateObjectsUsingBlock:^(TLBotInlineResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    
                                    
                                    TGContextRowItem *item = [[TGContextRowItem alloc] initWithObject:obj bot:user queryId:response.query_id];
                                    
                                    [items addObject:item];
                                    
                                }];
                                
                                [self setCurrentTableView:_contextTableView];
                                
                                if(_contextTableView.count > 0) {
                                    [_contextTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:_contextTableView.count-1] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                                }
                                
                                [_contextTableView insert:items startIndex:_contextTableView.count tableRedraw:YES];
                                
                                [self updateFrames:YES];
                                
                                
                            } else {
                                
                                if(response.switch_pm != nil && _mediaContextTableView.count == 0) {
                                    TGContextImportantRowItem *important = [[TGContextImportantRowItem alloc] initWithObject:response.switch_pm bot:user];
                                    
                                    [items addObject:important];
                                }
                                
                                [response.results enumerateObjectsUsingBlock:^(TLBotInlineResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    [obj setQueryId:response.query_id];
                                    [items addObject:obj];
                                }];
                                
                                [_mediaContextTableView drawResponse:items];
                                
                                [self setCurrentTableView:_mediaContextTableView];
                            }
                            
                            [_mediaContextTableView setMessagesViewController:self.messagesViewController];
                            
                            
                            if(items.count > 0) {
                                if(self.alphaValue == 0.0f)
                                    [self show:NO];
                            } else if(_currentTableView.count == 0)
                                [self hide];
                            
                            
                            
                        } else if(_currentTableView == _mediaContextTableView) {
                            [self hide];
                        }
                        
                        weak();
                        
                        [_mediaContextTableView setChoiceHandler:^(TLBotInlineResult *botResult) {
                            
                            __strong TGMessagesHintView *strongSelf = weakSelf;
                            
                            if(strongSelf != nil) {
                                
                                if([botResult isKindOfClass:[TGContextImportantRowItem class]]) {
                                    [strongSelf performSelected];
                                } else {
                                    [strongSelf.messagesViewController sendContextBotResult:botResult via_bot_id:user.n_id via_bot_name:user.username queryId:botResult.queryId forConversation:conversation];
                                    
                                    [conversation.inputTemplate updateTextAndSave:[[NSAttributedString alloc] init]];
                                    [conversation.inputTemplate performNotification];
                                    
                                }
                                
                            }
                            
                        }];
                        
                        
                        
                        _isLockedWithRequest = NO;
                        k++;
                        
                        if(forceNextLoad && _mediaContextTableView.needLoadNext) {
                            _mediaContextTableView.needLoadNext(YES);
                        }
                        
                    } errorHandler:^(id request, RpcError *error) {
                        _isLockedWithRequest = NO;
                        [subscriber putNext:@(NO)];
                    }];
                };
                
                
                
                if(user.isBot_inline_geo && !geo && !_locationRequest) {
                    
                    weak();
                    
                    [SettingsArchiver requestPermissionWithKey:kPermissionInlineBotLocationRequest peer_id:user.n_id handler:^(bool success) {
                        
                        if(success) {
                            
                            _locationRequest = [[TGLocationRequest alloc] init];
                            
                            [_locationRequest startRequestLocation:^(CLLocation *location) {
                                
                                weakSelf.locationRequest = nil;
                                
                                geo = [TL_inputGeoPoint createWithLat:location.coordinate.latitude n_long:location.coordinate.longitude];
                                
                                block();
                                
                            } failback:^(NSString *error) {
                                alert(appName(), error);
                            }];
                            
                            
                        } else {
                            block();
                        }
                        
                    }];
                } else
                    block();
                
            };
            
            
            
            [_mediaContextTableView setNeedLoadNext:^(BOOL next) {
                if(forceNextLoad || (next && !_isLockedWithRequest && offset.length > 0)) {
                    performQuery();
                }
                
            }];
            
            [_contextTableView setNeedLoadNext:^(BOOL next) {
                if(forceNextLoad || (next && !_isLockedWithRequest && offset.length > 0)) {
                    performQuery();
                }
                
            }];
            
            
            if(!user) {
                [RPCRequest sendRequest:[TLAPI_contacts_resolveUsername createWithUsername:bot] successHandler:^(RPCRequest *request, TL_contacts_resolvedPeer * response) {
                    
                    [SharedManager proccessGlobalResponse:response];
                    
                    if([response.peer isKindOfClass:[TL_peerUser class]]) {
                        user = [response.users firstObject];
                        
                        if(!user.isBot || !user.isBotInlinePlaceholder) {
                            inlineBotsExceptions[user.username] = @(1);
                            return;
                        }
                        
                        performQuery();
                        
                        if(user && acceptHandler)
                            acceptHandler(user);
                        
                    }  else {
                        
                        TLAPI_contacts_resolveUsername *req = request.object;
                        
                        inlineBotsExceptions[req.username] = @(1);
                    }
                    
                    
                    
                } errorHandler:^(id request, RpcError *error) {
                    
                }];
            } else {
                performQuery();
            }
            
        });
        
        return nil;
    }];
    
}

-(void)show:(BOOL)animated selectNext:(BOOL)selectNext {
    if(self.alphaValue == 1.0f && !self.isHidden) {
        [self updateFrames:YES];
        if(selectNext)
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
    if(selectNext)
        [self selectNext];
}

-(void)show:(BOOL)animated {
    [self show:animated selectNext:YES];
}

-(void)updateFrames:(BOOL)animated {
    
    NSUInteger height = MIN(_currentTableView.count * 40, 140 );
    
    if(_currentTableView == _mediaContextTableView) {
        height = MIN(_mediaContextTableView.hintHeight,200);
    } else if(_currentTableView == _contextTableView) {
        height = MIN(_contextTableView.hintHeight, 180 );
    }
    
    if(animated) {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [[self animator] setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
            
            
        } completionHandler:^{
        }];
        
        
    } else {
        [self setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
        [self.tableView.containerView setFrameSize:NSMakeSize(NSWidth(self.frame), NSHeight(self.frame) )];
        [self.contextTableView.containerView setFrameSize:NSMakeSize(NSWidth(self.frame), NSHeight(self.frame))];
        [_separator setFrame:NSMakeRect(0, NSHeight(self.frame) - DIALOG_BORDER_WIDTH, NSWidth(self.frame), DIALOG_BORDER_WIDTH)];
        [self.tableView scrollToBeginningOfDocument:self];
    }
    
    
}

-(BOOL)isVisibleAndHasSelected {
    return !self.isHidden && self.currentTableView.selectedItem != nil;
}


-(void)hide {
    
    [self hide:NO];
    [_tableView removeAllItems:YES];
    [_contextTableView removeAllItems:YES];
    [_mediaContextTableView clear];
    cancel_delayed_block(_handle);
    [_contextRequest cancelRequest];
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
    
    if(_currentTableView == _mediaContextTableView)
        return;
    
    TGContextRowItem *item = (TGContextRowItem *)_currentTableView.selectedItem;
    
    if([item isKindOfClass:[TGContextImportantRowItem class]]) {
        
        TGContextImportantRowItem *importantItem = ( TGContextImportantRowItem *)item;
        
        [_messagesModalView close:YES];
        
        _messagesModalView = [[TGModalMessagesViewController alloc] initWithFrame:self.window.contentView.bounds];
        
        [_messagesModalView show:self.window animated:YES];
        
        ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionCustomBehavior class] filter:nil object:importantItem.bot.dialog];
        
        ComposeActionCustomBehavior *behavior = (ComposeActionCustomBehavior *) action.behavior;
        
        
        [behavior setComposeDone:^{
            //[weakSelf.messagesViewController.bottomView updateText];
        }];
        
        action.reservedObject1 = item.botResult;
        action.reservedObject2 = item.bot;
        action.reservedObject3 =  _messagesViewController.conversation;
        [_messagesModalView setAction:action];
        
        return;
    }
    
    if(_choiceHandler != nil)
    {
        TGMessagesHintRowItem *item = (TGMessagesHintRowItem *) _tableView.selectedItem;
        
        if(item != nil) {
            _choiceHandler(item.result,item.object);
        }
    } else if(_currentTableView == _contextTableView) {
        
        [self.messagesViewController sendContextBotResult:item.botResult via_bot_id:item.bot.n_id via_bot_name:item.bot.username queryId:item.queryId forConversation:self.messagesViewController.conversation];
        
        TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:self.messagesViewController.conversation.peer_id];
        
        [template updateTextAndSave:[[NSAttributedString alloc] init]];
 
        
        [template performNotification];
        
     //   [self.messagesViewController.bottomView setInputMessageString:@"" disableAnimations:NO];
        
        
    }
    
    [self hide:YES];
}



-(void)selectNext {
    
    NSUInteger selectedIndex = _currentTableView.selectedItem == nil ? -1 : [_currentTableView indexOfItem:_currentTableView.selectedItem];
    
    selectedIndex++;
    
    if(selectedIndex == _currentTableView.count) {
        selectedIndex = 0;
    }
    
    if(selectedIndex < _currentTableView.count)
    {
        
        id item = [_currentTableView itemAtPosition:selectedIndex];
        [_currentTableView setSelectedObject:item];
        
        if([item isKindOfClass:[TGContextImportantRowItem class]])
        {
            if(_currentTableView.count > 1) {
                [self selectNext];
                return;
            }
            
        }
        
        
        
        [_currentTableView.scrollView.clipView scrollRectToVisible:[_currentTableView rectOfRow:selectedIndex] animated:NO];
    }
    
    
    
}
-(void)selectPrev {
    NSUInteger selectedIndex = _currentTableView.selectedItem == nil ? _currentTableView.count : [_currentTableView indexOfItem:_currentTableView.selectedItem];
    
    selectedIndex--;
    
    if(selectedIndex == -1) {
        selectedIndex =  MAX(_currentTableView.count-1,0);
    }
    
    if(selectedIndex < _currentTableView.count)
    {
        id item = [_currentTableView itemAtPosition:selectedIndex];
        [_currentTableView setSelectedObject:item];
        
        if([item isKindOfClass:[TGContextImportantRowItem class]])
        {
            if(_currentTableView.count > 1) {
                [self selectPrev];
                return;
            }
            
        }
        
        
        
        [_currentTableView.scrollView.clipView scrollRectToVisible:[_currentTableView rectOfRow:selectedIndex] animated:NO];
    }
}

-(void)setCurrentTableView:(TMTableView *)currentTableView {
    
    if(_currentTableView != currentTableView) {
        _currentTableView = currentTableView;
        [_contextTableView.containerView setHidden:_currentTableView != _contextTableView];
        [_tableView.containerView setHidden:_currentTableView != _tableView];
        [_mediaContextTableView.containerView setHidden:_currentTableView != _mediaContextTableView];
    }
    
}


-(void)updateTrackingAreas
{
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    

    
    int opts = (NSTrackingCursorUpdate | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                  options:opts
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}



+(TGHintViewShowType)needShowHint:(NSString *)string selectedRange:(NSRange)selectedRange completeString:(NSString **)completeString searchString:(NSString **)searchString {
    NSRange range;
    
    NSString *search;
    
    
    TGHintViewShowType type = TGHintViewShowTypeNone;
    
    
    NSUInteger originalLength = string.length;
    
    while ((range = [string rangeOfString:@"@"]).location != NSNotFound || (range = [string rangeOfString:@"#"]).location != NSNotFound || (range = [string rangeOfString:@"/"]).location != NSNotFound || (range = [string rangeOfString:@":"]).location != NSNotFound) {
        
        type = [[string substringWithRange:range] isEqualToString:@"@"] ? TGHintViewShowMentionType : ([[string substringWithRange:range] isEqualToString:@"#"] ? TGHintViewShowHashtagType : ([[string substringWithRange:range] isEqualToString:@":"] ? TGHintViewShowEmojiType :TGHintViewShowBotCommandType));
        
        search = [string substringFromIndex:range.location + 1];
        
        NSRange space = [search rangeOfString:@" "];
        
        if(space.location == NSNotFound)
            space = [search rangeOfString:@"\n"];
        
        if(space.location != NSNotFound)
            search = [search substringToIndex:space.location];
        
        
        
        if(search.length > 0) {
            
            if((selectedRange.location - (originalLength - string.length)) == range.location + search.length + 1)
                break;
            else
                search = nil;
        }
        
        string = [string substringFromIndex:range.location +1];
        
    }
    
    
    *completeString = string;
    *searchString = search;
    
    return type;
}


@end
