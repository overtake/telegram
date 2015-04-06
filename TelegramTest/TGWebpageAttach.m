//
//  TGWebpageAttach.m
//  Telegram
//
//  Created by keepcoder on 06.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageAttach.h"

@interface TGWebpageAttach ()
@property (nonatomic,strong) TLWebPage *webpage;
@property (nonatomic,strong) NSString *link;
@property (nonatomic,assign) int peer_id;

@property (nonatomic,strong) TMTextField *titleField;
@property (nonatomic,strong) TMTextField *stateField;
@property (nonatomic,strong) id internalId;

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
        
        
        [_titleField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        
        [_titleField setTextColor:LINK_COLOR];
        
        
        [_titleField setFrameOrigin:NSMakePoint(5, NSHeight(frameRect) - 13)];
        
        
        [_stateField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        
        
        
        [_stateField setFrameOrigin:NSMakePoint(5, 0)];
        
        [self addSubview:_titleField];
        [self addSubview:_stateField];
        
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
    
    [Storage addWebpage:webpage forLink:webpage.url];
    
    if(_peer_id == [Telegram rightViewController].messagesViewController.conversation.peer_id) {
        [[Telegram rightViewController].messagesViewController updateWebpage];
    }
}

-(void)didUpdateWebpage:(NSNotification *)notify {
    
    TLWebPage *webpage = notify.userInfo[KEY_WEBPAGE];
    
    if(_webpage.n_id == webpage.n_id)
    {
        [self updateWithWebpage:webpage];
    }

}

-(void)updateLayout {
    [_titleField setStringValue:[_webpage isKindOfClass:[TL_webPagePending class]] ? NSLocalizedString(@"Webpage.GettingLinkInfo", nil) : _webpage.site_name];
    
    [_stateField setStringValue:_link];
   
    
    [_stateField sizeToFit];
    [_titleField sizeToFit];
}

-(void)dealloc {
    remove_global_dispatcher(_internalId);
    [Notification removeObserver:self];
}

@end
