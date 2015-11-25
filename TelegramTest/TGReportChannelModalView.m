//
//  TGReportChannelModalView.m
//  Telegram
//
//  Created by keepcoder on 20/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGReportChannelModalView.h"
#import "TGSettingsTableView.h"
#import "TGGeneralInputRowItem.h"
@interface TGReportChannelModalView ()
@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) id reason;
@end

@implementation TGReportChannelModalView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(300, 248)];
        
        
        [self initialize];
    }
    
    return self;
}


-(void)configure {
    [self.tableView removeAllItems:YES];
    
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:10] tableRedraw:YES];
    
    GeneralSettingsRowItem *spam = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        _reason = [TL_inputReportReasonSpam create];
        [self configure];
        
    } description:NSLocalizedString(@"Report.ReportSpam", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([_reason isKindOfClass:[TL_inputReportReasonSpam class]]);
    }];
    
    GeneralSettingsRowItem *violence = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        _reason = [TL_inputReportReasonViolence create];
        [self configure];
        
    } description:NSLocalizedString(@"Report.ReportViolence", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([_reason isKindOfClass:[TL_inputReportReasonViolence class]]);
    }];
    
    GeneralSettingsRowItem *porno = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        _reason = [TL_inputReportReasonPornography create];
        [self configure];
        
    } description:NSLocalizedString(@"Report.ReportPorno", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([_reason isKindOfClass:[TL_inputReportReasonPornography class]]);
    }];
    
    TGGeneralInputRowItem *other = [[TGGeneralInputRowItem alloc] initWithHeight:42];
    other.placeholder = NSLocalizedString(@"Report.ReportOther", nil);
    
    [other setCallback:^(TGGeneralRowItem *item) {
        BOOL needConfigure = ![_reason isKindOfClass:[TL_inputReportReasonOther class]];
        _reason = [TL_inputReportReasonOther createWithText:other.result.string];
        if(needConfigure)
            [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }];
    
    spam.xOffset = violence.xOffset = porno.xOffset = other.xOffset = 0;
    
    [_tableView addItem:spam tableRedraw:YES];
    [_tableView addItem:violence tableRedraw:YES];
    [_tableView addItem:porno tableRedraw:YES];
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20]  tableRedraw:YES];
    [_tableView addItem:other tableRedraw:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];

}

-(void)okAction {
    [super okAction];
    
    
    [TMViewController showModalProgress];
    
    [self close:YES];
    
    [RPCRequest sendRequest:[TLAPI_account_reportPeer createWithPeer:_conversation.inputPeer reason:_reason] successHandler:^(id request, id response) {
        
        [TMViewController hideModalProgress];
        
        alert(NSLocalizedString(@"Report.AlertText", nil), NSLocalizedString(@"Report.AlertDescription", nil));
        
    } errorHandler:^(id request, RpcError *error) {
        [TMViewController hideModalProgress];
    }];
}

-(void)cancelAction {
    [super cancelAction];
}

-(void)initialize {
    _tableView = [[TGSettingsTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 50)];
    
    [self addSubview:_tableView.containerView];
    
    _reason = [TL_inputReportReasonSpam create];
    
    [self configure];
    
    [self enableCancelAndOkButton];
}

@end
