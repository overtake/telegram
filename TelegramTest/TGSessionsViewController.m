//
//  TGSessionsViewController.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSessionsViewController.h"
#import "TGSessionRowView.h"

@interface TGSessionsViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) BTRButton *terminateAllSessions;
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) NSProgressIndicator *progressIndicator;

@property (nonatomic,strong) NSMutableArray *authorizations;
@end

@implementation TGSessionsViewController

-(void)loadView {
    [super loadView];
    
    self.authorizations = [[NSMutableArray alloc] init];
    
    
    
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    self.progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
    
    [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    
    [self setCenterBarViewText:NSLocalizedString(@"Authorization.Authorizations", nil)];
    
    [self.view addSubview:self.progressIndicator];
    
    [self.progressIndicator setCenterByView:self.view];
    
    
    [self.view addSubview:self.tableView.containerView];
    
}

-(void)newAuthorization:(NSNotification *)notification {
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView removeAllItems:YES];
    
    [self.progressIndicator setHidden:NO];
    
    [self.progressIndicator startAnimation:self.view];
    
    [self.progressIndicator setCenterByView:self.view];
    
    [self.tableView.containerView setHidden:YES];
    
    
    [RPCRequest sendRequest:[TLAPI_account_getAuthorizations create] successHandler:^(RPCRequest *request, TL_account_authorizations *response) {
        
        [self.progressIndicator stopAnimation:self.view];
        [self.progressIndicator setHidden:YES];
        [self.tableView.containerView setHidden:NO];
        
        [response.authorizations enumerateObjectsUsingBlock:^(TL_authorization *obj, NSUInteger idx, BOOL *stop) {
            
            [self.authorizations addObject:[[TGSessionRowitem alloc] initWithObject:obj]];
            
        }];
        
        [self.tableView insert:self.authorizations startIndex:0 tableRedraw:YES];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
        
    } timeout:10];
    
}

-(void)resetAuthorization:(TGSessionRowitem *)item {
    
    
    dispatch_block_t block = ^ {
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_account_resetAuthorization createWithN_hash:item.authorization.n_hash] successHandler:^(RPCRequest *request, id response) {
            
            [self hideModalProgress];
            
            [self.authorizations removeObject:item];
            
            self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
            
            [self.tableView removeItem:item tableRedraw:YES];
            
            self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
        
    };
    
    
    if((item.authorization.flags & TGSESSIONCURRENT ) == TGSESSIONCURRENT) {
        
       confirm(NSLocalizedString(@"Confirm", nil),NSLocalizedString(@"Confirm.ConfirmLogout", nil), ^ {
           [[Telegram delegate] logoutWithForce:NO];
       },nil);
        
    } else {
        block();
    }
    
    
    
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? 103 : 50;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self.tableView cacheViewForClass:[TGSessionRowView class] identifier:@"TGSessionRowView" withSize:NSMakeSize(NSWidth(self.view.frame), 50)];
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

@end
