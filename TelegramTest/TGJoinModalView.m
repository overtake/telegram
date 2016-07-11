//
//  TGJoinModalView.m
//  Telegram
//
//  Created by keepcoder on 08/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGJoinModalView.h"
#import "TGTextLabel.h"
@interface TGJoinModalView ()
@property (nonatomic,strong) TLChatInvite *chatInvite;
@property (nonatomic,strong) NSString *n_hash;
@property (nonatomic,strong) TMAvatarImageView *photoImageView;
@property (nonatomic,strong) TGTextLabel *nameLabel;
@property (nonatomic,strong) TGTextLabel *infoLabel;
@property (nonatomic,strong) TMView *usersContainer;
@end

@implementation TGJoinModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self enableCancelAndOkButton];
        
        [self.ok setTitle:NSLocalizedString(@"Conversation.Action.Join", nil) forControlState:BTRControlStateNormal];
        
        _photoImageView = [TMAvatarImageView standartInfoAvatar];
        
        [self addSubview:_photoImageView];
        
        _nameLabel = [[TGTextLabel alloc] init];
        _infoLabel = [[TGTextLabel alloc] init];
        
        
        [self addSubview:_infoLabel];
        [self addSubview:_nameLabel];
        
        _usersContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        
        [self addSubview:_usersContainer];
        
    }
    
    return self;
}

-(void)okAction {
    [TMViewController showModalProgress];
    [self close:YES];

    [RPCRequest sendRequest:[TLAPI_messages_importChatInvite createWithN_hash:_n_hash] successHandler:^(RPCRequest *request, TLUpdates *response) {
        
        if([response chats].count > 0) {
            TLChat *chat = [response chats][0];
            
            TL_conversation *conversation = chat.dialog;
            
            [appWindow().navigationController showMessagesViewController:conversation];
            
            dispatch_after_seconds(0.2, ^{
                
                [TMViewController hideModalProgressWithSuccess];
            });
        } else {
            [TMViewController hideModalProgress];
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [TMViewController hideModalProgress];
        
        if(error.error_code == 400) {
            alert(appName(), NSLocalizedString(error.error_msg, nil));
        }
        
        
    }];

}


-(void)showWithChatInvite:(TLChatInvite *)chatInvite hash:(NSString *)hash {
    
    _chatInvite = chatInvite;
    _n_hash = hash;
    TLChat *fakeChat = [TL_chat createWithFlags:0 n_id:rand_int() title:chatInvite.title photo:chatInvite.photo participants_count:(int)chatInvite.participants_count date:0 version:0 migrated_to:nil];
    
    NSUInteger count = MIN(chatInvite.participants.count,4);
    
    NSSize usersContainerSize = NSMakeSize(MIN(200,count * 50 + (count - 1) * 25), count > 0 ? 70 : 0);
    
    [_usersContainer setFrameOrigin:NSMakePoint(0, 70)];
    [_usersContainer setFrameSize:usersContainerSize];
    
    [self setContainerFrameSize:NSMakeSize(MAX(250,usersContainerSize.width + 50), 230 + usersContainerSize.height)];
    
    [_usersContainer setCenteredXByView:_usersContainer.superview];
    
    [_photoImageView setChat:fakeChat];
    
    [_photoImageView setFrameOrigin:NSMakePoint(0, self.containerSize.height - 25 - NSHeight(_photoImageView.frame))];

    [_photoImageView setCenteredXByView:_photoImageView.superview];
    
    [self fillUsers:chatInvite.participants];
    
    
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] init];
    [titleAttr appendString:fakeChat.title withColor:TEXT_COLOR];
    [titleAttr setFont:TGSystemFont(15) forRange:titleAttr.range];
    [_nameLabel setText:titleAttr maxWidth:self.containerSize.width - 40];
    [_nameLabel setFrameOrigin:NSMakePoint(0, NSMinY(_photoImageView.frame) - 10 - NSHeight(_nameLabel.frame))];
    [_nameLabel setCenteredXByView:_nameLabel.superview];
    
    
    NSMutableAttributedString *infoAttr = [[NSMutableAttributedString alloc] init];
    [infoAttr appendString:[NSString stringWithFormat:fakeChat.participants_count > 1 ? NSLocalizedString(@"ChatInvite.MultiChatDesc", nil) : NSLocalizedString(@"ChatInvite.SingleChatDesc", nil),fakeChat.participants_count] withColor:GRAY_TEXT_COLOR];
    [infoAttr setFont:TGSystemFont(13) forRange:infoAttr.range];
    [_infoLabel setText:infoAttr maxWidth:self.containerSize.width - 40];
    [_infoLabel setFrameOrigin:NSMakePoint(0, NSMinY(_nameLabel.frame)  - NSHeight(_infoLabel.frame))];
    [_infoLabel setCenteredXByView:_infoLabel.superview];
    
    [super show:appWindow() animated:YES];
}

-(void)fillUsers:(NSArray *)participants {
    
    __block int x = 0;
    
    [participants enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TMAvatarImageView *photo = [TMAvatarImageView standartTableAvatar];
        
        TMView *container = [[TMView alloc] initWithFrame:NSMakeRect(x, 0, NSWidth(photo.frame), NSHeight(_usersContainer.frame))];
        container.isFlipped = YES;
        
        [photo setFrameOrigin:NSMakePoint(0, 0)];
        [photo setUser:obj];
        [container addSubview:photo];
        
        TGTextLabel *name = [[TGTextLabel alloc] init];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:obj.first_name withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
        
        [name setText:attr maxWidth:NSWidth(photo.frame)];
        
        [name setFrameOrigin:NSMakePoint(0, NSMaxY(photo.frame) + 5)];
        [name setCenteredXByView:container];
        [container addSubview:name];
        
        [_usersContainer addSubview:container];
        
        x+=NSWidth(photo.frame)+25;
        
        if(idx == 3)
            *stop = YES;
        
    }];
}


@end
