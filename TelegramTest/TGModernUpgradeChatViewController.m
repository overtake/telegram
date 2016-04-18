//
//  TGModernUpgradeChatViewController.m
//  Telegram
//
//  Created by keepcoder on 04/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernUpgradeChatViewController.h"
#import "TGSettingsTableView.h"
#import "ComposeActionCustomBehavior.h"
@interface TGModernUpgradeChatViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@end

@implementation TGModernUpgradeChatViewController

-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
        
    [self.doneButton setHidden:YES];
    
    [_tableView removeAllItems:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    GeneralSettingsBlockHeaderItem *header = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.ForceConvertChatAbilityDescription", nil) flipped:NO];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    paragraph.lineSpacing = 4;
    
    [header setParagraph:paragraph];
    
    [_tableView addItem:header tableRedraw:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    weak();
    
    GeneralSettingsRowItem *convertItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            ComposeActionCustomBehavior *behavior = (ComposeActionCustomBehavior *) strongSelf.action.behavior;
            
            if(behavior.composeDone)
                behavior.composeDone();
        }
        
    } description:NSLocalizedString(@"Conversation.ConvertToSuperGroup", nil) height:42 stateback:nil];
    
    
    convertItem.textColor = BLUE_UI_COLOR;
    
    [_tableView addItem:convertItem tableRedraw:YES];
    
    [_tableView addItem:[[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.ForceConvertChatAbilityNote", nil) flipped:YES] tableRedraw:YES];
    
}

-(void)dealloc {
    [_tableView clear];
}

@end
