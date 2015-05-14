//
//  DialogsViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGConversationsViewController.h"
#import "TGSecretAction.h"
#import "DialogsHistoryController.h"
#import "SearchViewController.h"
#import "SelfDestructionController.h"
#import "TGModernTypingManager.h"
#import "TGPasslock.h"
#import "SecretChatAccepter.h"
#import "TMTaskRequest.h"
#import "EmojiViewController.h"
#import "TGConversationTableCell.h"
#import "TGConversationsTableView.h"
@interface TGConversationsViewController ()<NSTableViewDataSource,NSTableViewDelegate,TMTableViewDelegate>
@property (nonatomic, strong) DialogsHistoryController *history;
@property (nonatomic, strong) TGConversationsTableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation TGConversationsViewController

- (void)loadView {
    [super loadView];
    
    
    _list = [[NSMutableArray alloc] init];
    
    
    int topOffset = 48;
    
 //   self.view.wantsLayer = NO;
    
    
    _history = [DialogsHistoryController sharedController];
    
    self.searchViewController.type = SearchTypeDialogs | SearchTypeMessages | SearchTypeContacts | SearchTypeGlobalUsers;
    
    NSRect tableRect = NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.view.frame) - topOffset);
    
    self.tableView = [[TGConversationsTableView alloc] initWithFrame:tableRect];
    
    self.tableView.tm_delegate = self;
    [self.view addSubview:self.tableView.containerView];
    
    self.mainView = self.tableView.containerView;
    
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [Notification addObserver:self selector:@selector(notificationLogout:) name:LOGOUT_EVENT];
    
    [Notification addObserver:self selector:@selector(notificationDialogsReload:) name:DIALOGS_NEED_FULL_RESORT];
    [Notification addObserver:self selector:@selector(notificationDialogToTop:) name:DIALOG_TO_TOP];
    [Notification addObserver:self selector:@selector(notificationDialogRemove:) name:DIALOG_DELETE];
    [Notification addObserver:self selector:@selector(notificationDialogChangePosition:) name:DIALOG_MOVE_POSITION];
    [Notification addObserver:self selector:@selector(notificationDialogSelectionChanged:) name:@"ChangeDialogSelection"];
    [self addScrollEvent];
    
    
    
    [MTNetwork instance];
    
    if(![TGPasslock isEnabled]) {
        [self initialize];
    }
    
    
}

-(void)initialize {
    
    [[Storage manager] users:^(NSArray *result) {
        
        
        
        [[UsersManager sharedManager] addFromDB:result];
        
        [[BroadcastManager sharedManager] loadBroadcastList:^{
            
            [[Storage manager] loadChats:^(NSArray *chats) {
                [[ChatsManager sharedManager] add:chats];
                
                    [self initConversations];
            }];
        }];
        
    }];
    
    [MessagesManager unreadBadgeCount];
    
    
    
    
}


-(void)initConversations {
    
    [SecretChatAccepter instance];
    
    [[DialogsHistoryController sharedController] next:0 limit:20 callback:^(NSArray *result) {
        
        [EmojiViewController loadStickersIfNeeded];
        
        [[MTNetwork instance] startNetwork];
        
        [[BlockedUsersManager sharedManager] remoteLoad];
        
        if(result.count != 0 || _history.state == DialogsHistoryStateEnd) {
            
            [TMTaskRequest executeAll];
            
            [self insertAll:result];
            
            [Notification perform:APP_RUN object:nil];
            
            [SelfDestructionController initialize];
            
            [TGModernTypingManager initialize];
            
            [[NewContactsManager sharedManager] fullReload];
            [[FullChatManager sharedManager] loadStored];
            
            [TGSecretAction dequeAllStorageActions];
            
            [self loadhistory:100];
            
            
        } else if(_history.state != DialogsHistoryStateEnd) {
            [self initConversations];
        }
        
       
        
    } usersCallback:nil];
    
    
    [MessagesManager updateUnreadBadge];
}

- (void)addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void)removeScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}

- (void)searchFieldDidEnter {
    
}

-(void)notificationLogout:(NSNotification *)notification {
    [_history drop];
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}

- (void) scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    if(_history.isLoading || _history.state == DialogsHistoryStateEnd || ![self.tableView.scrollView isNeedUpdateBottom])
        return;
    
    static int limit = 30;
    [self loadhistory:limit];
}

-(void)loadhistory:(int)limit  {
    
    
    
    int offset = (int) self.tableView.count;
    
    if(_history.state == DialogsHistoryStateNeedRemote) {
        NSArray *filtred = [self.tableView.list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.conversation.peer.class != %@ AND self.conversation.peer.class != %@",[TL_peerSecret class], [TL_peerBroadcast class]]];
        
        offset = (int) filtred.count;
    }
    
    [_history next:offset limit:limit callback:^(NSArray *result) {
        
        [self insertAll:result];
        
        if(_history.state != DialogsHistoryStateEnd) {
            dispatch_after_seconds(0.8, ^{
                [self loadhistory:limit];
            });
        }
        
    } usersCallback:^(NSArray *users) {
        
    }];
}

-(void)insertAll:(NSArray *)all {
    NSMutableArray *dialogs = [[NSMutableArray alloc] init];
    
    for(TL_conversation *conversation in all) {
        if(!conversation.isAddToList)
            continue;
        
        TGConversationTableItem *item = [[TGConversationTableItem alloc] initWithConversation:conversation];
        [dialogs addObject:item];
    }
    
    NSTableViewAnimationOptions animation = self.tableView.defaultAnimation;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    
    [self.tableView insert:dialogs startIndex:self.tableView.list.count tableRedraw:YES];
    
    self.tableView.defaultAnimation = animation;
    
    if(self.tableView.selectedItem  != self.selectedItem) {
        
        if([self.tableView itemByHash:[self.selectedItem hash]]) {
            [self.tableView cancelSelection];
            [self.tableView setSelectedByHash:[self.selectedItem hash]];
        }
    }
}
- (void)dealloc {
    [Notification removeObserver:self];
    [self removeScrollEvent];
}

- (void) setHidden:(BOOL)isHidden {
    [super setHidden:isHidden];
    
    if(isHidden) {
        [self.tableView setHidden:YES];
    } else {
        [self.tableView setHidden:NO];
    }
}

//Notifications
- (void)notificationDialogSelectionChanged:(NSNotification *)notify {
    if([notify.userInfo objectForKey:@"sender"] != self) {
        TL_conversation *conversation = [notify.userInfo objectForKey:KEY_DIALOG];
        
        [self.tableView cancelSelection];
        
        if(![conversation isKindOfClass:NSNull.class]) {
            [self.tableView setSelectedByHash:[conversation peer_id]];
        }
    }
}

- (void) notificationDialogRemove:(NSNotification *)notify {
    TL_conversation *conversation = [notify.userInfo objectForKey:KEY_DIALOG];
    id object = [self.tableView itemByHash:[conversation peer_id]];
    [self.tableView removeItem:object];
}

- (void) notificationDialogsReload:(NSNotification *)notify {
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        NSArray *current = [[DialogsManager sharedManager] all];
        
        for(TL_conversation *conversation in current) {
            
            if(!conversation.isAddToList)
                continue;
            
            TGConversationTableItem *item = [[TGConversationTableItem alloc] initWithConversation:conversation];
            
            [items addObject:item];
        }
        
        [ASQueue dispatchOnMainQueue:^{
            
            [self.tableView removeAllItems:NO];
            [self.tableView insert:items startIndex:0 tableRedraw:NO];
            [self.tableView reloadData];
            
        }];
    }];
}

- (void)notificationDialogToTop:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    [self move:0 conversation:dialog];
}

- (void)notificationDialogChangePosition:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    int position = [[notify.userInfo objectForKey:KEY_POSITION] intValue];
    [self move:position conversation:dialog];
}

-(void)move:(int)position conversation:(TL_conversation *)conversation {
    
    if(position == 0 && conversation.top_message > TGMINFAKEID) {
        [self.tableView scrollToBeginningOfDocument:self];
    }
    
    if(position != 0 && position >= self.tableView.count)
        position = (int) self.tableView.count-1;
    
    TGConversationTableItem *object = (TGConversationTableItem *) [self.tableView itemByHash:[conversation peer_id]];
    if(object) {
        [self.tableView moveItemFrom:[self.tableView positionOfItem:object] to:position tableRedraw:YES];
    } else {
        object = [[TGConversationTableItem alloc] initWithConversation:conversation];
        [self.tableView insert:object atIndex:position tableRedraw:YES];
        if(conversation == [Telegram rightViewController].messagesViewController.conversation)
            [self.tableView setSelectedByHash:object.hash];
    }
    
}

- (CGFloat) rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    return 66;
}

- (BOOL) isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (NSView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    
    TGConversationTableCell *view = (TGConversationTableCell *)[self.tableView cacheViewForClass:[TGConversationTableCell class] identifier:@"tgconvcell" withSize:NSMakeSize(NSWidth(self.view.frame), 66)];
    
    return view;
    
    
}

- (BOOL) selectionWillChange:(NSInteger)row item:(TGConversationTableItem *) item {
    
    if([[Telegram rightViewController] isModalViewActive]) {
        [[Telegram rightViewController] modalViewSendAction:item.conversation];
        return NO;
    }
    
    
    return ![Telegram rightViewController].navigationViewController.isLocked;
}

- (void) selectionDidChange:(NSInteger)row item:(TGConversationTableItem *) item {
    [[Telegram sharedInstance] showMessagesFromDialog:item.conversation sender:self];
    
    [self.tableView setSelectedByHash:[item hash]];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
    [self.tableView tableViewSelectionDidChange:notification];
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return YES;
}

-(TGConversationTableItem *)selectedItem {
    return (TGConversationTableItem *)self.tableView.selectedItem;
}

+ (void)showPopupMenuForDialog:(TL_conversation *)dialog withEvent:(NSEvent *)theEvent forView:(NSView *)view {
    NSMenu *menu = [[NSMenu alloc] init];
    
    __block TLUser *user = dialog.type == DialogTypeSecretChat ? dialog.encryptedChat.peerUser : dialog.user;
    __block TLChat *chat = dialog.chat;
    
    NSMenuItem *openConversationMenuItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.OpenConversation", nil) withBlock:^(id sender) {
        [[Telegram rightViewController] showByDialog:dialog sender:self];
    }];
    if([Telegram rightViewController].messagesViewController.conversation == dialog)
        openConversationMenuItem.target = nil;
    
    [menu addItem:openConversationMenuItem];
    
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    if(dialog.type != DialogTypeChat && dialog.type != DialogTypeBroadcast) {
        NSMenuItem *showUserProfile = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Conversation.ShowProfile", nil), user.dialogFullName] withBlock:^(id sender) {
            [[Telegram rightViewController] showUserInfoPage:user conversation:user.dialog];
        }];
        [menu addItem:showUserProfile];
        
        
        BOOL isMuted = dialog.isMute;
        
        NSMenuItem *muteMenuItem = [NSMenuItem menuItemWithTitle:isMuted ? NSLocalizedString(@"Conversation.Unmute", nil) : NSLocalizedString(@"Conversation.Mute", nil) withBlock:^(id sender) {
            [dialog muteOrUnmute:nil until:isMuted ? 0 : 365*24*60*60];
        }];
        if(dialog.type == DialogTypeSecretChat)
            muteMenuItem.target = nil;
        [menu addItem:muteMenuItem];
        
        
        if(user.type == TLUserTypeRequest) {
            [menu addItem:[NSMenuItem separatorItem]];
            __block BOOL isBlocked = [[BlockedUsersManager sharedManager] isBlocked:user.n_id];
            NSMenuItem *blockUser = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:isBlocked ? NSLocalizedString(@"User.UnlockUser", nil) : NSLocalizedString(@"User.BlockUser", nil), user.dialogFullName] withBlock:^(id sender) {
                
                if(isBlocked) {
                    [[BlockedUsersManager sharedManager] unblock:user.n_id completeHandler:nil];
                } else {
                    [[BlockedUsersManager sharedManager] block:user.n_id completeHandler:nil];
                }
            }];
            [menu addItem:blockUser];
            
            NSMenuItem *addToContacts = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"User.AddToContacts", nil) withBlock:^(id sender) {
                [[NewContactsManager sharedManager] importContact:[TL_inputPhoneContact createWithClient_id:0 phone:user.phone first_name:user.first_name last_name:user.last_name] callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
                    
                }];
            }];
            [menu addItem:addToContacts];
        }
        
        if(dialog.type == DialogTypeSecretChat) {
            [menu addItem:[NSMenuItem separatorItem]];
            NSMenuItem *deleteMenuItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.DeleteSecretChat", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:deleteMenuItem];
        }
        
        if(dialog.type == DialogTypeUser) {
            [menu addItem:[NSMenuItem separatorItem]];
            
            NSMenuItem *clearHistory = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Delete", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:clearHistory];
        }
        
    } else {
        
        NSMenuItem *showСhatProfile;
        
        if(dialog.type == DialogTypeChat) {
            showСhatProfile = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.ShowGroupInfo", nil) withBlock:^(id sender) {
                [[Telegram rightViewController] showChatInfoPage:chat];
            }];
            
        } else {
            showСhatProfile = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.ShowBroadcastInfo", nil) withBlock:^(id sender) {
                [[Telegram rightViewController] showBroadcastInfoPage:dialog.broadcast];
            }];
            
        }
        
        if(chat.type != TLChatTypeNormal || chat.left)
            showСhatProfile.target = nil;
        
        [menu addItem:showСhatProfile];
        
        BOOL isMuted = dialog.isMute;
        
        NSMenuItem *muteMenuItem = [NSMenuItem menuItemWithTitle:isMuted ? NSLocalizedString(@"Conversation.Unmute", nil) : NSLocalizedString(@"Conversation.Mute", nil) withBlock:^(id sender) {
            [dialog muteOrUnmute:nil until:isMuted ? 0 : 365*24*60*60];
        }];
        if(dialog.type == DialogTypeSecretChat)
            muteMenuItem.target = nil;
        [menu addItem:muteMenuItem];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        if(dialog.type == DialogTypeChat) {
            
            NSMenuItem *deleteAndExitItem = [NSMenuItem menuItemWithTitle:chat.type == TLChatTypeNormal ? NSLocalizedString(@"Profile.DeleteAndExit", nil) : NSLocalizedString(@"Profile.DeleteConversation", nil)  withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:deleteAndExitItem];
            
            NSMenuItem *leaveFromGroupItem = [NSMenuItem menuItemWithTitle:!dialog.chat.left ? NSLocalizedString(@"Conversation.Actions.LeaveGroup", nil) : NSLocalizedString(@"Conversation.Actions.ReturnToGroup", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController leaveOrReturn:dialog];
            }];
            if(chat.type != TLChatTypeNormal)
                leaveFromGroupItem.target = nil;
            
            [menu addItem:leaveFromGroupItem];
        } else {
            NSMenuItem *deleteBroadcast = [NSMenuItem menuItemWithTitle: NSLocalizedString(@"Profile.DeleteBroadcast", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:deleteBroadcast];
        }
        
        
    }
    
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:view];
}





- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [TMTableView setCurrent:self.tableView];
}

@end
