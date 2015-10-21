//
//  TGHeadChatPanel.m
//  Telegram
//
//  Created by keepcoder on 15.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGHeadChatPanel.h"
#import "TGHCMessagesViewController.h"
@interface TGHeadChatPanel ()
@property (nonatomic,strong) TMNavigationController *navigationController;
@property (nonatomic,strong) TGHCMessagesViewController *messagesViewController;
@property (nonatomic,strong) TL_conversation *conversation;
@end

@implementation TGHeadChatPanel

-(instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen]) {
        [self initializeHeadChatPanel];
    }
    
    return self;
}

-(instancetype)init {
    if(self = [super initWithContentRect:NSMakeRect(300, 300, 350, 350) styleMask:NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES]) {
        [self initializeHeadChatPanel];
    }
    
    return self;
}

static NSMutableDictionary *allChatHeads;
+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allChatHeads = [[NSMutableDictionary alloc] init];
    });
}

+(void)showWithConversation:(TL_conversation *)conversation {
    
    
    TGHeadChatPanel *panel = allChatHeads[@(conversation.peer_id)];
    
    if(!panel) {
        panel = [[TGHeadChatPanel alloc] init];
        
        allChatHeads[@(conversation.peer_id)] = panel;
        
        [panel showWithConversation:conversation];
    }
    
    [panel makeKeyAndOrderFront:self];
}

-(void)orderOut:(id)sender {
    
    [super orderOut:sender];
    

}


-(void)dealloc {
    [allChatHeads removeObjectForKey:@(self.conversation.peer_id)];
    
    [_navigationController.view removeFromSuperview];
    [_messagesViewController.view removeFromSuperview];
    
    [_navigationController.viewControllerStack removeAllObjects];
    
    [_messagesViewController _didStackRemoved];
    [_messagesViewController viewDidDisappear:NO];
    [_messagesViewController drop];
    _navigationController.currentController = nil;
    _messagesViewController.navigationViewController = nil;
    
    
    
    _messagesViewController = nil;
    _navigationController = nil;
}

-(void)showWithConversation:(TL_conversation *)conversation {
    _conversation = conversation;
    
    [_messagesViewController setCurrentConversation:conversation];
}

-(void)initializeHeadChatPanel {
    
    [self setReleasedWhenClosed:YES];
    
    [self setMinSize:NSMakeSize(380, 300)];
    
    self.contentView.wantsLayer = YES;
  //  self.contentView.layer.cornerRadius = 4;
    
    _navigationController = [[TMNavigationController alloc] initWithFrame:self.contentView.frame];
    
    _messagesViewController = [[TGHCMessagesViewController alloc] initWithFrame:self.contentView.frame];
    
    
    [_messagesViewController loadViewIfNeeded];
    [self.contentView addSubview:_navigationController.view];
    
    [_navigationController pushViewController:_messagesViewController animated:NO];

}

@end
