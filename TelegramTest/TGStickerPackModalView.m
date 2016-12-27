//
//  TGStickerPackModalView.m
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickerPackModalView.h"
#import "TGAllStickersTableView.h"
#import "TGMessagesStickerImageObject.h"
#import "TGImageView.h"
#import "TGModernESGViewController.h"
#import "TGModalArchivedPacks.h"
#import "TLStickerSet+Extension.h"
@interface TGStickerPackModalView ()<TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) TGAllStickersTableView *tableView;

@property (nonatomic,strong) TL_messages_stickerSet *pack;
@property (nonatomic,strong) BTRButton *addButton;
@property (nonatomic,strong) TMView *bottomView;
@property (nonatomic,strong) BTRButton *cLink;
@end

@implementation TGStickerPackModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(int)bottomOffset {
    return 50;
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        [self setContainerFrameSize:NSMakeSize(384, 380)];
        
        
        
        
        _tableView = [[TGAllStickersTableView alloc] initWithFrame:NSZeroRect];
        

        
        [self addSubview:_tableView.containerView];
        
        weak();

        
        _bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, 50)];
        
        [_bottomView setDrawBlock:^{
            
            [GRAY_BORDER_COLOR set];
            NSRectFill(NSMakeRect(0, NSHeight(weakSelf.bottomView.frame) - DIALOG_BORDER_WIDTH, NSWidth(weakSelf.bottomView.frame), DIALOG_BORDER_WIDTH));
        }];
        
        self.bottomView.backgroundColor = [NSColor whiteColor];
        
        
        [self addSubview:_bottomView];
    
        
        
        _addButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 130, 27)];
        
        [_addButton setTitleFont:TGSystemMediumFont(14) forControlState:BTRControlStateNormal];
        
        [_addButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_addButton setTitle:NSLocalizedString(@"StickerPack.AddStickerPack", nil) forControlState:BTRControlStateNormal];
        
        
        [_addButton addBlock:^(BTRControlEvents events) {
            
            
            [weakSelf close:NO];
            
            if(weakSelf.addcallback != nil)
            {
                weakSelf.addcallback();
                
                return;
            }
            
            [TMViewController showModalProgress];
            
            
            [[MessageSender addStickerPack:weakSelf.pack] startWithNext:^(id next) {
                
            }];
                        
        } forControlEvents:BTRControlEventMouseDownInside];
        
        
        [_addButton setCenterByView:_bottomView];
        
        [_bottomView addSubview:_addButton];
        
        
    }
    
    return self;
}


-(void)textField:(id)textField handleURLClick:(NSString *)url {
    
    
    [self close:NO];
    
    [TMViewController showModalProgress];
    
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    
    [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
    [cb setString:[NSString stringWithFormat:@"https://telegram.me/addstickers/%@",_pack.set.short_name] forType:NSStringPboardType];
    
    dispatch_after_seconds(0.2, ^{
        [TMViewController hideModalProgressWithSuccess];
    });
    
   
}

-(void)setCanSendSticker:(BOOL)canSendSticker {
    _canSendSticker = canSendSticker;
    _tableView.canSendStickerAlways = canSendSticker;
}



-(void)show:(NSWindow *)window animated:(BOOL)animated stickerPack:(TL_messages_stickerSet *)stickerPack messagesController:(MessagesViewController *)messagesViewController {
    
    _messagesViewController = messagesViewController;
    _tableView.messagesViewController = messagesViewController;
    _pack = stickerPack;
    
    [self enableHeader:stickerPack.set.title];
    
   
    
    __block BOOL packIsset = [TGModernESGViewController setWithId:stickerPack.set.n_id] != nil;
    
    
    NSUInteger dif = ceil((float)stickerPack.documents.count/5.0);
    
    if(dif < 4) {
        [self setContainerFrameSize:NSMakeSize(self.containerSize.width, (packIsset ? 0 : 50) + self.topOffset + dif*80)];
    }
    
    _cLink = [[BTRButton alloc] initWithFrame:NSMakeRect( roundf((self.topOffset - image_StickerLink().size.height)/2.0f), self.containerSize.height - image_StickerLink().size.height - roundf((self.topOffset - image_StickerLink().size.height)/2.0f), image_StickerLink().size.width, image_StickerLink().size.height)];
    
    [_cLink setImage:[image_StickerLink() imageTintedWithColor:BLUE_ICON_COLOR] forControlState:BTRControlStateNormal];
    
    
    [_cLink addBlock:^(BTRControlEvents events) {
        
        [TMViewController showModalProgressWithDescription:NSLocalizedString(@"Conversation.CopyToClipboard", nil)];
        
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        
        [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
        [cb setString:[NSString stringWithFormat:@"https://telegram.me/addstickers/%@",stickerPack.set.short_name] forType:NSStringPboardType];
        
        dispatch_after_seconds(0.2, ^{
            [TMViewController hideModalProgressWithSuccess];
        });
        
    } forControlEvents:BTRControlEventClick];
    
    [self addSubview:_cLink];
    
    
    [_tableView.containerView setFrame:NSMakeRect(0, (!packIsset ? self.bottomOffset : 0), self.containerSize.width, self.containerSize.height - (!packIsset ? self.bottomOffset : 0) - self.topOffset )];
    
    
    [self addScrollEvent:_tableView];
    
    [super show:window animated:animated];

    
    [_tableView showWithStickerPack:stickerPack];

    [_bottomView setHidden:packIsset || stickerPack.set.isMasks];
    
    [_addButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"StickerPack.AddStickerPack", nil),stickerPack.documents.count] forControlState:BTRControlStateNormal];
    
    
    [_addButton setTitleFont:TGSystemFont(14) forControlState:BTRControlStateNormal];
    
    
    
}


-(void)_didScrolledTableView:(NSNotification *)notification {
    self.drawHeaderSeparator = _tableView.scrollView.documentOffset.y > 0;
}




-(void)modalViewDidHide {
    
    int bp = 0;
}

-(void)modalViewDidShow {
    [super modalViewDidShow];
    [self.window makeFirstResponder:self.tableView];
    [self.tableView becomeFirstResponder];
}

-(void)dealloc {
    [_tableView clear];
}




@end
