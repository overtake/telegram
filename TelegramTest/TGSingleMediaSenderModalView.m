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
#import "TGGeneralInputTextRowView.h"
#import "TGPopoverHint.h"
@interface TGSingleMediaSenderModalView ()
@property (nonatomic,strong) NSString *filepath;
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGGeneralInputRowItem *inputItem;

@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,weak) MessagesViewController *messagesViewController;
@property (nonatomic,assign) BOOL sendAsCompressed;
@property (nonatomic,strong) TGSingleMediaPreviewRowItem *item;

@property (nonatomic,assign) BOOL sent;
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

-(void)keyUp:(NSEvent *)theEvent {
    if(theEvent.keyCode == 53) {
        [self close:YES];
    } else if(isEnterAccess(theEvent)) {
        
        if(![TGPopoverHint isShown]) {
            [self okAction];
        } else {
            [[TGPopoverHint hintView] performSelected];
        }

    } else {
        [self becomeFirstResponder];
    }
}


-(void)okAction {
    
    [self close:YES];
    
    if(!_sent) {
        
        _sent = YES;
        
        if(_item.ptype == PasteBoardItemTypeVideo)
            [_messagesViewController sendVideo:_filepath forConversation:_conversation caption:_inputItem.result.string addCompletionHandler:nil];
        else if(_item.ptype == PasteBoardItemTypeDocument)
            [_messagesViewController sendDocument:_filepath forConversation:_conversation caption:_inputItem.result.string addCompletionHandler:nil];
        else if(_item.ptype == PasteBoardItemTypeImage) {
            if(_sendAsCompressed)
                [_messagesViewController sendImage:_filepath forConversation:_conversation file_data:_item.data caption:_inputItem.result.string];
            else {
                if(!_filepath) {
                    _filepath = exportPath(rand_long(), @"jpg");
                    [_item.data writeToFile:_filepath atomically:YES];
                }
                
                [_messagesViewController sendDocument:_filepath forConversation:_conversation caption:_inputItem.result.string addCompletionHandler:nil];
            }
            
        }
    }

    
}

-(void)cancelAction {
    [self close:YES];
}

-(BOOL)becomeFirstResponder {
    
    @try {
        TGGeneralInputTextRowView *view = (TGGeneralInputTextRowView *) [self.tableView rowViewAtRow:_item.ptype != PasteBoardItemTypeImage ? 1 : 3 makeIfNecessary:NO].subviews[0];

        
        if(view)
            return [view becomeFirstResponder];
        
    } @catch (NSException *exception) {
        
    }
    
    return [super becomeFirstResponder];
}


-(void)show:(NSWindow *)window animated:(BOOL)animated {
    [NSException raise:@"use show:animated:file:" format:@""];
}

-(void)show:(NSWindow *)window animated:(BOOL)animated file:(NSString *)filepath filedata:(NSData *)filedata ptype:(PasteBoardItemType)ptype caption:(NSString *)caption conversation:(TL_conversation *)conversation messagesViewController:(MessagesViewController *)messagesViewController {
    
    
    _messagesViewController = messagesViewController;
    _conversation = conversation;
    _filepath = filepath;
    _sendAsCompressed = YES;
    
    _item = [[TGSingleMediaPreviewRowItem alloc] initWithObject:filepath ptype:ptype data:filedata];
    
    [_tableView addItem:_item tableRedraw:YES];
    
    if(ptype == PasteBoardItemTypeImage) {
        [_tableView addItem:[[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
            
            _sendAsCompressed = !_sendAsCompressed;
            
            [_tableView reloadData];
            
        } description:NSLocalizedString(@"SendMedia.SendAsCompressed", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return @(_sendAsCompressed);
        }] tableRedraw:YES];
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];

    }

    
    
    _inputItem = [[TGGeneralInputRowItem alloc] init];
    if(caption.length > 0)
        _inputItem.result = [[NSAttributedString alloc] initWithString:caption];
    _inputItem.placeholder = NSLocalizedString(@"Media.AddCaptionPlaceholder", nil);
    _inputItem.hintAbility = YES;
    
    weak();
    [_inputItem setCallback:^(TGGeneralRowItem *item) {
        
        [weakSelf setContainerFrameSize:NSMakeSize(350, weakSelf.tableView.tableHeight + 50 + 40)];

        
    }];
    
    
    [_tableView addItem:_inputItem tableRedraw:YES];
    
    
    [self setContainerFrameSize:NSMakeSize(350, weakSelf.tableView.tableHeight + 50 + 40)];
    
    
    [super show:window animated:animated];

}





-(void)dealloc {
    [_tableView clear];
}

@end

