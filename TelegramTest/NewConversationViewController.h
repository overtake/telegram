//
//  NewConversationViewController.h
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface NewConversationViewController : TMViewController<NSTableViewDataSource, NSTableViewDelegate,TMTableViewDelegate,TMSearchTextFieldDelegate,TMGrowingTextViewDelegate>
@property (nonatomic) int typeController;
typedef enum {
    NewConversationActionWrite = 0,
    NewConversationActionCreateGroup = 1,
    NewConversationActionCreateSecretChat = 2,
    NewConversationActionChoosePeople = 3,
    NewConversationActionAddContact = 4,
    NewConversationActionCreateBroadcast = 5
} NewConversationAction;

@property (nonatomic,strong) id chooseTarget;
@property (nonatomic,assign) SEL chooseSelector;

@property (nonatomic,strong) NSArray *filter;

-(void)setChooseButtonTitle:(NSString *)title;


@property (nonatomic,assign) NewConversationAction currentAction;

-(void)actionAddChatMembers:(TL_chatFull *)chat completionHandler:(void (^)(NSArray *users))completionHandler;

-(void)actionGoBack;
-(void)actionCreateChat;
-(void)actionCreateSecretChat;
@end
