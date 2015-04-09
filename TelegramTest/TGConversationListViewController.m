//
//  DialogsViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGConversationListViewController.h"
#import "Telegram.h"
#import "DialogsManager.h"
#import "TLPeer+Extensions.h"
#import "Telegram.h"
#import "DialogTableObject.h"
#import "ImageUtils.h"
#import "TMElements.h"
#import "ConversationTableItem.h"
#import "ConversationTableItemView.h"
#import "TGSecretAction.h"
#import "SearchSeparatorItem.h"
#import "SearchSeparatorTableCell.h"
#import "SearchItem.h"
#import "SearchTableCell.h"

#import "ImageCache.h"
#import "DialogsHistoryController.h"

#import "DialogTableView.h"
#import "SearchViewController.h"
#import "TMTaskRequest.h"
#import "SelfDestructionController.h"
#import "TGModernTypingManager.h"
#import "TGPasslock.h"




@interface TGConversationListViewController ()
@property (nonatomic, strong) DialogsHistoryController *historyController;
@property (nonatomic, strong) DialogTableView *tableView;
@property (nonatomic, strong) TL_conversation *selectedConversation;
@end

@implementation TGConversationListViewController

- (void)loadView {
    [super loadView];
    
    
    
    
    
    int topOffset = 48;
    
    self.view.wantsLayer = YES;
    
    
    self.historyController = [DialogsHistoryController sharedController];
    
    self.searchViewController.type = SearchTypeDialogs | SearchTypeMessages | SearchTypeContacts | SearchTypeGlobalUsers;
   
    NSRect tableRect = NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.view.frame) - topOffset);
    
    self.tableView = [[DialogTableView alloc] initWithFrame:tableRect];
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
                
                [ASQueue dispatchOnMainQueue:^{
                    
                    [self initConversations];
                    
                }];
            }];
        }];
        
    }];
    
    [[Storage manager] unreadCount:^(int count) {
        [[MessagesManager sharedManager] setUnread_count:count];
    }];
    
    
    

}


-(void)initConversations {

    
    [[DialogsHistoryController sharedController] next:0 limit:20 callback:^(NSArray *result) {
        
        [[MTNetwork instance] startNetwork];
        
       [[BlockedUsersManager sharedManager] remoteLoad];
        
        if(result.count != 0 || self.historyController.state == DialogsHistoryStateEnd) {
            
            [TMTaskRequest executeAll];
            
            [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{KEY_DIALOGS:result}];
            [Notification perform:APP_RUN object:nil];
            
            [SelfDestructionController initialize];
            [TMTypingManager sharedManager];
            
            [TGModernTypingManager initialize];
            
            [[NewContactsManager sharedManager] fullReload];
            [[FullChatManager sharedManager] loadStored];
            
            [TGSecretAction dequeAllStorageActions];
            
            [self loadhistory:100];
            
            
        } else if(self.historyController.state != DialogsHistoryStateEnd) {
            [self initConversations];
        }
        
    } usersCallback:nil];
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
    [self.historyController drop];
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}

- (void) scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    if(self.historyController.isLoading || self.historyController.state == DialogsHistoryStateEnd || ![self.tableView.scrollView isNeedUpdateBottom])
        return;
    
    static int limit = 30;
    [self loadhistory:limit];
}

-(void)loadhistory:(int)limit  {
    
    int offset = (int) self.tableView.count;
    
    if(self.historyController.state == DialogsHistoryStateNeedRemote) {
         NSArray *filtred = [self.tableView.list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.conversation.peer.class != %@ AND self.conversation.peer.class != %@",[TL_peerSecret class], [TL_peerBroadcast class]]];
        
        offset = (int) filtred.count;
    }
     
    [self.historyController next:offset limit:limit callback:^(NSArray *result) {
        
        [self insertAll:result];
        
        if(self.historyController.state != DialogsHistoryStateEnd) {
            dispatch_after_seconds(0.8, ^{
                [self loadhistory:limit];
            });
        }
        
    } usersCallback:^(NSArray *users) {
        
    }];
}

-(void)insertAll:(NSArray *)all {
    NSMutableArray *dialogs = [[NSMutableArray alloc] init];
    for(TL_conversation *dialog in all) {
        if(!dialog.isAddToList)
            continue;
        
        ConversationTableItem *item = [[ConversationTableItem alloc] initWithConversationItem:dialog];
        [dialogs addObject:item];
    }
    
    NSTableViewAnimationOptions animation = self.tableView.defaultAnimation;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    
    [self.tableView insert:dialogs startIndex:self.tableView.list.count tableRedraw:YES];
    
    self.tableView.defaultAnimation = animation;
    
    
    if([(ConversationTableItem *)self.tableView.selectedItem conversation] != self.selectedConversation) {
        NSUInteger hash = [ConversationTableItem hash:self.selectedConversation];
        if([self.tableView itemByHash:hash]) {
            [self.tableView cancelSelection];
            [self.tableView setSelectedByHash:hash];
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
            self.selectedConversation = conversation;
            NSUInteger hash = [ConversationTableItem hash:self.selectedConversation];
            [self.tableView setSelectedByHash:hash];
        }
    }
}

- (void) notificationDialogRemove:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
  //  DialogTableItem *dialogItem = [[DialogTableItem alloc] initWithDialogItem:dialog];
     id object = [self.tableView itemByHash:[ConversationTableItem hash:dialog]];
    [self.tableView removeItem:object];
}

- (void) notificationDialogsReload:(NSNotification *)notify {
    
    [self.tableView removeAllItems:NO];
    NSArray *current = [[DialogsManager sharedManager] all];
    
    NSMutableArray *dialogs = [[NSMutableArray alloc] init];
    
    [ASQueue dispatchOnStageQueue:^{
        
        for(TL_conversation *dialog in current) {
            if(!dialog.isAddToList)
                continue;
            
            ConversationTableItem *item = [[ConversationTableItem alloc] initWithConversationItem:dialog];
            
            [dialogs addObject:item];
        }
    } synchronous:YES];
    
        
    [self.tableView insert:dialogs startIndex:0 tableRedraw:NO];
    [self.tableView reloadData];
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
    
    ConversationTableItem *object = (ConversationTableItem *) [self.tableView itemByHash:[ConversationTableItem hash:conversation]];
    if(object) {
        [self.tableView moveItemFrom:[self.tableView positionOfItem:object] to:position tableRedraw:YES];
    } else {
        object = [[ConversationTableItem alloc] initWithConversationItem:conversation];
        [self.tableView insert:object atIndex:position tableRedraw:YES];
        if(conversation == [Telegram rightViewController].messagesViewController.conversation)
            [self.tableView setSelectedByHash:object.hash];
    }
    
}

- (CGFloat) rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    if([item isKindOfClass:[SearchSeparatorItem class]]) {
        return 25.0f;
    } else if([item isKindOfClass:[ConversationTableItem class]]) {
        return DIALOG_CELL_HEIGHT;
    }
    return DIALOG_CELL_HEIGHT;
}

- (BOOL) isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (NSView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    
    ConversationTableItemView *view = (ConversationTableItemView *)[self.tableView cacheViewForClass:[ConversationTableItemView class] identifier:@"dialogItem" withSize:NSMakeSize(200, DIALOG_CELL_HEIGHT)];
    
    view.tableView = self.tableView;
    return view;


}

- (BOOL) selectionWillChange:(NSInteger)row item:(ConversationTableItem *) item {
    
    if([[Telegram rightViewController] isModalViewActive]) {
        [[Telegram rightViewController] modalViewSendAction:item.conversation];
        return NO;
    }
    
    
    return ![Telegram rightViewController].navigationViewController.isLocked;
}

- (void) selectionDidChange:(NSInteger)row item:(ConversationTableItem *) item {
    [[Telegram sharedInstance] showMessagesFromDialog:item.conversation sender:self];
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



- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return [item isKindOfClass:[SearchSeparatorItem class]] ? NO : YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [TMTableView setCurrent:self.tableView];
}

@end
