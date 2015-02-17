//
//  RightViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "RightViewController.h"
#import "MessagesViewController.h"
#import "Telegram.h"
#import "NotSelectedDialogsViewController.h"
#import "NSView-DisableSubsAdditions.h"
#import "NSAlertCategory.h"
#import "MessageTableItem.h"
#import "DraggingControllerView.h"
#import "TMMediaUserPictureController.h"
#import "TMCollectionPageController.h"
#import "TMAudioRecorder.h"
#import "TMProgressModalView.h"
#import "ComposeBroadcastListViewController.h"
#import "ContactsViewController.h"

@implementation TMView (Dragging)




-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {

    if([Telegram rightViewController].messagesViewController.conversation && [Telegram rightViewController].navigationViewController.currentController == [Telegram rightViewController].messagesViewController) {
        NSPasteboard *pst = [sender draggingPasteboard];
        
        if(![pst.name isEqualToString:TGImagePType] && ( [[pst types] containsObject:NSFilenamesPboardType] || [[pst types] containsObject:NSTIFFPboardType])) {
            if([[pst types] containsObject:NSFilenamesPboardType]) {
                NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
                

                
                if(files.count == 1 && ![mediaTypes() containsObject:[[files[0] pathExtension] lowercaseString]]) {
                     [DraggingControllerView setType:DraggingTypeSingleChoose];
                } else {
                    [DraggingControllerView setType:DraggingTypeMultiChoose];
                }
            }
            
            
            [self addSubview:[DraggingControllerView view]];
            
        }
    }
    
    
    return NSDragOperationNone;
}




-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    [MessageSender sendDraggedFiles:sender dialog:[Telegram rightViewController].messagesViewController.conversation asDocument:NO];
    
    return YES;
}

@end

@interface RightViewController ()
@property (nonatomic, strong) NSView *lastView;
@property (nonatomic, strong) NSView *currentView;

@property (nonatomic, strong) TMViewController *noDialogsSelectedViewController;
@property (nonatomic, strong) TMView *modalView;
@property (nonatomic, strong) id modalObject;
 


@end

@implementation RightViewController

- (id)init {
    self = [super init];
    if(self) {

    }
    return self;
}



-(BOOL)becomeFirstResponder {
    [self.messagesViewController becomeFirstResponder];
    return YES;
}
-(BOOL)acceptsFirstResponder {
    return YES;
}

- (void) loadView {
    [super loadView];
    
    
    self.navigationViewController = [[TMNavigationController alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.navigationViewController.view];
    
    [self.view setBackgroundColor:[NSColor whiteColor]];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    
    [self.view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType, nil]];
    
    [Notification addObserver:self selector:@selector(logout:) name:LOGOUT_EVENT];
    
    self.messagesViewController = [[MessagesViewController alloc] initWithFrame:self.view.bounds];
    self.userInfoViewController = [[UserInfoViewController alloc] initWithFrame:self.view.bounds];
    self.chatInfoViewController = [[ChatInfoViewController alloc] initWithFrame:self.view.bounds];
    self.collectionViewController = [[TMCollectionPageController alloc] initWithFrame:self.view.bounds];
    self.noDialogsSelectedViewController = [[NotSelectedDialogsViewController alloc] initWithFrame:self.view.bounds];
    self.broadcastInfoViewController = [[BroadcastInfoViewController alloc] initWithFrame:self.view.bounds];
    
    self.
    
    self.composePickerViewController = [[ComposePickerViewController alloc] initWithFrame:self.view.bounds];
    self.composeChatCreateViewController = [[ComposeChatCreateViewController alloc] initWithFrame:self.view.bounds];
    self.composeBroadcastListViewController = [[ComposeBroadcastListViewController alloc] initWithFrame:self.view.bounds];
    self.privacyViewController = [[PrivacyViewController alloc] initWithFrame:self.view.bounds];
    
    
    self.encryptedKeyViewController = [[EncryptedKeyViewController alloc] initWithFrame:self.view.bounds];
    
    
    self.blockedUsersViewController = [[BlockedUsersViewController alloc] initWithFrame:self.view.bounds];
    
    self.generalSettingsViewController = [[GeneralSettingsViewController alloc] initWithFrame:self.view.bounds];
    self.settingsSecurityViewController = [[SettingsSecurityViewController alloc] initWithFrame:self.view.bounds];
    
    self.aboutViewController = [[AboutViewController alloc] initWithFrame:self.view.bounds];
    self.userNameViewController = [[UserNameViewController alloc] initWithFrame:self.view.bounds];
    
    self.addContactViewController = [[AddContactViewController alloc] initWithFrame:self.view.bounds];
    
    self.lastSeenViewController = [[PrivacySettingsViewController alloc] initWithFrame:self.view.bounds];
    
    self.privacyUserListController = [[PrivacyUserListController alloc] initWithFrame:self.view.bounds];
    
    
    self.phoneChangeAlertController = [[PhoneChangeAlertController alloc] initWithFrame:self.view.bounds];
    self.phoneChangeController = [[PhoneChangeController alloc] initWithFrame:self.view.bounds];
    
    self.phoneChangeConfirmController = [[PhoneChangeConfirmController alloc] initWithFrame:self.view.bounds];
    
    self.opacityViewController = [[TGOpacityViewController alloc] initWithFrame:self.view.bounds];
    
    [self.navigationViewController pushViewController:self.messagesViewController animated:NO];

    [self.navigationViewController pushViewController:self.noDialogsSelectedViewController animated:NO];
    [self.navigationViewController.view.window makeFirstResponder:nil];
    [[Telegram mainViewController] layout];
    
    [Notification addObserver:self selector:@selector(didChangedLayout:) name:LAYOUT_CHANGED];
    
}


-(void)didChangedLayout:(NSNotification *)notification {
    
}

- (void)navigationGoBack {
    if([[TMAudioRecorder sharedInstance] isRecording])
        return;
    
    [self hideModalView:YES animation:NO];
    
    [[[Telegram sharedInstance] firstController] closeAllPopovers];
       
    
    [self.navigationViewController goBackWithAnimation:YES];
}



- (void)hideModalView:(BOOL)isHide animation:(BOOL)animated {
    
    if(isHide) {
        dispatch_block_t block = ^{
            [self.modalView removeFromSuperview];
            [self.navigationViewController.view enableSubViews];
            self.modalView = nil;
            self.modalObject = nil;
            [Notification perform:@"MODALVIEW_VISIBLE_CHANGE" data:nil];
            [[Telegram leftViewController] updateForwardActionView];
            
            if([[Telegram mainViewController] isSingleLayout]) {
                [[Telegram mainViewController] checkLayout];
            }
            
        };
        
        if(animated) {
            [CATransaction begin];
            {
                [CATransaction setCompletionBlock:block];
                
                CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
                flash.fromValue = [NSNumber numberWithFloat:0.95];
                flash.toValue = [NSNumber numberWithFloat:0];
                flash.duration = 0.16;
                flash.autoreverses = NO;
                flash.repeatCount = 0;
                [self.modalView.layer removeAllAnimations];
                self.modalView.layer.opacity = 0;
                
                [self.modalView.layer addAnimation:flash forKey:@"flashAnimation"];
            }
            
            [CATransaction commit];
        } else {
            block();
        }
        
       
    } else {
        [self.modalView removeFromSuperview];
        [self.navigationViewController.view disableSubViews];
        [self.modalView setFrame:self.view.bounds];

        [self.view addSubview:self.modalView];
        
        [[Telegram leftViewController] updateForwardActionView];
        
        if([[Telegram mainViewController] isSingleLayout]) {
            [[Telegram mainViewController] checkLayout];
        }
        
        if(animated) {
            CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
            flash.fromValue = [NSNumber numberWithFloat:0.0];
            flash.toValue = [NSNumber numberWithFloat:0.95];
            flash.duration = 0.16;
            flash.autoreverses = NO;
            flash.repeatCount = 0;
            [self.modalView.layer removeAllAnimations];
            self.modalView.layer.opacity = 0.95;
            
            [self.modalView.layer addAnimation:flash forKey:@"flashAnimation"];
            
            [[NSCursor arrowCursor] set];
        }
    }
    
   
}

- (void)modalViewSendAction:(id)object {
    
    TL_conversation *dialog = object;
    if(dialog.type == DialogTypeSecretChat) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:NSLocalizedString(@"Alert.Error", nil)];
        NSString *informativeText;
        if(self.modalView == [self shareContactModalView]) {
            informativeText = NSLocalizedString(@"Conversation.CantShareContactToSecretChat", nil);
        } else {
            informativeText = NSLocalizedString(@"Conversation.CantForwardSecretMessages", nil);
        }
        [alert setInformativeText:informativeText];
        [alert show];
        return;
    }
    
    if(dialog.type == DialogTypeBroadcast && self.modalView == [self forwardModalView]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:NSLocalizedString(@"Alert.Error", nil)];
        [alert setInformativeText: NSLocalizedString(@"Conversation.CantForwardToBroadcast", nil)];
        [alert show];
        return;
    }
    
    if(self.modalView == [self shareContactModalView]) {
        TLUser *modalObject = self.modalObject;
        
        if(modalObject && modalObject.phone) {
            
            [self.messagesViewController shareContact:modalObject conversation:dialog callback:^{
                [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:self];
            }];
            
           
            //[MessageSender shareContact:media dialog:dialog];
        }
        
        
    } else {
        
        confirm(NSLocalizedString(@"Alert.Forward", nil), [NSString stringWithFormat:NSLocalizedString(@"Alert.ForwardTo", nil),(dialog.type == DialogTypeChat) ? dialog.chat.title : (dialog.type == DialogTypeBroadcast) ? dialog.broadcast.title : dialog.user.fullName], ^{
            
            NSMutableArray *messages = [self.messagesViewController selectedMessages];
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            for(MessageTableItem *item in messages)
                [ids addObject:item.message];
            
            [ids sortUsingComparator:^NSComparisonResult(TLMessage * a, TLMessage * b) {
                return a.n_id > b.n_id ? NSOrderedDescending : NSOrderedAscending;
            }];
            
            [self.messagesViewController cancelSelectionAndScrollToBottom];
            weakify();
            
            
            
            dialog.last_marked_date = [[MTNetwork instance] getTime]+1;
            dialog.last_marked_message = dialog.top_message;
            
            [dialog save];
            
            self.messagesViewController.didUpdatedTable = ^ {
                
                strongSelf.messagesViewController.didUpdatedTable = nil;
                
                [strongSelf.messagesViewController forwardMessages:ids conversation:dialog callback:^{
                    
                    
                }];
            };
            
            if(self.messagesViewController.conversation == dialog) {
                self.messagesViewController.didUpdatedTable();
            }
            [self hideModalView:YES animation:YES];
            
            [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:self];
            
            
            TMViewController *controller = [[Telegram leftViewController] currentTabController];
            
            if([controller isKindOfClass:[StandartViewController class]]) {
                [(StandartViewController *)controller searchByString:@""];
            }
            
            
        },nil);
        
    }
    
    
}


- (void)showShareContactModalView:(TLUser *)user {
    [self hideModalView:YES animation:NO];
    
   
    
    
    TMModalView *view = [self shareContactModalView];
    
    self.modalView = view;
    self.modalObject = user;
    
    [view removeFromSuperview];
    [view setFrameSize:view.bounds.size];
    [view setHeaderTitle:NSLocalizedString(@"Messages.SharingContact", nil) text:[NSString stringWithFormat:NSLocalizedString(@"Conversation.SelectToShareContact", nil), user.fullName]];
    
    [self hideModalView:NO animation:YES];
    
    
}

- (void)showForwardMessagesModalView:(TL_conversation *)dialog messagesCount:(NSUInteger)messagesCount {
    [self hideModalView:YES animation:NO];
    
    
    
    TMModalView *view = [self forwardModalView];
    
    self.modalView = view;
    self.modalObject = dialog;
    
    [view removeFromSuperview];
    [view setFrameSize:view.bounds.size];
    
    NSString *messageOrMessages = messagesCount == 1 ? NSLocalizedString(@"message", nil) : NSLocalizedString(@"messages", nil);
    
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Message.Action.Forwarding", nil)];
    if(messagesCount == 1) {
        title = [NSString stringWithFormat:@"%@ %@", title, messageOrMessages];
    } else {
        title = [NSString stringWithFormat:@"%@ %lu %@", title, (unsigned long)messagesCount, messageOrMessages];
    }
    
    NSString *name;
    if(dialog.type == DialogTypeChat) {
        name = dialog.chat.title;
    } else if(dialog.type == DialogTypeSecretChat) {
        name = dialog.encryptedChat.peerUser.fullName;
    } else {
        name = dialog.user.fullName;
    }
    
    [view setHeaderTitle:title text:[NSString stringWithFormat:NSLocalizedString(messagesCount == 1 ?  @"Conversation.SelectToForward" : @"Conversation.SelectToForwards", nil), name]];
    
    
    
    [self hideModalView:NO animation:YES];
    
}

- (TMModalView *)forwardModalView {
    static TMModalView *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[TMModalView alloc] initWithFrame:self.view.bounds];
    });
    return view;
}


- (TMModalView *)shareContactModalView {
    static TMModalView *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[TMModalView alloc] initWithFrame:self.view.bounds];
    });
    return view;
}



- (void)dealloc {
    [Notification removeObserver:self];
}

- (void)showNotSelectedDialog {
    [self.navigationViewController.viewControllerStack removeAllObjects];
    [self.navigationViewController pushViewController:self.noDialogsSelectedViewController animated:YES];
}

- (void)logout:(NSNotification *)notify {
    [self.messagesViewController drop];
}

- (void)showByDialog:(TL_conversation *)dialog sender:(id)sender {
    [self showByDialog:dialog withJump:0 historyFilter:[HistoryFilter class] sender:sender];
}


- (BOOL)showByDialog:(TL_conversation *)dialog withJump:(int)messageId historyFilter:(Class )filter sender:(id)sender  {

    
    [self hideModalView:YES animation:NO];
    
    if(self.messagesViewController.conversation == dialog && self.navigationViewController.currentController != self.messagesViewController) {
      
        [self.messagesViewController setCurrentConversation:dialog withJump:messageId historyFilter:filter];
        
        [self.navigationViewController.viewControllerStack removeAllObjects];
        [self.navigationViewController.viewControllerStack addObject:self.noDialogsSelectedViewController];
        [self.navigationViewController.viewControllerStack addObject:self.messagesViewController];
        [self.navigationViewController.viewControllerStack addObject:self.navigationViewController.currentController];
        [self.navigationViewController goBackWithAnimation:YES];
    } else {
        
        
        [self.messagesViewController setCurrentConversation:dialog withJump:messageId historyFilter:filter];
        
        [self.navigationViewController.viewControllerStack removeAllObjects];
        [self.navigationViewController.viewControllerStack addObject:self.noDialogsSelectedViewController];
        
        [self.navigationViewController pushViewController:self.messagesViewController animated:![sender isKindOfClass:[TGConversationListViewController class]] && ![sender isKindOfClass:[SearchViewController class]]  && ![sender isKindOfClass:[ContactsViewController class]] && ![sender isKindOfClass:[RightViewController class]]];
    }

    return YES;
}

- (void)showUserInfoPage:(TLUser *)user conversation:(TL_conversation *)conversation {
    if(self.navigationViewController.currentController == self.userInfoViewController && self.userInfoViewController.user.n_id == user.n_id)
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.userInfoViewController setUser:user conversation:conversation];
    
    [self.navigationViewController pushViewController:self.userInfoViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
}



- (void)showUserInfoPage:(TLUser *)user  {
    [self showUserInfoPage:user conversation:user.dialog];
}

- (void)showCollectionPage:(TL_conversation *)conversation {
    if(self.navigationViewController.currentController == self.collectionViewController && self.collectionViewController.conversation.peer.peer_id == conversation.peer.peer_id)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    
    [self.navigationViewController pushViewController:self.collectionViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
    [self.collectionViewController setConversation:conversation];
    
    
}

- (void)showBroadcastInfoPage:(TL_broadcast *)broadcast {
    if(self.navigationViewController.currentController == self.chatInfoViewController && self.chatInfoViewController.chat.n_id == broadcast.n_id)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.broadcastInfoViewController setBroadcast:broadcast];
    [self.navigationViewController pushViewController:self.broadcastInfoViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
}

- (void)showComposeWithAction:(ComposeAction *)composeAction {
    
    [self hideModalView:YES animation:NO];
    
    
    [self.composePickerViewController setAction:composeAction];
    
    [self.navigationViewController pushViewController:self.composePickerViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
}

- (void)showComposeCreateChat:(ComposeAction *)composeAction {
    if(self.navigationViewController.currentController == self.composeChatCreateViewController && self.composeChatCreateViewController.action == composeAction)
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeChatCreateViewController setAction:composeAction];
    [self.navigationViewController pushViewController:self.composeChatCreateViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}


-(void)showComposeBroadcastList:(ComposeAction *)composeAction {
    if(self.navigationViewController.currentController == self.composeBroadcastListViewController && self.composeBroadcastListViewController.action == composeAction)
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeBroadcastListViewController setAction:composeAction];
    [self.navigationViewController pushViewController:self.composeBroadcastListViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];

}

- (void)showChatInfoPage:(TLChat *)chat {
    if(self.navigationViewController.currentController == self.chatInfoViewController && self.chatInfoViewController.chat.n_id == chat.n_id)
        return;
    
    if(chat.type != TLChatTypeNormal)
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.chatInfoViewController setChat:chat];
    [self.navigationViewController pushViewController:self.chatInfoViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
}

- (void)showEncryptedKeyWindow:(TL_encryptedChat *)chat {
    if(self.navigationViewController.currentController == self.encryptedKeyViewController)
        return;
    [self hideModalView:YES animation:NO];
    
    [self.encryptedKeyViewController showForChat:chat];
    
    [self.navigationViewController pushViewController:self.encryptedKeyViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
    
}

- (BOOL)isActiveDialog {
    return self.navigationViewController.currentController == self.messagesViewController;
}

- (BOOL)isModalViewActive {
    return self.modalView != nil;
}

- (void)showBlockedUsers {
    if(self.navigationViewController.currentController == self.blockedUsersViewController)
        return;
    
    [self hideModalView:YES animation:NO];

    [self.navigationViewController pushViewController:self.blockedUsersViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showGeneralSettings {
    if(self.navigationViewController.currentController == self.generalSettingsViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.generalSettingsViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showSecuritySettings {
    if(self.navigationViewController.currentController == self.settingsSecurityViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.settingsSecurityViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showAbout {
    if(self.navigationViewController.currentController == self.aboutViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.aboutViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showUserNameController {
    if(self.navigationViewController.currentController == self.userNameViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.userNameViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

-(void)showAddContactController {
    if(self.navigationViewController.currentController == self.addContactViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.addContactViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showPrivacyController {
    if(self.navigationViewController.currentController == self.privacyViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    [self.navigationViewController pushViewController:self.privacyViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];

}

- (void)showLastSeenController {
    if(self.navigationViewController.currentController == self.lastSeenViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
     [self.lastSeenViewController setPrivacy:[PrivacyArchiver privacyForType:kStatusTimestamp]];
    
    [self.navigationViewController pushViewController:self.lastSeenViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
   
    
}

-(void)showPrivacyUserListController:(PrivacyArchiver *)privacy arrayKey:(NSString *)arrayKey addCallback:(dispatch_block_t)addCallback title:(NSString *)title  {
    if(self.navigationViewController.currentController == self.privacyUserListController)
        return;
    
    [self hideModalView:YES animation:NO];
    

    self.privacyUserListController.privacy = privacy;
    self.privacyUserListController.arrayKey = arrayKey;
    self.privacyUserListController.addCallback = addCallback;
    self.privacyUserListController.title = title;
    
    
    [self.navigationViewController pushViewController:self.privacyUserListController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
}

- (void)showPhoneChangeAlerController {
    if(self.navigationViewController.currentController == self.phoneChangeAlertController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.phoneChangeAlertController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    
}

- (void)showPhoneChangeController {
    if(self.navigationViewController.currentController == self.phoneChangeController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.phoneChangeController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showPhoneChangeConfirmController:(TL_account_sentChangePhoneCode *)params phone:(NSString *)phone {
    if(self.navigationViewController.currentController == self.phoneChangeConfirmController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    [self.phoneChangeConfirmController setChangeParams:params phone:phone];
    
    
    [self.navigationViewController pushViewController:self.phoneChangeConfirmController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

- (void)showAboveController:(TMViewController *)lastController {
    NSUInteger idx = [self.navigationViewController.viewControllerStack indexOfObject:lastController];
    
     [self hideModalView:YES animation:NO];
    
    if(idx != NSNotFound && idx != 0) {
        
        TMViewController *above = self.navigationViewController.viewControllerStack[idx-1];
        
        [self.navigationViewController.viewControllerStack removeObjectsInRange:NSMakeRange(idx, self.navigationViewController.viewControllerStack.count - idx)];
       
        [self.navigationViewController pushViewController:above animated:YES];
        
    } else {
        [self.navigationViewController.viewControllerStack removeAllObjects];
        [self.navigationViewController pushViewController:self.noDialogsSelectedViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
    }
}

@end
