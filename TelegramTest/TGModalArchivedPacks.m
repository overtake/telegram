//
//  TGModalArchivedPacks.m
//  Telegram
//
//  Created by keepcoder on 21/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModalArchivedPacks.h"
#import "TGSettingsTableView.h"
#import "TGStickerPackRowItem.h"
#import "TGModernESGViewController.h"
@interface TGModalArchivedPacks ()
@property (nonatomic,strong) TGSettingsTableView *tableView;

@end

@implementation TGModalArchivedPacks


@synthesize ok = _ok;


-(void)okAction {
    [self close:YES];
}

-(void)show:(NSWindow *)window animated:(BOOL)animated sets:(NSArray *)sets documents:(NSDictionary *)documents {
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:NSMakeRect(0, 50, 300, 300)];
    
    [self addSubview:_tableView.containerView];

    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    GeneralSettingsBlockHeaderItem *desc = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Stickers.WillArchived", nil) flipped:YES];
    desc.autoHeight = YES;
    [desc setAligment:NSCenterTextAlignment];
    
    [_tableView addItem:desc tableRedraw:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(documents[@(set.n_id)] && [documents[@(set.n_id)] count] > 0) {
            TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:@{@"set":set,@"stickers":documents[@(set.n_id)]}];
            
            [_tableView addItem:item tableRedraw:YES];
        }
        
    }];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    
    [self setContainerFrameSize:NSMakeSize(300, _tableView.tableHeight + 50)];

    
    [_tableView.containerView setFrame:NSMakeRect(0, 50, 300, self.containerSize.height - 50)];
    
    weak();
    
    _ok = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, 49)];
    _ok.autoresizingMask = NSViewWidthSizable;
    _ok.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_ok setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_ok setTitleFont:TGSystemFont(15) forControlState:BTRControlStateNormal];
    [_ok setTitle:NSLocalizedString(@"OK", nil) forControlState:BTRControlStateNormal];
    
    [_ok addBlock:^(BTRControlEvents events) {
        
        [weakSelf okAction];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    [self addSubview:_ok];
    
    TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, self.containerSize.width, 1)];
    [separator setBackgroundColor:DIALOG_BORDER_COLOR];
    
    separator.autoresizingMask = NSViewWidthSizable;
    [self addSubview:separator];
    
    
    [super show:window animated:animated];
}

-(void)modalViewDidHide {
    [_tableView clear];
}

@end
