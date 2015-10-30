//
//  LastSeenViewController.m
//  Telegram
//
//  Created by keepcoder on 19.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacySettingsViewController.h"
#import "GeneralSettingsRowItem.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "ComposeActionCustomBehavior.h"
#import "SelectUserItem.h"
#import "NewContactsManager.h"
@interface PrivacySettingsViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTextButton *doneButton;
@property (nonatomic,strong) TMTableView *tableView;

@property (nonatomic,strong) PrivacyArchiver *changedPrivacy;
@property (nonatomic,strong) PrivacyArchiver *privacy;

@property (nonatomic,strong) GeneralSettingsRowItem *allowSelector;
@property (nonatomic,strong) GeneralSettingsRowItem *disallowSelector;

@property (nonatomic,strong) ComposeAction *allowUsersAction;
@property (nonatomic,strong) ComposeAction *disallowUsersAction;

@end

@implementation PrivacySettingsViewController

-(void)loadView {
    [super loadView];
    
    
    weakify();
    
    self.allowUsersAction = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionCustomBehavior class]];
    
    self.disallowUsersAction = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionCustomBehavior class]];
    
    
    ((ComposeActionCustomBehavior *)self.allowUsersAction.behavior).composeDone = ^ {
        
        NSMutableArray *added = [[NSMutableArray alloc] init];
        
        [strongSelf.allowUsersAction.result.multiObjects enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            [added addObject:@(obj.n_id)];
        }];
        
        strongSelf.changedPrivacy.allowUsers = [strongSelf.changedPrivacy.allowUsers arrayByAddingObjectsFromArray:added];
        
        NSMutableArray *cleared = [strongSelf.changedPrivacy.disallowUsers mutableCopy];
        
        [cleared removeObjectsInArray:added];
        
        strongSelf.changedPrivacy.disallowUsers = cleared;
        
         strongSelf.changedPrivacy = strongSelf.changedPrivacy;
        
        [strongSelf.navigationViewController goBackWithAnimation:YES];
        
    };
    
    ((ComposeActionCustomBehavior *)self.disallowUsersAction.behavior).composeDone = ^ {
        NSMutableArray *added = [[NSMutableArray alloc] init];
        
        [strongSelf.disallowUsersAction.result.multiObjects enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            [added addObject:@(obj.n_id)];
        }];
        
        strongSelf.changedPrivacy.disallowUsers = [strongSelf.changedPrivacy.disallowUsers arrayByAddingObjectsFromArray:added];
        
        NSMutableArray *cleared = [strongSelf.changedPrivacy.allowUsers mutableCopy];
        
        [cleared removeObjectsInArray:added];
        
        strongSelf.changedPrivacy.allowUsers = cleared;
        
        strongSelf.changedPrivacy = strongSelf.changedPrivacy;
        
        [strongSelf.navigationViewController goBackWithAnimation:YES];
    };
    
    ((ComposeActionCustomBehavior *)self.allowUsersAction.behavior).customDoneTitle = @"Done";
    ((ComposeActionCustomBehavior *)self.allowUsersAction.behavior).customCenterTitle = NSLocalizedString(@"PrivacySettingsController.AlwaysShare", nil);
    
    ((ComposeActionCustomBehavior *)self.disallowUsersAction.behavior).customDoneTitle = @"Done";
    ((ComposeActionCustomBehavior *)self.disallowUsersAction.behavior).customCenterTitle = NSLocalizedString(@"PrivacySettingsController.NeverShare", nil);
    
    [self setCenterBarViewText:NSLocalizedString(@"PrivacySettingsController.Header", nil)];
    
    
    TMView *rightView = [[TMView alloc] init];
    
    
    self.doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:@"Done"];
    
    [self.doneButton setDisableColor:GRAY_BORDER_COLOR];
    
    
    [self.doneButton setTapBlock:^{
        [strongSelf savePrivacy];
    }];
    
    [rightView setFrameSize:self.doneButton.frame.size];
    
    
    [rightView addSubview:self.doneButton];
    
    [self setRightNavigationBarView:rightView animated:NO];

    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
    GeneralSettingsRowItem *everbody = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        self.changedPrivacy.allowType = PrivacyAllowTypeEverbody;
        self.changedPrivacy = self.changedPrivacy;
        
    } description:NSLocalizedString(@"PrivacySettingsController.Everbody", nil) height:70 stateback:^id(TGGeneralRowItem *item) {
        return @(self.changedPrivacy.allowType == PrivacyAllowTypeEverbody);
    }];
    
    [self.tableView insert:everbody atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *myContacts = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        self.changedPrivacy.allowType = PrivacyAllowTypeContacts;
        self.changedPrivacy = self.changedPrivacy;
        
    } description:NSLocalizedString(@"PrivacySettingsController.MyContacts", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(self.changedPrivacy.allowType == PrivacyAllowTypeContacts);
    }];
    
    [self.tableView insert:myContacts atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *nobody = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        self.changedPrivacy.allowType = PrivacyAllowTypeNobody;
        self.changedPrivacy = self.changedPrivacy;
        
    } description:NSLocalizedString(@"PrivacySettingsController.Nobody", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(self.changedPrivacy.allowType == PrivacyAllowTypeNobody);
    }];
    
    [self.tableView insert:nobody atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    self.allowSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        if(self.changedPrivacy.allowUsers.count == 0) {
            [[Telegram rightViewController] showComposeWithAction:self.allowUsersAction];
        } else {
            [[Telegram rightViewController] showPrivacyUserListController:self.changedPrivacy arrayKey:@"allowUsers" addCallback:^{
                
                [[Telegram rightViewController] showComposeWithAction:self.allowUsersAction];
                
            } title:NSLocalizedString(@"PrivacySettingsController.AlwaysShare", nil)];
        }
        
    } description:NSLocalizedString(@"PrivacySettingsController.AlwaysShareWith", nil) subdesc:@"5 users" height:42 stateback:nil];
    
    
    self.disallowSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        if(self.changedPrivacy.disallowUsers.count == 0) {
            [[Telegram rightViewController] showComposeWithAction:self.disallowUsersAction];
        } else {
            [[Telegram rightViewController] showPrivacyUserListController:self.changedPrivacy arrayKey:@"disallowUsers" addCallback:^{
                [[Telegram rightViewController] showComposeWithAction:self.disallowUsersAction];
            } title:NSLocalizedString(@"PrivacySettingsController.NeverShare", nil)];
        }
        
       
        
    } description:NSLocalizedString(@"PrivacySettingsController.NeverShareWith", nil) subdesc:@"2 users" height:42 stateback:nil];
    
    [self.tableView insert:nobody atIndex:self.tableView.list.count tableRedraw:NO];
    
    [self.tableView reloadData];
    
}



-(void)setPrivacy:(PrivacyArchiver *)privacy {
    _privacy = privacy;
    
    [self view];
    
    self.changedPrivacy = [_privacy copy];
}

-(void)savePrivacy {
    
    id pk;
    
    if([self.changedPrivacy.privacyType isEqualToString:kStatusTimestamp])
        pk = [TL_inputPrivacyKeyStatusTimestamp create];
    
    
    
    [self showModalProgress];
    
    [RPCRequest sendRequest:[TLAPI_account_setPrivacy createWithN_key:pk rules:[[self.changedPrivacy rules] mutableCopy]] successHandler:^(RPCRequest *request, id response) {
        
        self.privacy = self.changedPrivacy;
        [self.privacy _save];
        
        self.changedPrivacy = [self.privacy copy];
        
       
        [[NewContactsManager sharedManager] getStatuses:^ {
           
            [self hideModalProgress];
            
            [self.navigationViewController goBackWithAnimation:YES];
            
        }];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self hideModalProgress];
    } timeout:15];;
    
}

-(void)setChangedPrivacy:(PrivacyArchiver *)changedPrivacy {
    _changedPrivacy = changedPrivacy;
    
    [self.tableView removeItem:self.allowSelector tableRedraw:NO];
    [self.tableView removeItem:self.disallowSelector tableRedraw:NO];
    
    switch (_changedPrivacy.allowType) {
        case PrivacyAllowTypeContacts:
            self.disallowSelector.height = 80;
            self.allowSelector.height = 42;
            [self.tableView addItem:self.disallowSelector tableRedraw:NO];
            [self.tableView addItem:self.allowSelector tableRedraw:NO];
            break;
        case PrivacyAllowTypeEverbody:
            self.disallowSelector.height = 80;
            [self.tableView addItem:self.disallowSelector tableRedraw:NO];
            break;
        case PrivacyAllowTypeNobody:
            self.allowSelector.height = 80;
            [self.tableView addItem:self.allowSelector tableRedraw:NO];
        default:
            break;
    }
    
    [self.allowSelector setSubdesc:self.changedPrivacy.allowUsers.count == 0 ? NSLocalizedString(@"PrivacySettingsController.AddUsers", nil) : [NSString stringWithFormat:self.changedPrivacy.allowUsers.count == 1 ? NSLocalizedString(@"PrivacySettingsController.UserCount", nil) : NSLocalizedString(@"PrivacySettingsController.UsersCount", nil),self.changedPrivacy.allowUsers.count]];
    
    [self.disallowSelector setSubdesc:self.changedPrivacy.disallowUsers.count == 0 ? NSLocalizedString(@"PrivacySettingsController.AddUsers", nil) : [NSString stringWithFormat:self.changedPrivacy.disallowUsers.count == 1 ? NSLocalizedString(@"PrivacySettingsController.UserCount", nil) : NSLocalizedString(@"PrivacySettingsController.UsersCount", nil),self.changedPrivacy.disallowUsers.count]];

    
    [self.tableView reloadData];
    [self checkDone];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.changedPrivacy = self.changedPrivacy;
    
    [Notification addObserver:self selector:@selector(didPrivacyUpdated:) name:PRIVACY_UPDATE];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}

-(void)didPrivacyUpdated:(NSNotification *)notification {
    
    PrivacyArchiver *privacy = notification.userInfo[KEY_PRIVACY];
    
    if([privacy.privacyType isEqualToString:self.privacy.privacyType]) {
        self.privacy = privacy;
        
        self.changedPrivacy = [privacy copy];
    }
    
}


-(void)checkDone {
    
    BOOL isChanged = NO;
    
    isChanged = isChanged || self.privacy.allowType != self.changedPrivacy.allowType;
    
    isChanged = isChanged || ![self.privacy.allowUsers isEqualToArray:self.changedPrivacy.allowUsers];
    
    isChanged = isChanged || ![self.privacy.disallowUsers isEqualToArray:self.changedPrivacy.disallowUsers];
    
    [self.doneButton setDisable:!isChanged];
    
}

- (CGFloat)rowHeight:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowViewClass"];
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}


@end
