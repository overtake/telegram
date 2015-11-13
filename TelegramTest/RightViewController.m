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
#import "TGPhotoViewer.h"
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
    return [self.navigationViewController.currentController becomeFirstResponder];
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
    
    [self.view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,NSTIFFPboardType, nil]];
    
    [Notification addObserver:self selector:@selector(logout:) name:LOGOUT_EVENT];
    
    NSRect rect = NSMakeRect(0, 0, NSWidth([NSScreen mainScreen].frame), NSHeight([NSScreen mainScreen].frame));
    
    self.messagesViewController = [[MessagesViewController alloc] initWithFrame:self.view.bounds];
    self.userInfoViewController = [[UserInfoViewController alloc] initWithFrame:rect];
    self.chatInfoViewController = [[ChatInfoViewController alloc] initWithFrame:rect];
    self.collectionViewController = [[TMCollectionPageController alloc] initWithFrame:rect];
    self.noDialogsSelectedViewController = [[NotSelectedDialogsViewController alloc] initWithFrame:rect];
    self.broadcastInfoViewController = [[BroadcastInfoViewController alloc] initWithFrame:rect];
    self.channelInfoViewController = [[ChannelInfoViewController alloc] initWithFrame:rect];
    
    
    self.composePickerViewController = [[ComposePickerViewController alloc] initWithFrame:rect];
    self.composeChatCreateViewController = [[ComposeChatCreateViewController alloc] initWithFrame:rect];
    self.composeBroadcastListViewController = [[ComposeBroadcastListViewController alloc] initWithFrame:rect];
    self.privacyViewController = [[PrivacyViewController alloc] initWithFrame:rect];
    
    
    self.encryptedKeyViewController = [[EncryptedKeyViewController alloc] initWithFrame:rect];
    
    
    self.blockedUsersViewController = [[BlockedUsersViewController alloc] initWithFrame:rect];
    
    self.generalSettingsViewController = [[GeneralSettingsViewController alloc] initWithFrame:rect];
    self.settingsSecurityViewController = [[SettingsSecurityViewController alloc] initWithFrame:rect];
    
    self.aboutViewController = [[AboutViewController alloc] initWithFrame:rect];
    self.userNameViewController = [[UserNameViewController alloc] initWithFrame:rect];
    
    self.addContactViewController = [[AddContactViewController alloc] initWithFrame:rect];
    
    self.lastSeenViewController = [[PrivacySettingsViewController alloc] initWithFrame:rect];
    
    self.privacyUserListController = [[PrivacyUserListController alloc] initWithFrame:rect];
    
    
    self.phoneChangeAlertController = [[PhoneChangeAlertController alloc] initWithFrame:rect];
    self.phoneChangeController = [[PhoneChangeController alloc] initWithFrame:rect];
    
    self.phoneChangeConfirmController = [[PhoneChangeConfirmController alloc] initWithFrame:rect];
    
    self.opacityViewController = [[TGOpacityViewController alloc] initWithFrame:rect];
    
    self.passcodeViewController = [[TGPasscodeSettingsViewController alloc] initWithFrame:rect];
    
    
    self.sessionsViewContoller = [[TGSessionsViewController alloc] initWithFrame:rect];
    
    self.passwordMainViewController = [[TGPasswosdMainViewController alloc] initWithFrame:rect];
    
    self.passwordSetViewController = [[TGPasswordSetViewController alloc] initWithFrame:rect];
    
    
    
//    [self.navigationViewController pushViewController:self.messagesViewController animated:NO];
//    
//    
//    [self.navigationViewController.viewControllerStack removeAllObjects];
//    
   
    
    self.navigationViewController.messagesViewController = self.messagesViewController;
    
    [self.navigationViewController.view.window makeFirstResponder:nil];
    
}

//
//-(void)splitViewDidNeedResizeController:(NSRect)rect {
//    [super splitViewDidNeedResizeController:rect];
//    
//    if([self.navigationViewController.currentController isKindOfClass:[LeftViewController class]])
//    {
//        [self.leftViewController splitViewDidNeedResizeController:rect];
//    }
//}


-(TMViewController *)conversationsController {
    return _leftViewController;
}

-(void)didChangedLayout {
    
    [self loadViewIfNeeded];
    
    if(self.navigationViewController.viewControllerStack.count <= 1) {
        
        
        [self.navigationViewController.viewControllerStack removeAllObjects];
        
        
        [self.navigationViewController pushViewController:[self currentEmptyController] animated:NO];
        
       
        
    } else {
        
        [[self currentEmptyController].view removeFromSuperview];
        
                
        [self.navigationViewController.viewControllerStack removeObject:[self oldEmptyController]];
        
        
        [self.navigationViewController.viewControllerStack insertObject:[self currentEmptyController] atIndex:0];
        
        if([self isModalViewActive]) {
            
            
            [self.navigationViewController pushViewController:[Telegram isSingleLayout] ? self.navigationViewController.viewControllerStack[0] : [self.navigationViewController.viewControllerStack lastObject] animated:NO];
        }
        
        
        
    }
    
    [self.modalView setHidden:[Telegram isSingleLayout]];
    
    [_leftViewController didChangedLayout:nil];
    
}

- (void)navigationGoBack {
    if([[TMAudioRecorder sharedInstance] isRecording])
        return;
    
   
    
    [[[Telegram sharedInstance] firstController] closeAllPopovers];
    
    [self.navigationViewController goBackWithAnimation:YES];
    
    
    if([self isModalViewActive]) {
        [self.navigationViewController.viewControllerStack insertObject:[self currentEmptyController] atIndex:0];
    }
    
    [self hideModalView:YES animation:NO];
}



- (void)hideModalView:(BOOL)isHide animation:(BOOL)animated {
    
    if(isHide) {
        
        
        if(self.modalView) {
            
            
            dispatch_block_t block = ^{
                [self.modalView removeFromSuperview];
                [self.navigationViewController.view enableSubViews];
                self.modalView = nil;
                self.modalObject = nil;
                [Notification perform:@"MODALVIEW_VISIBLE_CHANGE" data:nil];
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

        }

       
    } else {
        
        [self.modalView removeFromSuperview];
        [self.leftViewController updateForwardActionView];
      //  [self.navigationViewController.view disableSubViews];
        [self.modalView setFrame:self.view.bounds];
        
        [self.modalView setHidden:[Telegram isSingleLayout]];
        
        [self.view addSubview:self.modalView];
        
        if(animated && ![Telegram isSingleLayout]) {
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
    
    if(!dialog.canSendMessage && self.modalView == [self forwardModalView]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:NSLocalizedString(@"Alert.Error", nil)];
        [alert setInformativeText: NSLocalizedString(@"Conversation.CantForwardMessagesToThisConversation", nil)];
        [alert show];
        return;
    }
    
    if(self.modalView == [self shareContactModalView]) {
        
        
        confirm(NSLocalizedString(@"Alert.Share", nil), [NSString stringWithFormat:NSLocalizedString(@"Alert.ShareTo", nil),(dialog.type == DialogTypeChat) ? dialog.chat.title : (dialog.type == DialogTypeBroadcast) ? dialog.broadcast.title : dialog.user.fullName], ^{
            
            TLUser *modalObject = self.modalObject;
            
            if(modalObject && modalObject.phone) {
                
                [self.navigationViewController showMessagesViewController:dialog];
                
                [self.messagesViewController shareContact:modalObject forConversation:dialog callback:^{
                    
                }];
                
            }
            
        }, ^{
            
        });
        
        
        
        
    } else if(self.modalView == [self shareModalView]) {
        
        
        NSDictionary *obj = self.modalObject;
        
        [appWindow().navigationController showMessagesViewController:dialog];
        
        [appWindow().navigationController.messagesViewController setStringValueToTextField:[NSString stringWithFormat:@"%@\n%@",obj[@"url"],obj[@"text"]]];
        
        [appWindow().navigationController.messagesViewController selectInputTextByText:obj[@"text"]];
        
    } else  {
        
     //   confirm(NSLocalizedString(@"Alert.Forward", nil), [NSString stringWithFormat:NSLocalizedString(@"Alert.ForwardTo", nil),(dialog.type == DialogTypeChat) ? dialog.chat.title : (dialog.type == DialogTypeBroadcast) ? dialog.broadcast.title : dialog.user.fullName], ^{
            
        NSMutableArray *messages = [self.messagesViewController selectedMessages];
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        for(MessageTableItem *item in messages)
            [ids addObject:item.message];
        
        [ids sortUsingComparator:^NSComparisonResult(TLMessage * a, TLMessage * b) {
            return a.n_id > b.n_id ? NSOrderedDescending : NSOrderedAscending;
        }];
        
        [self.messagesViewController cancelSelectionAndScrollToBottom];
        
        
        dialog.last_marked_date = [[MTNetwork instance] getTime]+1;
        dialog.last_marked_message = dialog.top_message;
        
        [dialog save];
        
        [self.messagesViewController setFwdMessages:ids forConversation:dialog];
        

        [self hideModalView:YES animation:YES];
        
        [appWindow().navigationController showMessagesViewController:dialog];
        
        
        
        TMViewController *controller = [_leftViewController currentTabController];
        
        if([controller isKindOfClass:[StandartViewController class]]) {
            [(StandartViewController *)controller searchByString:@""];
        }
        
        
    //    },nil);
        
    }
    
    
}


- (void)showShareContactModalView:(TLUser *)user {
    [self hideModalView:YES animation:NO];
    
   
    if([Telegram isSingleLayout]) {
        [self.navigationViewController pushViewController:[self currentEmptyController] animated:YES];
    }
    
    TMModalView *view = [self shareContactModalView];
    
    self.modalView = view;
    self.modalObject = user;
    
    [view removeFromSuperview];
    [view setFrameSize:view.bounds.size];
    [view setHeaderTitle:NSLocalizedString(@"Messages.SharingContact", nil) text:[NSString stringWithFormat:NSLocalizedString(@"Conversation.SelectToShareContact", nil), user.fullName]];
    
    [self hideModalView:NO animation:YES];
    
    
}

- (void)showShareLinkModalView:(NSString *)url text:(NSString *)text {
    [self hideModalView:YES animation:NO];
    
    
    if([Telegram isSingleLayout]) {
        [self.navigationViewController pushViewController:[self currentEmptyController] animated:YES];
    }
    
    TMModalView *view = [self shareModalView];
    
    self.modalView = view;
    
    self.modalObject = @{@"url":url, @"text":text};
    
    [view removeFromSuperview];
    [view setFrameSize:view.bounds.size];
    [view setHeaderTitle:NSLocalizedString(@"Messages.SharingLink", nil) text:url];
    
    [self hideModalView:NO animation:YES];
    
    
}

- (void)showForwardMessagesModalView:(TL_conversation *)dialog messagesCount:(NSUInteger)messagesCount {
    [self hideModalView:YES animation:NO];
    
    TMModalView *view = [self forwardModalView];
    
    self.modalView = view;
    self.modalObject = dialog;
    
    
    if([Telegram isSingleLayout]) {
        [self.navigationViewController pushViewController:[self currentEmptyController] animated:YES];
    }
    
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
    if(dialog.type == DialogTypeChat || dialog.type == DialogTypeChannel) {
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

- (TMModalView *)shareModalView {
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
    
    [self.navigationViewController.viewControllerStack addObject:[self currentEmptyController]];
    
    [self.navigationViewController.viewControllerStack addObject:self.navigationViewController.currentController];
    
    [self navigationGoBack];
    
    
}

- (void)logout:(NSNotification *)notify {
    [self.messagesViewController drop];
}


-(TMViewController *)currentEmptyController {
    return [_mainViewController isSingleLayout] ? [self conversationsController] : self.noDialogsSelectedViewController;
}

-(TMViewController *)oldEmptyController {
    return ![_mainViewController isSingleLayout] ? [self conversationsController] : self.noDialogsSelectedViewController;
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
    
    
    
    [self.navigationViewController pushViewController:self.collectionViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
    [self.collectionViewController setConversation:conversation];
    
    
}

- (void)showBroadcastInfoPage:(TL_broadcast *)broadcast {
    if(self.navigationViewController.currentController == self.chatInfoViewController && self.chatInfoViewController.chat.n_id == broadcast.n_id)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.broadcastInfoViewController setBroadcast:broadcast];
    [self.navigationViewController pushViewController:self.broadcastInfoViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
}

- (void)showComposeWithAction:(ComposeAction *)composeAction {
    
    [self hideModalView:YES animation:NO];
    
    
    [self.composePickerViewController setAction:composeAction];
    
    [self.navigationViewController pushViewController:self.composePickerViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
}

- (void)showComposeCreateChat:(ComposeAction *)composeAction {
    if(self.navigationViewController.currentController == self.composeChatCreateViewController && self.composeChatCreateViewController.action == composeAction)
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeChatCreateViewController setAction:composeAction];
    [self.navigationViewController pushViewController:self.composeChatCreateViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

-(void)showComposeCreateChannel:(ComposeAction *)composeAction {
    if(self.navigationViewController.currentController == self.composeCreateChannelViewController && self.composeCreateChannelViewController.action == composeAction)
        return;
    
    if(!self.composeCreateChannelViewController)
    {
        self.composeCreateChannelViewController = [[ComposeCreateChannelViewController alloc] initWithFrame:self.view.bounds];
    }
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeCreateChannelViewController setAction:composeAction];
    [self.navigationViewController pushViewController:self.composeCreateChannelViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}


-(void)showComposeBroadcastList:(ComposeAction *)composeAction {
    if(self.navigationViewController.currentController == self.composeBroadcastListViewController && self.composeBroadcastListViewController.action == composeAction)
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeBroadcastListViewController setAction:composeAction];
    [self.navigationViewController pushViewController:self.composeBroadcastListViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

- (void)showComposeAddUserToGroup:(ComposeAction *)composeAction {
    if(self.navigationViewController.currentController == self.composeChooseGroupViewController && self.composeChooseGroupViewController.action == composeAction)
        return;
    
    if(!_composeChooseGroupViewController) {
        _composeChooseGroupViewController = [[ComposeChooseGroupViewController alloc] initWithFrame:self.view.bounds];
    }
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeChooseGroupViewController setAction:composeAction];
    [self.navigationViewController pushViewController:self.composeChooseGroupViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

- (void)showChatInfoPage:(TLChat *)chat {
    
    
    if([chat isKindOfClass:[TL_channel class]]) {
        [self showChannelInfoPage:chat];
        return;
    }
    
    if(self.navigationViewController.currentController == self.chatInfoViewController && self.chatInfoViewController.chat.n_id == chat.n_id)
        return;
    
    //if(chat.type != TLChatTypeNormal)
    //    return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.chatInfoViewController setChat:chat];
    [self.navigationViewController pushViewController:self.chatInfoViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
}

- (void)showEncryptedKeyWindow:(TL_encryptedChat *)chat {
    if(self.navigationViewController.currentController == self.encryptedKeyViewController)
        return;
    [self hideModalView:YES animation:NO];
    
    [self.encryptedKeyViewController showForChat:chat];
    
    [self.navigationViewController pushViewController:self.encryptedKeyViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
    
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

    [self.navigationViewController pushViewController:self.blockedUsersViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showGeneralSettings {
    if(self.navigationViewController.currentController == self.generalSettingsViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.generalSettingsViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showSecuritySettings {
    if(self.navigationViewController.currentController == self.settingsSecurityViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.settingsSecurityViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showAbout {
    if(self.navigationViewController.currentController == self.aboutViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.aboutViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showUserNameController {
    if(self.navigationViewController.currentController == self.userNameViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    self.userNameViewController.channel = nil;
    self.userNameViewController.completionHandler = nil;
    
    [self.navigationViewController pushViewController:self.userNameViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showUserNameControllerWithChannel:(TL_channel *)channel completionHandler:(dispatch_block_t)completionHandler {
    if(self.navigationViewController.currentController == self.userNameViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    self.userNameViewController.channel = channel;
    self.userNameViewController.completionHandler = completionHandler;
    
    [self.navigationViewController pushViewController:self.userNameViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

-(void)showAddContactController {
    if(self.navigationViewController.currentController == self.addContactViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.addContactViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showPrivacyController {
    if(self.navigationViewController.currentController == self.privacyViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    [self.navigationViewController pushViewController:self.privacyViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

- (void)showLastSeenController {
    if(self.navigationViewController.currentController == self.lastSeenViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
     [self.lastSeenViewController setPrivacy:[PrivacyArchiver privacyForType:kStatusTimestamp]];
    
    [self.navigationViewController pushViewController:self.lastSeenViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
   
    
}

-(void)showPrivacyUserListController:(PrivacyArchiver *)privacy arrayKey:(NSString *)arrayKey addCallback:(dispatch_block_t)addCallback title:(NSString *)title  {
    if(self.navigationViewController.currentController == self.privacyUserListController)
        return;
    
    [self hideModalView:YES animation:NO];
    

    self.privacyUserListController.privacy = privacy;
    self.privacyUserListController.arrayKey = arrayKey;
    self.privacyUserListController.addCallback = addCallback;
    self.privacyUserListController.title = title;
    
    
    [self.navigationViewController pushViewController:self.privacyUserListController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
}

- (void)showPhoneChangeAlerController {
    if(self.navigationViewController.currentController == self.phoneChangeAlertController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.phoneChangeAlertController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
}

- (void)showPhoneChangeController {
    if(self.navigationViewController.currentController == self.phoneChangeController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.phoneChangeController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

- (void)showPhoneChangeConfirmController:(TL_account_sentChangePhoneCode *)params phone:(NSString *)phone {
    if(self.navigationViewController.currentController == self.phoneChangeConfirmController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    [self.phoneChangeConfirmController setChangeParams:params phone:phone];
    
    
    [self.navigationViewController pushViewController:self.phoneChangeConfirmController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
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
        [self.navigationViewController pushViewController:[self currentEmptyController] animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    }
}


-(void)showPasscodeController {
    if(self.navigationViewController.currentController == self.passcodeViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.passcodeViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

-(void)showSessionsController {
    if(self.navigationViewController.currentController == self.sessionsViewContoller)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.sessionsViewContoller animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

-(void)showPasswordMainController {
    if(self.navigationViewController.currentController == self.passwordMainViewController)
        return;
    
    [self hideModalView:YES animation:NO];
    
    
    [self.navigationViewController pushViewController:self.passwordMainViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
    [self.passwordMainViewController reload];
    
    
}

-(void)showSetPasswordWithAction:(TGSetPasswordAction *)action {
    
    [self hideModalView:YES animation:NO];
    
    TGPasswordSetViewController *controller = [[TGPasswordSetViewController alloc] initWithFrame:self.view.bounds];
    
    [controller setAction:action];
    
    action.controller = controller;
    
    
    [self.navigationViewController pushViewController:controller animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

-(void)showEmailPasswordWithAction:(TGSetPasswordAction *)action {
    [self hideModalView:YES animation:NO];
    
    TGPasswordEmailViewController *controller = [[TGPasswordEmailViewController alloc] initWithFrame:self.view.bounds];
    
    [controller setAction:action];
    
    action.controller = controller;
    
    [self.navigationViewController pushViewController:controller animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}


-(void)clearStack {
    [self.navigationViewController.viewControllerStack removeAllObjects];
    
    [self.navigationViewController.viewControllerStack addObject:[self currentEmptyController]];
}

-(void)showChatExportLinkController:(TLChatFull *)chat {
    if(self.navigationViewController.currentController == _chatExportLinkViewController)
        return;
    
    if(!_chatExportLinkViewController) {
        _chatExportLinkViewController = [[ChatExportLinkViewController alloc] initWithFrame:self.view.bounds];
    }

    
    [_chatExportLinkViewController setChat:chat];
    
    [self.navigationViewController pushViewController:_chatExportLinkViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
    
}


-(void)showStickerSettingsController {
    if(self.navigationViewController.currentController == _stickersSettingsViewController)
        return;
    
    if(!_stickersSettingsViewController) {
        _stickersSettingsViewController = [[TGStickersSettingsViewController alloc] initWithFrame:self.view.bounds];
    }
    
    [self.navigationViewController pushViewController:_stickersSettingsViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

-(void)showCacheSettingsViewController {
    if(self.navigationViewController.currentController == _cacheSettingsViewController)
        return;
    
    if(!_cacheSettingsViewController) {
        _cacheSettingsViewController = [[CacheSettingsViewController alloc] initWithFrame:self.view.bounds];
    }
    
    [self.navigationViewController pushViewController:_cacheSettingsViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}


-(void)showNotificationSettingsViewController {
    if(self.navigationViewController.currentController == _notificationSettingsViewController)
        return;
    
    if(!_notificationSettingsViewController) {
        _notificationSettingsViewController = [[NotificationSettingsViewController alloc] initWithFrame:self.view.bounds];
    }
    
    [self.navigationViewController pushViewController:_notificationSettingsViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}


-(void)showChannelInfoPage:(TLChat *)chat {
    if((self.navigationViewController.currentController == self.channelInfoViewController && self.channelInfoViewController.chat.n_id == chat.n_id) || chat.type == TLChatTypeForbidden )
        return;
    
    
    [self hideModalView:YES animation:NO];
    
    [self.channelInfoViewController setChat:chat];
    
    [self.navigationViewController pushViewController:self.channelInfoViewController animated:self.navigationViewController.currentController != self.noDialogsSelectedViewController];
}

-(void)showComposeChangeUserName:(ComposeAction *)action {
    if(self.navigationViewController.currentController == self.composeCreateChannelUserNameStepViewController && self.composeCreateChannelUserNameStepViewController.action == action)
        return;
    
    if(_composeCreateChannelUserNameStepViewController == nil) {
        _composeCreateChannelUserNameStepViewController = [[ComposeCreateChannelUserNameStepViewController alloc] initWithFrame:self.view.bounds];
    }
    
    
    [self hideModalView:YES animation:NO];
    
    [self.composeCreateChannelUserNameStepViewController setAction:action];
    [self.navigationViewController pushViewController:self.composeCreateChannelUserNameStepViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

-(void)showComposeAddModerator:(ComposeAction *)action {
    if(self.navigationViewController.currentController == self.composeConfirmModeratorViewController && self.composeConfirmModeratorViewController.action == action)
        return;
    
    if(_composeConfirmModeratorViewController == nil) {
        _composeConfirmModeratorViewController = [[ComposeConfirmModeratorViewController alloc] initWithFrame:self.view.bounds];
    }
    
    
    [self hideModalView:YES animation:NO];
    
    [_composeConfirmModeratorViewController setAction:action];
    [self.navigationViewController pushViewController:_composeConfirmModeratorViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}

-(void)showComposeManagment:(ComposeAction *)action {
    if(self.navigationViewController.currentController == self.composeManagmentViewController && self.composeManagmentViewController.action == action)
        return;
    
    if(_composeManagmentViewController == nil) {
        _composeManagmentViewController = [[ComposeManagmentViewController alloc] initWithFrame:self.view.bounds];
    }
    
    
    [self hideModalView:YES animation:NO];
    
    [_composeManagmentViewController setAction:action];
    [self.navigationViewController pushViewController:_composeManagmentViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

-(void)showComposeChannelParticipants:(ComposeAction *)action {
    if(self.navigationViewController.currentController == _composeChannelParticipantsViewController && _composeChannelParticipantsViewController.action == action)
        return;
    
    if(_composeChannelParticipantsViewController == nil) {
        _composeChannelParticipantsViewController = [[ComposeChannelParticipantsViewController alloc] initWithFrame:self.view.bounds];
    }
    
    
    [self hideModalView:YES animation:NO];
    
    [_composeChannelParticipantsViewController setAction:action];
    [self.navigationViewController pushViewController:_composeChannelParticipantsViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];
}

-(void)showComposeSettingsupNewChannel:(ComposeAction *)action {
    if(self.navigationViewController.currentController == _composeSettingupNewChannelViewController && _composeSettingupNewChannelViewController.action == action)
        return;
    
    if(_composeSettingupNewChannelViewController == nil) {
        _composeSettingupNewChannelViewController = [[ComposeSettingupNewChannelViewController alloc] initWithFrame:self.view.bounds];
    }
    
    [self hideModalView:YES animation:NO];
    
    [_composeSettingupNewChannelViewController setAction:action];
    [self.navigationViewController pushViewController:_composeSettingupNewChannelViewController animated:self.navigationViewController.currentController != [self noDialogsSelectedViewController]];

}


@end
