//
//  UserPickerViewController.m
//  Telegram
//
//  Created by keepcoder on 28.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposePickerViewController.h"
#import "SelectUsersTableView.h"
#import "TMTokenField.h"



@interface ComposePickerViewController ()<SelectTableDelegate,ComposeBehaviorDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;


@end

@implementation ComposePickerViewController



-(void)loadView {
    [super loadView];
    
    self.tableView = [[SelectUsersTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.tableView.containerView];
    
   
    self.tableView.selectDelegate = self;
    [self.tableView ready];
    
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    self.tableView.exceptions = action.filter;
    
    [self.tableView ready];
    
    self.tableView.selectLimit = self.action.behavior.limit;
    self.action.behavior.delegate = self;
    
    [self.tableView scrollToBeginningOfDocument:self];
}


-(void)setAction:(ComposeAction *)action animated:(BOOL)animated {
    [super setAction:action];
    
    self.tableView.selectLimit = self.action.behavior.limit;
    self.action.behavior.delegate = self;
    
    [self.tableView scrollToBeginningOfDocument:self];
    
    
    [self.tableView.list enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(idx == 0)
            return;
        
        SelectUserRowView *view = [self.tableView viewAtColumn:0 row:idx makeIfNecessary:NO];
        
        [view needUpdateSelectType];
    }];
    
    [self viewWillAppear:YES];
}

-(void)behaviorDidEndRequest:(id)response {
    [self hideModalProgress];
    
    [self.backButton setDisabled:NO];
    [self.doneButton setDisable:NO];
}

-(void)behaviorDidStartRequest {
    [self showModalProgress];
    
    
    [self.backButton setDisabled:YES];
    [self.doneButton setDisable:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.action.behavior composeDidCancel];
}

-(void)viewWillAppear:(BOOL)animated {
    self.action.currentViewController = self;

    [self.centerTextField setAttributedStringValue:self.action.behavior.centerTitle];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton setDisable:self.action.result.multiObjects.count == 0];
    
    [self.doneButton setDisable:self.doneButton.disable || self.action.behavior.doneTitle.length == 0];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
}


-(void)selectTableDidChangedItem:(SelectUserItem *)item {
    
    self.action.result = [[ComposeResult alloc] initWithMultiObjects:[self.tableView selectedItems]];
    
    [self.centerTextField setAttributedStringValue:self.action.behavior.centerTitle];
    
    [self.action.behavior composeDidChangeSelected];
    
    [self.doneButton setDisable:self.action.result.multiObjects.count == 0 || self.action.behavior.doneTitle.length == 0];
}


@end
