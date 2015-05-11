//
//  TGStickerPackModalView.m
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickerPackModalView.h"
#import "TGAllStickersTableView.h"
#import "EmojiViewController.h"
@interface TGStickerPackModalView ()
@property (nonatomic,strong) TGAllStickersTableView *tableView;

@property (nonatomic,strong) TL_messages_stickerSet *pack;
@property (nonatomic,strong) BTRButton *addButton;
@property (nonatomic,strong) TMTextField *nameField;
@end

@implementation TGStickerPackModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        [self setContainerFrameSize:NSMakeSize(300, 300)];
        
        _tableView = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 80 )];
        
        [self addSubview:_tableView.containerView];
    
        
        TMView *view = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, self.containerSize.width, 1)];
        
        view.backgroundColor = GRAY_BORDER_COLOR;
        
        _addButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, 50)];
        
        [_addButton setTitleFont:TGSystemFont(14) forControlState:BTRControlStateNormal];
        
        [_addButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_addButton setTitle:NSLocalizedString(@"StickerPack.AddStickerPack", nil) forControlState:BTRControlStateNormal];
        
        weak();
        
        [_addButton addBlock:^(BTRControlEvents events) {
            
            
            [RPCRequest sendRequest:[TLAPI_messages_installStickerSet createWithStickerset:[TL_inputStickerSetID createWithN_id:weakSelf.pack.set.n_id access_hash:weakSelf.pack.set.access_hash]] successHandler:^(id request, id response) {
                
                [weakSelf close:YES];
                
                [EmojiViewController reloadStickers];
                
            } errorHandler:^(id request, RpcError *error) {
                
            } timeout:10];
            
        } forControlEvents:BTRControlEventClick];
        
        
        [_addButton addSubview:view];
        [self addSubview:_addButton];
        
        
        _nameField = [TMTextField defaultTextField];
        
        [_nameField setFrame:NSMakeRect(0, self.containerSize.height - 30, self.containerSize.width, 27)];
        [_nameField setAlignment:NSCenterTextAlignment];
        [_nameField setTextColor:TEXT_COLOR];
        [_nameField setFont:TGSystemFont(13)];
        
        [self addSubview:_nameField];
        
        TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, self.containerSize.height - 30, self.containerSize.width, 1)];
        
        separator.backgroundColor = GRAY_BORDER_COLOR;
        
        [self addSubview:separator];

    }
    
    return self;
}

-(void)setStickerPack:(TL_messages_stickerSet *)stickerPack {
    
    _pack = stickerPack;
    
    
    [_nameField setStringValue:_pack.set.title];
    
    
    [_tableView showWithStickerPack:stickerPack];
    
    __block BOOL packIsset = NO;
    
    [[stickerPack documents] enumerateObjectsUsingBlock:^(TLDocument *obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *filter = [[EmojiViewController allStickers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
        
        if(filter.count > 0) {
            packIsset = YES;
            *stop = YES;
        }
        
    }];
    
    
    [_tableView.containerView setFrame:NSMakeRect(0, packIsset ? 0 : 50, self.containerSize.width, packIsset ? self.containerSize.height - 30 : self.containerSize.height - 80)];
    
    [_addButton setHidden:packIsset];
    
    [_addButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"StickerPack.AddStickerPack", nil),stickerPack.documents.count] forControlState:BTRControlStateNormal];
        
}


@end
