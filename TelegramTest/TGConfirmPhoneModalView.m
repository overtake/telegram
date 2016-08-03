//
//  TGConfirmPhoneModalView.m
//  Telegram
//
//  Created by keepcoder on 27/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGConfirmPhoneModalView.h"
#import "TGSettingsTableView.h"
#import "TGGeneralInputRowItem.h"
#import "RMPhoneFormat.h"
#import "TGSignalUtils.h"
#import "TGGeneralInputTextRowView.h"
@interface TGConfirmPhoneModalView ()

@property (nonatomic,strong) TLauth_SentCode *sentCode;
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) id <SDisposable> willCallDispose;
@property (nonatomic,strong) TGGeneralInputRowItem *inputItem;

@end

@implementation TGConfirmPhoneModalView

-(void)okAction {

    
    [RPCRequest sendRequest:[TLAPI_account_confirmPhone createWithPhone_code_hash:_sentCode.phone_code_hash phone_code:_inputItem.result.string] successHandler:^(id request, id response) {
        
        if([response isKindOfClass:[TL_boolTrue class]]) {
            [self close:NO];
            alert(NSLocalizedString(@"AccountReset.SuccessHeader", nil), [NSString stringWithFormat:NSLocalizedString(@"AccountReset.Success", nil),[UsersManager currentUser].phoneWithFormat]);
        } else {
            alert(appName(), @"AccountReset.Error");
        }
        
        
    } errorHandler:^(id request, RpcError *error) {
        alert(appName(), NSLocalizedString(@"AccountReset.IncorrectCode", nil));
    }];
}



-(void)show:(NSWindow *)window animated:(BOOL)animated response:(TLauth_SentCode *)response {
    
    
    _sentCode = response;
    
    [self setContainerFrameSize:NSMakeSize(300, 300)];
    
    [self enableCancelAndOkButton];

    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:NSMakeRect(0, 50, 300, 250)];
    
    [self addSubview:_tableView.containerView];
    
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];
    
    _inputItem = [[TGGeneralInputRowItem alloc] init];
    [_inputItem setPlaceholder:NSLocalizedString(@"Account.Code", nil)];
    [_inputItem setLimit:_sentCode.type.length];
    
    [_tableView addItem:_inputItem tableRedraw:NO];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];

    
    NSString *desc = [NSString stringWithFormat:NSLocalizedString(@"Account.CancelReset", nil),[UsersManager currentUser].phoneWithFormat];
    
    [_tableView addItem:[[GeneralSettingsBlockHeaderItem alloc] initWithString:desc flipped:NO] tableRedraw:NO];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];

    
    [_tableView reloadData];
    
    if([_sentCode.next_type isKindOfClass:[TL_auth_sentCodeTypeCall class]]) {
        [self runTimer:_sentCode.timeout];

    }
    
    [super show:window animated:animated];
}

-(BOOL)becomeFirstResponder {
    @try {
        TGGeneralInputTextRowView *view = (TGGeneralInputTextRowView *) [self.tableView rowViewAtRow:0 makeIfNecessary:NO].subviews[0];
        
        if(view)
            return [view becomeFirstResponder];
        
    } @catch (NSException *exception) {
        
    }
    
    return [super becomeFirstResponder];
}

-(void)runTimer:(int)t {
    
    
    GeneralSettingsBlockHeaderItem *timerItem  = [[GeneralSettingsBlockHeaderItem alloc] initWithString:@"" flipped:NO];

    [_tableView addItem:timerItem tableRedraw:YES];
    
    _willCallDispose = [[TGSignalUtils countdownSignal:t delay:1] startWithNext:^(id next) {
       
        NSString *willCall = @"";
        
        if([next intValue] > 0) {
            int minutes = [next intValue] / 60;
            int sec = [next intValue] % 60;
            NSString *secStr = sec > 9 ? [NSString stringWithFormat:@"%d", sec] : [NSString stringWithFormat:@"0%d", sec];
            
            willCall = [NSString stringWithFormat:NSLocalizedString(@"Login.willCallYou", nil), minutes, secStr];
            
            
        } else {
            willCall = NSLocalizedString(@"Registration.PhoneDialed", nil);
        }
        
        [timerItem updateWithString:willCall];
        
        [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_tableView indexOfItem:timerItem]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];

        
    }];
    
}

-(void)modalViewDidHide {
    [_willCallDispose dispose];
}


@end
