//
//  NewConversationViewController.m
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NewConversationViewController.h"
#import "NewConversationTableView.h"
#import "NewConversationRowItem.h"
#import "NewConversationRowView.h"
#import "SearchViewController.h"
#import "Telegram.h"
#import "TMImageView.h"
#import "NSString+Extended.h"
#import "TLPeer+Extensions.h"
#import "SelectUsersTableView.h"
#import "AddContactView.h"

@interface NewConversationViewController ()
@property (nonatomic, strong) TMSearchTextField *searchTextField;
@property (nonatomic,strong) SelectUsersTableView *tableView;
@property (nonatomic,strong) SearchViewController *searchViewController;
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TMView *defaultTopView;
@property (nonatomic,strong) TMView *createChatTopView;
@property (nonatomic,strong) TMView *createSecretChatTopView;
@property (nonatomic,strong) TMView *addMembersBottomView;
@property (nonatomic,strong) TMView *broadcastBottomView;

@property (nonatomic,strong) TMView *currentTopView;
@property (nonatomic,strong) TMView *currentBottomView;

@property (nonatomic,strong) TMView *bottomViewForGroupChat;
@property (nonatomic,strong) TMView *prevTopView;


@property (nonatomic,strong) TMView *addContactContainerView;

@property (nonatomic,strong) BTRButton *addMembersButton;
@property (nonatomic,strong) BTRButton *createBroadcastButton;
@property (nonatomic,strong) NSString *chooseMembersTitle;

@property (nonatomic,strong) TMButton *createButton;
@property (nonatomic,strong) NSString *chatTitle;
@property (nonatomic,strong) NSString *lastSearchText;

@property (nonatomic,strong) NSDictionary *actionsOffset;
@property (nonatomic,assign) NSSize normalSize;
@property (nonatomic,assign) NSSize addContactSize;
@end

@implementation NewConversationViewController



-(void)loadView {
    [super loadView];
   
    
    self.normalSize = self.view.frame.size;
    self.addContactSize = NSMakeSize(self.view.frame.size.width, 240);
    
    self.actionsOffset = @{@(0):@(194),@(1):@(160),@(2):@(160),@(3):@(40),@(4):@(240),@(5):@(160)};
    
    
    [self.view setBackgroundColor:[NSColor whiteColor]];
    
    self.createChatTopView = [self topViewForGroupChat:[_actionsOffset[@(NewConversationActionCreateGroup)] intValue]];
    self.createSecretChatTopView = [self topViewForSecretChat:[_actionsOffset[@(NewConversationActionCreateSecretChat)] intValue]];
    self.defaultTopView = [self topViewForDefault:[_actionsOffset[@(NewConversationActionWrite)] intValue]];
    self.bottomViewForGroupChat = [self createBottomViewForGroupChat];
    
    
    self.addContactContainerView = [self createAddContactView:[_actionsOffset[@(NewConversationActionAddContact)] intValue]];
    
    
    self.addMembersBottomView = [self createBottomViewForAddMembers];
    self.broadcastBottomView = [self createBottomViewForBroadcast];
    
    
    if(self.currentAction == NewConversationActionCreateGroup) {
        self.currentTopView = self.createChatTopView;
        self.currentBottomView = self.bottomViewForGroupChat;
    }
    
    if(self.currentAction == NewConversationActionCreateSecretChat) {
        self.currentTopView = self.createSecretChatTopView;
    }
    
    if(self.currentAction == NewConversationActionWrite) {
         self.currentTopView = self.defaultTopView;
    }
   
    if(self.currentAction == NewConversationActionChoosePeople) {
        self.currentBottomView = self.addMembersBottomView;
    }
    
    if(self.currentAction == NewConversationActionAddContact) {
        self.currentTopView = self.addContactContainerView;
    }
    
    

    [self.defaultTopView setHidden:NO];
    [self.createSecretChatTopView setHidden:YES];
    [self.createChatTopView setHidden:YES];
    [self.addContactContainerView setHidden:YES];
    
    
    [self.view addSubview:self.defaultTopView];
    [self.view addSubview:self.createChatTopView];
    [self.view addSubview:self.createSecretChatTopView];
    [self.view addSubview:self.bottomViewForGroupChat];
    [self.view addSubview:self.addMembersBottomView];
    [self.view addSubview:self.addContactContainerView];
    [self.view addSubview:self.broadcastBottomView];
    
    
   
    
    
    self.searchTextField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(14, self.view.bounds.size.height-[_actionsOffset[@(self.currentAction)] intValue]+6, self.view.bounds.size.width-30, 30)];
    self.searchTextField.delegate = self;
    [self.view addSubview:self.searchTextField];
    
    
    
    
    NSRect frame = NSMakeRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-[_actionsOffset[@(self.currentAction)] intValue]);
    
    self.tableView = [[SelectUsersTableView alloc] initWithFrame:frame];
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    
    
    self.currentAction = self.currentAction;
    self.tableView.exceptions = self.filter;
    [self.tableView ready];
    
    weakify();
    [self.tableView setMultipleCallback:^(NSArray *contacts) {
        
        TLContact *contact = contacts[0];
        if(strongSelf.currentAction == NewConversationActionCreateSecretChat) {
            [MessageSender startEncryptedChat:contact.user callback:^{
                
            }];
            [strongSelf.popover close];
        }
        
        if(strongSelf.currentAction == NewConversationActionWrite) {
            
            [strongSelf.popover close];
            
            TLDialog *dialog = contact.user.dialog;
            if(!dialog) {
                [[Storage manager] dialogByPeer:contact.user.n_id completeHandler:^(TLDialog *dialog, TLMessage *message) {
                    
                    if(dialog)
                        [[DialogsManager sharedManager] add:@[dialog]];
                    else
                        dialog = [[DialogsManager sharedManager] createDialogForUser:contact.user];
                    
                    if(message)
                        [[MessagesManager sharedManager] add:@[message]];
                    
                    
                    [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:strongSelf];
                    
                }];
            } else {
                [[Telegram sharedInstance] showMessagesFromDialog:contact.user.dialog sender:strongSelf];
            }
        }
    }];
    
    
    [self.tableView setMultipleCallback:^(NSArray *contacts) {
        if(strongSelf.currentAction == NewConversationActionCreateGroup) {
            [strongSelf checkCreateButton];
            [strongSelf updateTopTitle];
        }
        
        if(strongSelf.currentAction == NewConversationActionCreateBroadcast) {
            [strongSelf checkCreateBroadcastButton];
            [strongSelf updateTopTitle];
        }
    }];
    
    [self.view addSubview:self.tableView.containerView];
    
    

    self.prevTopView = self.defaultTopView;
    
    if(self.currentAction != NewConversationActionWrite)
        [self startAnimation:NewConversationActionWrite animated:NO];
    
    
}


-(void)setChooseButtonTitle:(NSString *)title {
    self.chooseMembersTitle = title;
}

-(BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *)item {
    return NO;
}

-(void)dealloc {
    [Notification removeObserver:self];
}



- (TMButton *)backButton {
    NSImage *backImage = image_boxBack();
    TMButton *back = [[TMButton alloc] initWithFrame:NSZeroRect];
    [back setAutoresizesSubviews:YES];
    [back setAutoresizingMask:NSViewMinXMargin];
    [back setTarget:self selector:@selector(actionGoBack)];
    [back setText:NSLocalizedString(@"Profile.Back", nil)];
    [back setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    NSSize size = NSMakeSize([back sizeOfText].width+24, [back sizeOfText].height);
    [back setFrameSize:size];
    [back setFrameOrigin:NSMakePoint(self.view.bounds.size.width - size.width - 25, 24)];
    
    [back setTextColor:LINK_COLOR forState:TMButtonNormalState];
    [back setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
    [back setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
    
    TMImageView *imgView = [[TMImageView alloc] initWithFrame:NSMakeRect(0, roundf(size.height/2-backImage.size.height/2-2), backImage.size.width, backImage.size.height)];
    imgView.image = backImage;
    
    [back addSubview:imgView];
    
    return back;

}


- (TMView *)createAddContactView:(int)topOffset {
    static float rightOffet = 0.0;
    float width = self.view.bounds.size.width - rightOffet;
    
    TMView *topView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.addContactSize.height-topOffset, width, topOffset)];
    [topView setBackgroundColor:[NSColor whiteColor]];
    [topView setAutoresizesSubviews:YES];
    [topView setAutoresizingMask:NSViewMaxYMargin];
    
    
    
    TMButton *back = [self backButton];
    
    [back setFrame:NSMakeRect(15, topView.frame.size.height-back.frame.size.height-15, back.frame.size.width, back.frame.size.height)];
   
    
    TMTextField *topTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, topView.frame.size.height-back.frame.size.height-15, topView.frame.size.width, 20)];
    
    
    
    [topTextField setStringValue:NSLocalizedString(@"NewConversation.AddContact", nil)];
    [topTextField setEditable:NO];
    [topTextField setSelectable:NO];
    [topTextField setBordered:NO];
    [topTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [topTextField setTextColor:NSColorFromRGB(0x333333)];
    [topTextField setAlignment:NSCenterTextAlignment];
    
    
    
    AddContactView *addContactView = [[AddContactView alloc] initWithFrame:NSMakeRect(0, 0, topView.frame.size.width, topOffset-40)];
    addContactView.controller = self;

    
    
    [topView addSubview:topTextField];
    
    [topView addSubview:back];
    
    
    [topView addSubview:addContactView];
    
    
    return topView;

}

-(TMView *)topViewForDefault:(int)topOffset {
    
    static float rightOffet = 0;
    float width = self.view.bounds.size.width - rightOffet;
    
    TMView *topView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height - topOffset, width, topOffset)];
    [topView setBackgroundColor:[NSColor whiteColor]];
    [topView setAutoresizesSubviews:YES];
    [topView setAutoresizingMask:NSViewMinYMargin];
    
    
    
    dispatch_block_t separatorDraw = ^ {
        [NSColorFromRGB(0xf4f4f4) set];
        NSRectFill(NSMakeRect(15, 0, topView.frame.size.width-30, 1));
    };
    
    int offsetY = topView.frame.size.height - 39;
    
    NSImage *gImage = image_group();
    TMButton *createChatButton = [[TMButton alloc] initWithFrame:NSMakeRect(0, offsetY, topView.frame.size.width, 40)];
    [createChatButton setAutoresizesSubviews:YES];
    [createChatButton setAutoresizingMask:NSViewMinXMargin];
    [createChatButton setTarget:self selector:@selector(actionCreateChat)];
    [createChatButton setText:NSLocalizedString(@"NewConversation.CreateGroupChat", nil)];
    [createChatButton setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    
    [createChatButton setTextOffset:NSMakeSize(0, 3)];
    
   //  [createChatButton setDrawBlock:separatorDraw];
    
    NSSize size = NSMakeSize([createChatButton sizeOfText].width+30, [createChatButton sizeOfText].height);
    [createChatButton setTextColor:BLUE_UI_COLOR forState:TMButtonNormalState];
    [createChatButton setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
    [createChatButton setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
    TMImageView *gImageView = [[TMImageView alloc] initWithFrame:NSMakeRect(roundf((topView.frame.size.width-size.width)/2) - 4, roundf(size.height/2-gImage.size.height/2+11), gImage.size.width, gImage.size.height)];
    gImageView.image = gImage;
    
    [createChatButton addSubview:gImageView];
    
   
    [topView addSubview:createChatButton];
    
    offsetY-=(createChatButton.frame.size.height)+1;
    
  
    
    
    
    
    
    NSImage *bImage = [NSImage imageNamed:@"newConversationBroadcast"];
    TMButton *broadcastButton = [[TMButton alloc] initWithFrame:NSMakeRect(0, offsetY, topView.frame.size.width, 35)];
    [broadcastButton setAutoresizesSubviews:YES];
    [broadcastButton setAutoresizingMask:NSViewMinXMargin];
    [broadcastButton setTarget:self selector:@selector(actionCreateBroadcast)];
    [broadcastButton setText:NSLocalizedString(@"NewConversation.CreateBroadcast", nil)];
    [broadcastButton setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    size = NSMakeSize([broadcastButton sizeOfText].width+20, [broadcastButton sizeOfText].height);
    
   
    [broadcastButton setTextOffset:NSMakeSize(0, 3)];
    [broadcastButton setTextColor:BLUE_UI_COLOR forState:TMButtonNormalState];
    [broadcastButton setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
    [broadcastButton setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
    
    TMImageView *bImageView = [[TMImageView alloc] initWithFrame:NSMakeRect(roundf((topView.frame.size.width-size.width)/2) - 8, roundf(size.height/2-bImage.size.height/2+9), bImage.size.width, bImage.size.height)];
    bImageView.image = bImage;
    
    [broadcastButton addSubview:bImageView];
    
 //    [broadcastButton setDrawBlock:separatorDraw];
    
    
    [topView addSubview:broadcastButton];
    
    offsetY-=(broadcastButton.frame.size.height)+6;
    
    
    NSImage *sImage = image_secret();
    TMButton *createSecretChatButton = [[TMButton alloc] initWithFrame:NSMakeRect(0, offsetY, topView.frame.size.width, 41)];
    [createSecretChatButton setAutoresizesSubviews:YES];
    [createSecretChatButton setAutoresizingMask:NSViewMinXMargin];
    [createSecretChatButton setTarget:self selector:@selector(actionCreateSecretChat)];
    [createSecretChatButton setText:NSLocalizedString(@"NewConversation.CreateSecretChat", nil)];
    [createSecretChatButton setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    
    [createSecretChatButton setTextOffset:NSMakeSize(0, 2)];
    
   // [createSecretChatButton setDrawBlock:separatorDraw];
    
    size = NSMakeSize([createSecretChatButton sizeOfText].width+20, [createSecretChatButton sizeOfText].height);
    
    [createSecretChatButton setTextColor:NSColorFromRGB(0x40b158) forState:TMButtonNormalState];
    [createSecretChatButton setTextColor:NSColorFromRGB(0x458b80) forState:TMButtonNormalHoverState];
    [createSecretChatButton setTextColor:NSColorFromRGB(0x458b99) forState:TMButtonPressedState];
    
    TMImageView *sImageView = [[TMImageView alloc] initWithFrame:NSMakeRect(roundf((topView.frame.size.width-size.width)/2) - 4, roundf(size.height/2-sImage.size.height/2+12), sImage.size.width, sImage.size.height)];
    sImageView.image = sImage;
    
    [createSecretChatButton addSubview:sImageView];
    
    
    
    [topView addSubview:createSecretChatButton];
    
    
    
    
    
     offsetY-=(createSecretChatButton.frame.size.height)-4;
    
    
    
    NSImage *cImage = image_addContact();
    TMButton *addContactButton = [[TMButton alloc] initWithFrame:NSMakeRect(0, offsetY, topView.frame.size.width, 35)];
    [addContactButton setAutoresizesSubviews:YES];
    [addContactButton setAutoresizingMask:NSViewMinXMargin];
    [addContactButton setTarget:self selector:@selector(actionAddContact)];
    [addContactButton setText:NSLocalizedString(@"NewConversation.AddContact", nil)];
    [addContactButton setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    size = NSMakeSize([addContactButton sizeOfText].width+20, [addContactButton sizeOfText].height);
    [addContactButton setTextOffset:NSMakeSize(0, 2)];
    
    [addContactButton setTextColor:BLUE_UI_COLOR forState:TMButtonNormalState];
    [addContactButton setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
    [addContactButton setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
    
    TMImageView *cImageView = [[TMImageView alloc] initWithFrame:NSMakeRect(roundf((topView.frame.size.width-size.width)/2) - 4, roundf(size.height/2-cImage.size.height/2+7), cImage.size.width, cImage.size.height)];
    cImageView.image = cImage;
    
    [addContactButton addSubview:cImageView];
    
    
    
    [topView addSubview:addContactButton];
    
    
    return topView;
}


- (void) searchFieldTextChange:(NSString*)searchString {
    [self.tableView search:searchString];
}

-(TMView *)createBottomViewForAddMembers {
    TMView *bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 40)];
    
    [bottomView setBackgroundColor:NSColorFromRGB(0xfafafa)];
    [bottomView setAutoresizesSubviews:YES];
    [bottomView setAutoresizingMask:NSViewMinYMargin];
    
    
    self.addMembersButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 2, self.view.bounds.size.width, 40)];
    
    
    weakify();
    [self.addMembersButton addBlock:^(BTRControlEvents events) {
        
        NSArray *selected = [strongSelf.tableView selectedItems];
        
        if([strongSelf.chooseTarget respondsToSelector:strongSelf.chooseSelector]) {
            
            [strongSelf.chooseTarget performSelectorOnMainThread:strongSelf.chooseSelector withObject:selected waitUntilDone:YES];
            
        }
        
        [strongSelf.popover close];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    
    
    [self.addMembersButton setTitleFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forControlState:BTRControlStateNormal];
    [self.addMembersButton  setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateHover];
    
    [self.addMembersButton setTitle:self.chooseMembersTitle forControlState:BTRControlStateNormal];
    
    
    [self.addMembersButton setTitleColor:DARK_BLUE forControlState:BTRControlStateNormal];
    
    [self.addMembersButton setTitleColor:NSColorFromRGB(0xcccccc) forControlState:BTRControlStateDisabled];
    
    [bottomView addSubview:self.addMembersButton];
    
    
    return bottomView;
}


-(TMView *)createBottomViewForBroadcast {
    
    TMView *bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, -40, self.view.bounds.size.width, 40)];
    
    [bottomView setBackgroundColor:NSColorFromRGB(0xfafafa)];
    [bottomView setAutoresizesSubviews:YES];
    [bottomView setAutoresizingMask:NSViewMinYMargin];
    
    
    weakify();
    
    [bottomView setDrawBlock:^{
        [NSColorFromRGB(0xf1f1f1) setFill];
        NSRectFill(NSMakeRect(0, strongSelf.broadcastBottomView.frame.size.height-1, strongSelf.broadcastBottomView.frame.size.width, 1));
    }];
    
    self.createBroadcastButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 2, self.view.bounds.size.width, 40)];
    
    
    [self.createBroadcastButton addBlock:^(BTRControlEvents events) {
        
        
        NSMutableArray *participants = [[NSMutableArray alloc] init];
        
        [strongSelf.tableView.selectedItems enumerateObjectsUsingBlock:^( SelectUserItem * obj, NSUInteger idx, BOOL *stop) {
            [participants addObject:@(obj.user.n_id)];
        }];
        
        TL_broadcast *broadcast = [TL_broadcast createWithN_id:arc4random() participants:participants title:@"" date:[[MTNetwork instance] getTime]];
        
        TL_conversation *conversation = [TL_conversation createWithPeer:[TL_peerBroadcast createWithChat_id:broadcast.n_id] top_message:0 unread_count:0 last_message_date:[[MTNetwork instance] getTime] notify_settings:[TL_peerNotifySettingsEmpty create] last_marked_message:0 top_message_fake:0 last_marked_date:[[MTNetwork instance] getTime] sync_message_id:0];
        
        [[DialogsManager sharedManager] add:@[conversation]];
        [conversation save];
        
        [[BroadcastManager sharedManager] add:@[broadcast]];
        
        int fakeId = [MessageSender getFakeMessageId];
        
       
        TL_localMessageService *msg = [TL_localMessageService createWithN_id:fakeId flags:TGOUTMESSAGE from_id:[UsersManager currentUserId] to_id:conversation.peer date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:NSLocalizedString(@"MessageAction.ServiceMessage.CreatedBroadcast", nil)] fakeId:fakeId randomId:rand_long() dstate:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:msg];
        
        
        [[Telegram rightViewController] showByDialog:conversation sender:strongSelf];
        
        [strongSelf.popover close];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    
    
    [self.createBroadcastButton setTitleFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forControlState:BTRControlStateNormal];
    [self.createBroadcastButton setTitleFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forControlState:BTRControlStateDisabled];
    [self.createBroadcastButton  setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateHover];
    
    [self.createBroadcastButton setTitle:NSLocalizedString(@"Broadcast.Create", nil) forControlState:BTRControlStateNormal];
    
     [self.createBroadcastButton setTitle:NSLocalizedString(@"Broadcast.Create", nil) forControlState:BTRControlStateDisabled];
    
    [self.createBroadcastButton setTitleColor:DARK_BLUE forControlState:BTRControlStateNormal];
    
    [self.createBroadcastButton setTitleColor:NSColorFromRGB(0xcccccc) forControlState:BTRControlStateDisabled];
    
    [bottomView addSubview:self.createBroadcastButton];
    
    
    return bottomView;
}



-(TMView *)topViewForGroupChat:(int)topOffset {
    static float rightOffet = 0.0;
    float width = self.view.bounds.size.width - rightOffet;
    
    TMView *topView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.view.frame.size.height-topOffset, width, topOffset)];
    [topView setBackgroundColor:[NSColor whiteColor]];
    [topView setAutoresizesSubviews:YES];
    [topView setAutoresizingMask:NSViewMaxYMargin];
    
    
    TMButton *back = [self backButton];
    
    
    [back setFrame:NSMakeRect(15, topView.frame.size.height-back.frame.size.height-15, back.frame.size.width, back.frame.size.height)];
    
    
    TMTextField *topTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, topView.frame.size.height-back.frame.size.height-15, topView.frame.size.width, 20)];
    
    
    
    [topTextField setStringValue:NSLocalizedString(@"NewConversation.CreatingGroupChat", nil)];
    [topTextField setEditable:NO];
    [topTextField setSelectable:NO];
    [topTextField setBordered:NO];
    [topTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [topTextField setTextColor:NSColorFromRGB(0x333333)];
    [topTextField setAlignment:NSCenterTextAlignment];
    
    
    
    self.textField = topTextField;
    
    [self updateTopTitle];
    
    [topView addSubview:topTextField];
    
    [topView addSubview:back];
    return topView;
}



-(TMView *)topViewForSecretChat:(int)topOffset {
    static float rightOffet = 0.0;
    float width = self.view.bounds.size.width - rightOffet;
    
    TMView *topView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.view.frame.size.height-topOffset, width, topOffset)];
    [topView setBackgroundColor:[NSColor whiteColor]];
    [topView setAutoresizesSubviews:YES];
    [topView setAutoresizingMask:NSViewMaxYMargin];
    
    
    TMButton *back = [self backButton];
    
    
    
    [back setFrame:NSMakeRect(15, topView.frame.size.height-back.frame.size.height-15, back.frame.size.width, back.frame.size.height)];
    
    
    TMTextField *topTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, topView.frame.size.height-back.frame.size.height-15, topView.frame.size.width, 20)];
    
    
    
    [topTextField setStringValue:NSLocalizedString(@"NewConversation.CreatingSecretChat", nil)];
    [topTextField setEditable:NO];
    [topTextField setSelectable:NO];
    [topTextField setBordered:NO];
    [topTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [topTextField setTextColor:NSColorFromRGB(0x333333)];
    [topTextField setAlignment:NSCenterTextAlignment];
    
    [topView addSubview:topTextField];
    
    [topView addSubview:back];
    
    [back setFrame:NSMakeRect(15, topView.frame.size.height-back.frame.size.height-15, back.frame.size.width, back.frame.size.height)];
    
    return topView;
}

-(void)createGroupChat {
    NSArray *selected = [self.tableView selectedItems];
    
    if(selected.count == 0 || self.chatTitle.length == 0)
        return;
    
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(SelectUserItem* item in selected) {
        if(!item.user.type != TLUserTypeSelf) {
            TL_inputUserContact *_contact = [TL_inputUserContact createWithUser_id:item.user.n_id];
            [array addObject:_contact];
        }
       
    }
    
    
    [RPCRequest sendRequest:[TLAPI_messages_createChat createWithUsers:array title:self.chatTitle] successHandler:^(RPCRequest *request, TLUpdates *response) {
                
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:(TLMessage *) ( [response.updates[1] message])];
        
        [[FullChatManager sharedManager] performLoad:msg.conversation.chat.n_id callback:^{
            [[Telegram sharedInstance] showMessagesFromDialog:((TL_localMessage *)response.message).conversation sender:self];
        }];
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];

    [self.popover close];
    
}


-(TMView *)createBottomViewForGroupChat {
    TMView *bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, -60, self.view.bounds.size.width, 60)];
    
    [bottomView setBackgroundColor:NSColorFromRGB(0xfafafa)];
    [bottomView setAutoresizesSubviews:YES];
    [bottomView setAutoresizingMask:NSViewMinYMargin];
    
    TMGrowingTextView *textView = [[TMGrowingTextView alloc] init];
    [textView setEditable:YES];
    [textView setRichText:NO];
    [textView setMode:TMGrowingModeSingleLine];
    [textView setLimit:34];
    textView.growingDelegate = self;
   // [textView setBackgroundImage:msg_input()];
    [textView setPlaceholderString:NSLocalizedString(@"NewConversation.GroupNamePlaceholder", nil)];
    self.createButton = [[TMButton alloc] initWithFrame:NSZeroRect];
    
    [self.createButton setTarget:self selector:@selector(createGroupChat)];
    [self.createButton setText:NSLocalizedString(@"NewConversation.CreateGroup", nil)];
    [self.createButton setTextFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12]];
    NSSize size = [self.createButton sizeOfText];
    [self.createButton setFrameSize:size];
    [self.createButton setFrameOrigin:NSMakePoint(bottomView.bounds.size.width - size.width - 25, 24)];
    
    
    __block TMView *strong = bottomView;
    
    [bottomView setDrawBlock:^ {
        [GRAY_BORDER_COLOR set];
        NSRectFill(NSMakeRect(0, strong.frame.size.height-1, strong.frame.size.width, 1));
    }];
    
    [bottomView addSubview:self.createButton];
    
    textView.containerView.frame = NSMakeRect(15, roundf(bottomView.frame.size.height/2-15), bottomView.frame.size.width-100, 30);
    [textView textDidChange:nil];
    [bottomView addSubview:textView.containerView];
    
    return bottomView;
}

-(void)TMGrowingTextViewHeightChanged:(id)textView height:(int)height cleared:(BOOL)isCleared {
    
}

-(void)TMGrowingTextViewFirstResponder:(id)textView isFirstResponder:(BOOL)isFirstResponder {
    
}

-(BOOL)TMGrowingTextViewCommandOrControlPressed:(id)textView isCommandPressed:(BOOL)isCommandPressed {
    [self createGroupChat];
    return YES;
}


- (void) TMGrowingTextViewTextDidChange:(TMGrowingTextView *)textView {
    self.chatTitle = [textView.stringValue trim];
    [self checkCreateButton];
}

-(void)checkCreateBroadcastButton {
    [self.createBroadcastButton setEnabled:[self.tableView selectedItems].count > 0];
 }

-(void)checkCreateButton
{
    [self.addMembersButton setEnabled:[self.tableView selectedItems].count > 0];
    
    if(self.chatTitle.length > 0 && [self.tableView selectedItems].count > 0) {
        [self.createButton setTextColor:LINK_COLOR forState:TMButtonNormalState];
        [self.createButton setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
        [self.createButton setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
        [self.createButton setDisabled:NO];
        
    } else {
        [self.createButton setTextColor:NSColorFromRGB(0xaeaeae) forState:TMButtonNormalState];
        [self.createButton setDisabled:YES];
    }

   
}



-(void)actionGoBack {
    [self reset];
    
    self.prevTopView = self.currentTopView;
    NewConversationAction prevAction = self.currentAction;
    self.currentTopView = self.defaultTopView;
    self.currentAction = NewConversationActionWrite;
    
    [self startAnimation:prevAction animated:YES];
}

-(void)actionAddContact {
//    [self.popover close];
//    alert(@":(", @"Not working, wait please :)");
    
    [self reset];
    
    self.prevTopView = self.currentTopView;
    NewConversationAction prevAction = self.currentAction;
    self.currentTopView = self.addContactContainerView;
    self.currentAction = NewConversationActionAddContact;
    
    [self startAnimation:prevAction animated:YES];

}


-(void)actionCreateChat {
    [self reset];
    
    self.prevTopView = self.currentTopView;
    NewConversationAction prevAction = self.currentAction;
    self.currentTopView = self.createChatTopView;
    
    
    self.currentAction = NewConversationActionCreateGroup;
    self.tableView.selectLimit = maxChatUsers();
    [self.textField setStringValue:NSLocalizedString(@"NewConversation.CreatingGroupChat", nil)];
    self.currentBottomView = self.bottomViewForGroupChat;
    [self startAnimation:prevAction animated:YES];
}

-(void)actionCreateBroadcast {
    [self reset];
    [self checkCreateBroadcastButton];
    self.prevTopView = self.currentTopView;
    NewConversationAction prevAction = self.currentAction;
    self.currentTopView = self.createChatTopView;
    self.currentAction = NewConversationActionCreateBroadcast;
    self.tableView.selectLimit = maxBroadcastUsers();
    [self.textField setStringValue:NSLocalizedString(@"NewConversation.CreatingBroadcast", nil)];
    self.currentBottomView = self.broadcastBottomView;
    [self startAnimation:prevAction animated:YES];
}

-(void)actionCreateSecretChat {
    [self reset];
    
    self.prevTopView = self.currentTopView;
    
    self.currentTopView = self.createSecretChatTopView;
    NewConversationAction prevAction = self.currentAction;
    self.currentAction = NewConversationActionCreateSecretChat;
    [self startAnimation:prevAction animated:YES];
    
}

-(void)startAnimation:(NewConversationAction)prevAction animated:(BOOL)animated {
    
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:animated && self.currentAction != NewConversationActionAddContact && prevAction != NewConversationActionAddContact ? 0.2 : 0];
        
        [self fadeView:self.prevTopView alpha:0.0f];
        
        
        [self.prevTopView setHidden:prevAction == NewConversationActionAddContact];
        
        [self.currentBottomView setHidden:self.currentAction == NewConversationActionAddContact ? YES : NO];
        
        
        [self.currentTopView setHidden:NO];
        
        [self fadeView:self.currentTopView alpha:1.0f];
        
        
        [self.tableView.containerView setHidden:self.currentAction == NewConversationActionAddContact];
        [self.searchTextField setHidden:self.currentAction == NewConversationActionAddContact];
        
        
        [self.currentTopView becomeFirstResponder];
        
        self.popover.animates = NO;
        [self.popover setContentSize:self.currentAction == NewConversationActionAddContact ? self.addContactSize : self.normalSize];
        
        
        
        [[self.currentBottomView animator] setFrameOrigin:NSMakePoint(0, self.currentAction == NewConversationActionCreateBroadcast || self.currentAction == NewConversationActionCreateGroup || self.currentAction == NewConversationActionChoosePeople ? 0 : -self.currentBottomView.frame.size.height)];
        
        NSPoint searchPos = self.currentAction == NewConversationActionWrite ? NSMakePoint(self.searchTextField.frame.origin.x, self.view.bounds.size.height-[_actionsOffset[@(self.currentAction)] intValue]+6) : NSMakePoint(self.searchTextField.frame.origin.x, self.view.bounds.size.height-self.currentTopView.frame.size.height+83);
        
        
        if(self.currentAction == NewConversationActionChoosePeople) {
            searchPos = NSMakePoint(self.searchTextField.frame.origin.x, self.view.bounds.size.height-self.currentTopView.frame.size.height-[_actionsOffset[@(self.currentAction)] intValue]);
        }
        
        int marginY = self.currentAction == NewConversationActionWrite || self.currentAction == NewConversationActionCreateSecretChat ? 0 : self.currentBottomView.frame.size.height;
        
        
        int f = self.currentAction == NewConversationActionWrite ? 190 : (self.currentAction == NewConversationActionChoosePeople ? 40 : 80);
        
        id search = prevAction == NewConversationActionAddContact ? self.searchTextField : [self.searchTextField animator];
        id table = prevAction == NewConversationActionAddContact ? self.tableView.containerView : [self.tableView.containerView animator];
        
        [table setFrameSize:NSMakeSize(self.tableView.containerView.frame.size.width, self.view.frame.size.height-f-marginY)];
        
        NSPoint tablePos = NSMakePoint(0, marginY );
        
       
        
        
        [search setFrameOrigin:searchPos];
        [table setFrameOrigin:tablePos];
        
       
     
    } completionHandler:^{
        [self.prevTopView setHidden:YES];
     
    }];
    

}


-(void)reset {
    [self updateTopTitle];
}

-(void)fadeView:(NSView *)superview alpha:(float)alpha {
    [[superview animator] setAlphaValue:alpha];
    for (NSView *view in superview.subviews) {
        [[view animator] setAlphaValue:alpha];
    }
}


-(void)updateTopTitle {
    NSArray *selected = [self.tableView selectedItems];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    
    [attr appendString:self.currentAction == NewConversationActionCreateBroadcast ? NSLocalizedString(@"NewConversation.CreatingBroadcast", nil) : NSLocalizedString(@"NewConversation.CreatingGroupChat", nil) withColor:NSColorFromRGB(0x333333)];
    NSRange range = [attr appendString:[NSString stringWithFormat:@" - %lu/%d",selected.count,self.tableView.selectLimit] withColor:DARK_GRAY];
    [attr setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:range];
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    [self.textField setAttributedStringValue:attr];
    [self.textField setAlignment:NSCenterTextAlignment];
}


-(void)setCurrentAction:(NewConversationAction)currentAction {
    self->_currentAction = currentAction;
    
//    [self.bottomViewForGroupChat setHidden:currentAction != NewConversationActionCreateGroup];
    [self.addMembersBottomView setHidden:currentAction != NewConversationActionChoosePeople];
    
  //  self.tableView.selectType = (currentAction == NewConversationActionCreateBroadcast) || (currentAction == NewConversationActionCreateGroup) ||  (currentAction == NewConversationActionChoosePeople) ? SelectUsersTypeMultiple : SelectUsersTypeSingle;
}

@end
