//
//  TGSingleMediaSenderModalView.m
//  Telegram
//
//  Created by keepcoder on 20/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGSingleMediaSenderModalView.h"
#import "TGSettingsTableView.h"
#import "TGGeneralInputRowItem.h"
#import "TGSingleMediaPreviewRowItem.h"
@interface TGSingleMediaSenderModalView ()
@property (nonatomic,strong) NSString *filepath;
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGGeneralInputRowItem *inputItem;

@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,weak) MessagesViewController *messagesViewController;
@property (nonatomic,assign) PasteBoardItemType ptype;
@end

@implementation TGSingleMediaSenderModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(350, 270)];
        
        [self enableCancelAndOkButton];
        
        [self.ok setTitle:NSLocalizedString(@"Message.Send", nil) forControlState:BTRControlStateNormal];
        
        _tableView = [[TGSettingsTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 50)];
        
        [self addSubview:_tableView.containerView];
    }
    
    return self;
}



-(void)okAction {
    if(_ptype == PasteBoardItemTypeVideo) {
        [_messagesViewController sendVideo:_filepath forConversation:_conversation caption:_inputItem.result.string addCompletionHandler:nil];
    } else
        [_messagesViewController sendDocument:_filepath forConversation:_conversation caption:_inputItem.result.string addCompletionHandler:nil];
    
    [self close:YES];
}

-(void)cancelAction {
    [self close:YES];
}


-(void)show:(NSWindow *)window animated:(BOOL)animated {
    [NSException raise:@"use show:animated:file:" format:@""];
}

-(void)show:(NSWindow *)window animated:(BOOL)animated file:(NSString *)filepath ptype:(PasteBoardItemType)ptype conversation:(TL_conversation *)conversation messagesViewController:(MessagesViewController *)messagesViewController {
    [super show:window animated:animated];
    
    
    _messagesViewController = messagesViewController;
    _conversation = conversation;
    _filepath = filepath;
    _ptype = ptype;
    
    TGSingleMediaPreviewRowItem *previewItem = [[TGSingleMediaPreviewRowItem alloc] initWithObject:filepath ptype:ptype];
    
    [_tableView addItem:previewItem tableRedraw:YES];
    
    
    _inputItem = [[TGGeneralInputRowItem alloc] init];
    
    _inputItem.placeholder = NSLocalizedString(@"Media.AddCaptionPlaceholder", nil);
    
    
    [_tableView addItem:_inputItem tableRedraw:YES];
    
    
    
    
    
//    GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Media.AddFileCaptionDesc", nil) height:50 flipped:YES];
//    
//    
//    [_tableView addItem:description tableRedraw:YES];
    
    
    
}





-(void)dealloc {
    [_tableView clear];
}

@end

