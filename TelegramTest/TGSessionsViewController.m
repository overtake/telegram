//
//  TGSessionsViewController.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSessionsViewController.h"
#import "TGSessionRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "GeneralSettingsRowView.h"
#import "TGTimer.h"
@interface TGSessionsViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) NSProgressIndicator *progressIndicator;

@property (nonatomic,strong) NSMutableArray *authorizations;
@property (nonatomic,strong) TL_authorization *current;
@property (nonatomic,strong) TGTimer *updateTimer;
@end

@implementation TGSessionsViewController

-(void)loadView {
    [super loadView];
    
    self.authorizations = [[NSMutableArray alloc] init];
    
    
    
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    self.progressIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
    
    [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    
    [self setCenterBarViewText:NSLocalizedString(@"Authorization.Authorizations", nil)];
    
    [self.view addSubview:self.progressIndicator];
    
    [self.progressIndicator setCenterByView:self.view];
    
    
    [self.view addSubview:self.tableView.containerView];
    
}

-(void)newAuthorization:(NSNotification *)notification {
    
}

-(BOOL)becomeFirstResponder {
    
    [self reload];
    
    return [super becomeFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_updateTimer invalidate];
    _updateTimer = nil;
    _updateTimer  = [[TGTimer alloc] initWithTimeout:5 repeat:YES completion:^{
        
        if([[NSApplication sharedApplication] isActive])
            [self reload];
        
    } queue:[ASQueue mainQueue].nativeQueue];
    
    [self.tableView removeAllItems:YES];
    
    [self.progressIndicator setHidden:NO];
    
    [self.progressIndicator startAnimation:self.view];
    
    [self.progressIndicator setCenterByView:self.view];
    
    [self.tableView.containerView setHidden:YES];
    
    [self reload];
    
}

-(void)reload {
    
    
    
    [RPCRequest sendRequest:[TLAPI_account_getAuthorizations create] successHandler:^(RPCRequest *request, TL_account_authorizations *response) {
        
        [self.progressIndicator stopAnimation:self.view];
        [self.progressIndicator setHidden:YES];
        [self.tableView.containerView setHidden:NO];
        
        
        [self.authorizations removeAllObjects];
        
        self.current = [response.authorizations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_hash == 0"]][0];
        
        [response.authorizations removeObject:self.current];
        
        
        [response.authorizations enumerateObjectsUsingBlock:^(TL_authorization *obj, NSUInteger idx, BOOL *stop) {
            
            
            
            [self.authorizations addObject:[[TGSessionRowitem alloc] initWithObject:obj]];
            
            
            
        }];
        
        [self rebuild];
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
        
    } timeout:10];

}


-(void)rebuild {
    
    [self.tableView removeAllItems:NO];
    
    GeneralSettingsBlockHeaderItem *selfHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"AuthSessions.CurrentSession", nil) height:62 flipped:NO];
    
    [self.tableView insert:selfHeader atIndex:self.tableView.count tableRedraw:NO];
    
    
    [self.tableView insert:[[TGSessionRowitem alloc] initWithObject:self.current] atIndex:self.tableView.count tableRedraw:NO];
    
    
    
    GeneralSettingsRowItem *terminate = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [self terminateSessions];
        
        
    } description:NSLocalizedString(@"AuthSessions.TerminateOtherSessions", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
    }];
    
    
    [self.tableView insert:terminate atIndex:self.tableView.count tableRedraw:NO];
    
    if(self.authorizations.count > 0) {
        
        GeneralSettingsBlockHeaderItem *otherHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"AuthSessions.OtherSessions", nil) height:62 flipped:NO];
        
        
        [self.tableView insert:otherHeader atIndex:self.tableView.count tableRedraw:NO];
        
        
        
        
        [self.tableView insert:self.authorizations startIndex:self.tableView.count tableRedraw:NO];
    }
   
    
    [self.tableView reloadData];

}

- (void)terminateSessions {
    
    confirm(NSLocalizedString(@"Confirm", nil), NSLocalizedString(@"Confirm.TerminateSessions", nil), ^ {
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_auth_resetAuthorizations create] successHandler:^(RPCRequest *request, id response) {
            
            alert(NSLocalizedString(@"Success", nil), NSLocalizedString(@"Confirm.SuccessResetSessions", nil));
            
            [self hideModalProgress];
            
            [self rebuild];
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [self hideModalProgress];
            
        } timeout:5];
    },nil);
    
    
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
    [_updateTimer invalidate];
    _updateTimer = nil;
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    if([item isKindOfClass:[GeneralSettingsRowItem class]] || [item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [(GeneralSettingsRowItem *)item height];
    }
    
    return 60;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
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
