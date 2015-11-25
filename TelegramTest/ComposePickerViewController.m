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
}

-(void)behaviorDidStartRequest {
    [self showModalProgress];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

-(void)_didStackRemoved {
    [self.action.behavior composeDidCancel];
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.exceptions = self.action.filter;
    
    self.tableView.selectLimit = self.action.behavior.limit;
    self.action.behavior.delegate = self;
    
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [self.action.result.multiObjects enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
        
        [ids addObject:@(obj.n_id)];
    }];
    
    self.tableView.selectedItems = ids;
    
    [self.tableView readyContacts];
    
    [self.tableView scrollToBeginningOfDocument:self];
    
    self.action.currentViewController = self;

    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton setDisable:self.action.result.multiObjects.count == 0];
    
    [self.doneButton setDisable:self.doneButton.disable || self.action.behavior.doneTitle.length == 0];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
}


-(void)selectTableDidChangedItem:(SelectUserItem *)item {
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    [self.tableView.selectedItems enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL *stop) {
        
        [users addObject:obj.user];
        
    }];
    
    if(!self.action.result)
        self.action.result = [[ComposeResult alloc] initWithMultiObjects:users];
     else
         self.action.result.multiObjects = users;
    
    
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    [self.action.behavior composeDidChangeSelected];
    
    [self.doneButton setDisable:self.action.result.multiObjects.count == 0 || self.action.behavior.doneTitle.length == 0];
}


@end
