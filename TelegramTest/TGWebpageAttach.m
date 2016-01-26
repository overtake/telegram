//
//  TGWebpageAttach.m
//  Telegram
//
//  Created by keepcoder on 06.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageAttach.h"

@interface TGWebpageAttach ()
@property (nonatomic,assign) int peer_id;

@property (nonatomic,strong) TMTextField *titleField;
@property (nonatomic,strong) TMTextField *stateField;
@property (nonatomic,strong) id internalId;

@property (nonatomic,strong) NSImageView *deleteImageView;

@end

@implementation TGWebpageAttach

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [LINK_COLOR setFill];

    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
}

-(id)initWithFrame:(NSRect)frameRect webpage:(TLWebPage *)webpage link:(NSString *)link {
    if(self = [super initWithFrame:frameRect]) {
        _webpage = webpage;
        _link = link;
        
        _titleField = [TMTextField defaultTextField];
        _stateField = [TMTextField defaultTextField];
        
        
        [_titleField setFont:TGSystemFont(13)];
        
        [_titleField setTextColor:LINK_COLOR];
        
        
        [_titleField setFrameOrigin:NSMakePoint(5, NSHeight(frameRect) - 13)];
        
        
        [_stateField setFont:TGSystemFont(13)];
        
        
        
        [_stateField setFrameOrigin:NSMakePoint(5, 0)];
        
        [self addSubview:_titleField];
        [self addSubview:_stateField];
        
        
        _deleteImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_CancelReply().size.width, NSHeight(self.frame) - image_CancelReply().size.height, image_CancelReply().size.width, image_CancelReply().size.height)];
        
        _deleteImageView.image = image_CancelReply();
        
        
        [_deleteImageView setCallback:^{
            
            [[Telegram rightViewController].messagesViewController markAsNoWebpage];
            
        }];
        
        [_deleteImageView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        
        [self addSubview:_deleteImageView];

        
        [self updateLayout];
        
        if([_webpage isKindOfClass:[TL_webPagePending class]]) {
            _internalId = dispatch_in_time(_webpage.date, ^{
                
                [RPCRequest sendRequest:[TLAPI_messages_getWebPagePreview createWithMessage:_link] successHandler:^(RPCRequest *request, TL_messageMediaWebPage *response) {
                    
                    [self updateWithWebpage:response.webpage];
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                }];
                
            });
        }
    
        [Notification addObserver:self selector:@selector(didUpdateWebpage:) name:UPDATE_WEB_PAGES];
        
    }
    
    return self;
}

-(void)updateWithWebpage:(TLWebPage *)webpage {
    
    [self updateLayout];
}

-(void)didUpdateWebpage:(NSNotification *)notify {
    
    TLWebPage *webpage = notify.userInfo[KEY_WEBPAGE];
    
    [Storage addWebpage:webpage forLink:_link];
    
    if(_webpage.n_id == webpage.n_id)
    {
        _webpage = webpage;
        
        [self updateLayout];
    }

}

-(void)updateLayout {
    [_titleField setStringValue:[_webpage isKindOfClass:[TL_webPagePending class]] ? NSLocalizedString(@"Webpage.GettingLinkInfo", nil) : (_webpage.site_name ? _webpage.site_name : @"Link Preview")];
    
    if([_webpage isKindOfClass:[TL_webPageEmpty class]]) {
        
        [[Telegram rightViewController].messagesViewController updateWebpage];
        
        return;
    }
    
    NSString *desc = _link;
    
    [_stateField setTextColor:DARK_BLACK];
    
    if([_webpage isKindOfClass:[TL_webPage class]]) {
        desc = _webpage.title;
        if(!desc)
            desc = _webpage.n_description;
        if(!desc)
            desc = _webpage.author;
        if(!desc && _webpage.document)
            desc = NSLocalizedString(@"Document", nil);
        if(!desc)
            desc = _webpage.url;
        [_stateField setTextColor:GRAY_TEXT_COLOR];
    }
    
    [_stateField setStringValue:desc];
   
    
    
    
    [_stateField sizeToFit];
    [_titleField sizeToFit];
    
    [_stateField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(_stateField.frame), 20)];
    [_titleField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(_titleField.frame), NSHeight(_titleField.frame))];
    
    
}

-(void)dealloc {
    //assert([NSThread isMainThread]);
    remove_global_dispatcher(_internalId);
    [Notification removeObserver:self];
}

@end
