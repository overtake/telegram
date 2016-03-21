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
#import "TGSettingsTableView.h"
@interface PrivacySettingsViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTextButton *doneButton;
@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) PrivacyArchiver *changedPrivacy;
@property (nonatomic,strong) PrivacyArchiver *privacy;

@property (nonatomic,strong) GeneralSettingsRowItem *allowSelector;
@property (nonatomic,strong) GeneralSettingsRowItem *disallowSelector;

@property (nonatomic,strong) ComposeAction *allowUsersAction;
@property (nonatomic,strong) ComposeAction *disallowUsersAction;

@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *firstDescription;
@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *lastDescription;

@end

@implementation PrivacySettingsViewController

-(void)loadView {
    [super loadView];
    
    
    weak();
    
    self.allowUsersAction = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionCustomBehavior class]];
    
    self.disallowUsersAction = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionCustomBehavior class]];
    
    
    ((ComposeActionCustomBehavior *)self.allowUsersAction.behavior).composeDone = ^ {
        
        NSMutableArray *added = [[NSMutableArray alloc] init];
        
        [weakSelf.allowUsersAction.result.multiObjects enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            [added addObject:@(obj.n_id)];
        }];
        
        weakSelf.changedPrivacy.allowUsers = [weakSelf.changedPrivacy.allowUsers arrayByAddingObjectsFromArray:added];
        
        NSMutableArray *cleared = [weakSelf.changedPrivacy.disallowUsers mutableCopy];
        
        [cleared removeObjectsInArray:added];
        
        weakSelf.changedPrivacy.disallowUsers = cleared;
        
         weakSelf.changedPrivacy = weakSelf.changedPrivacy;
        
        [weakSelf.navigationViewController goBackWithAnimation:YES];
        
    };
    
    ((ComposeActionCustomBehavior *)self.disallowUsersAction.behavior).composeDone = ^ {
        NSMutableArray *added = [[NSMutableArray alloc] init];
        
        [weakSelf.disallowUsersAction.result.multiObjects enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            [added addObject:@(obj.n_id)];
        }];
        
        weakSelf.changedPrivacy.disallowUsers = [weakSelf.changedPrivacy.disallowUsers arrayByAddingObjectsFromArray:added];
        
        NSMutableArray *cleared = [weakSelf.changedPrivacy.allowUsers mutableCopy];
        
        [cleared removeObjectsInArray:added];
        
        weakSelf.changedPrivacy.allowUsers = cleared;
        
        weakSelf.changedPrivacy = weakSelf.changedPrivacy;
        
        [weakSelf.navigationViewController goBackWithAnimation:YES];
    };
    
   
    
    
    
    
    TMView *rightView = [[TMView alloc] init];
    
    
    self.doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Done", nil)];
    
    [self.doneButton setDisableColor:GRAY_BORDER_COLOR];
    
    
    [self.doneButton setTapBlock:^{
        [weakSelf savePrivacy];
    }];
    
    [rightView setFrameSize:self.doneButton.frame.size];
    
    
    [rightView addSubview:self.doneButton];
    
    [self setRightNavigationBarView:rightView animated:NO];

    
    self.tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    
    [self.view addSubview:self.tableView.containerView];
    
}



-(void)setPrivacy:(PrivacyArchiver *)privacy {
    _privacy = privacy;
    
    [self setCenterBarViewText:NSLocalizedString(privacy.privacyType, nil)];
    
    [self loadViewIfNeeded];
    
    NSString *allowDesc = [NSString stringWithFormat:@"PrivacySettingsController.AlwaysShare_%@",self.privacy.privacyType];
    NSString *disallowDesc = [NSString stringWithFormat:@"PrivacySettingsController.NeverShare_%@",self.privacy.privacyType];
    
    
    
    ((ComposeActionCustomBehavior *)self.allowUsersAction.behavior).customDoneTitle = NSLocalizedString(@"Done", nil);
    ((ComposeActionCustomBehavior *)self.allowUsersAction.behavior).customCenterTitle = NSLocalizedString(allowDesc, nil);
    
    ((ComposeActionCustomBehavior *)self.disallowUsersAction.behavior).customDoneTitle = NSLocalizedString(@"Done", nil);
    ((ComposeActionCustomBehavior *)self.disallowUsersAction.behavior).customCenterTitle = NSLocalizedString(disallowDesc, nil);
    
    [self reload];
    
    self.changedPrivacy = [_privacy copy];
    
    
    
}


-(void)reload {
    
    [self.tableView removeAllItems:YES];
    
    weak();
    
    GeneralSettingsRowItem *everbody = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        weakSelf.changedPrivacy.allowType = PrivacyAllowTypeEverbody;
        weakSelf.changedPrivacy = weakSelf.changedPrivacy;
        
    } description:NSLocalizedString(@"PrivacySettingsController.Everbody", nil) height:70 stateback:^id(TGGeneralRowItem *item) {
        return @(weakSelf.changedPrivacy.allowType == PrivacyAllowTypeEverbody);
    }];
    
    [self.tableView insert:everbody atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *myContacts = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        weakSelf.changedPrivacy.allowType = PrivacyAllowTypeContacts;
        weakSelf.changedPrivacy = weakSelf.changedPrivacy;
        
    } description:NSLocalizedString(@"PrivacySettingsController.MyContacts", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(weakSelf.changedPrivacy.allowType == PrivacyAllowTypeContacts);
    }];
    
    [self.tableView insert:myContacts atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    if(self.changedPrivacy.acceptNobodySetting) {
        GeneralSettingsRowItem *nobody = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
            
            weakSelf.changedPrivacy.allowType = PrivacyAllowTypeNobody;
            weakSelf.changedPrivacy = weakSelf.changedPrivacy;
            
        } description:NSLocalizedString(@"PrivacySettingsController.Nobody", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return @(weakSelf.changedPrivacy.allowType == PrivacyAllowTypeNobody);
        }];
        
        
        
        [self.tableView insert:nobody atIndex:self.tableView.list.count tableRedraw:NO];
    }
    
   
    
    
    NSString *first_desc = [NSString stringWithFormat:@"PRIVACY_FIRST_%@",self.privacy.privacyType];
    
    _firstDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(first_desc, nil) flipped:YES];
    
    [self.tableView addItem:_firstDescription tableRedraw:NO];
    
    
    self.allowSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        if(weakSelf.changedPrivacy.allowUsers.count == 0) {
            [[Telegram rightViewController] showComposeWithAction:weakSelf.allowUsersAction];
        } else {
            [[Telegram rightViewController] showPrivacyUserListController:weakSelf.changedPrivacy arrayKey:@"allowUsers" addCallback:^{
                
                [[Telegram rightViewController] showComposeWithAction:weakSelf.allowUsersAction];
                
            } title:NSLocalizedString(@"PrivacySettingsController.AlwaysShare", nil)];
        }
        
    } description:NSLocalizedString(@"PrivacySettingsController.AlwaysShareWith", nil) subdesc:@"5 users" height:42 stateback:nil];
    
    
    self.disallowSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        if(weakSelf.changedPrivacy.disallowUsers.count == 0) {
            [[Telegram rightViewController] showComposeWithAction:weakSelf.disallowUsersAction];
        } else {
            [[Telegram rightViewController] showPrivacyUserListController:weakSelf.changedPrivacy arrayKey:@"disallowUsers" addCallback:^{
                [[Telegram rightViewController] showComposeWithAction:weakSelf.disallowUsersAction];
            } title:NSLocalizedString(@"PrivacySettingsController.NeverShare", nil)];
        }
        
        
        
    } description:NSLocalizedString(@"PrivacySettingsController.NeverShareWith", nil) subdesc:@"2 users" height:42 stateback:nil];
    
    
    
    
    
    [self.tableView reloadData];
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
    
    NSString *allowDesc = [NSString stringWithFormat:@"PrivacySettingsController.AlwaysShare_%@",self.privacy.privacyType];
    NSString *disallowDesc = [NSString stringWithFormat:@"PrivacySettingsController.NeverShare_%@",self.privacy.privacyType];
    
    _disallowSelector.desc = NSLocalizedString(disallowDesc, nil);
    _allowSelector.desc = NSLocalizedString(allowDesc, nil);;
    
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
    
    [self.tableView removeItem:_lastDescription tableRedraw:NO];
    
    NSString *last_desc = [NSString stringWithFormat:@"PRIVACY_LAST_%@",self.privacy.privacyType];
    
    _lastDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(last_desc, nil) height:50 flipped:YES];
    
    [self.tableView addItem:_lastDescription tableRedraw:NO];

    
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


@end
