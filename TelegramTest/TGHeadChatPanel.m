//
//  TGHeadChatPanel.m
//  Telegram
//
//  Created by keepcoder on 15.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGHeadChatPanel.h"
#import "TGHCMessagesViewController.h"
#import "TGChatHeadLockView.h"
@interface TGHeadChatPanel ()
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
    if(self = [super initWithContentRect:NSMakeRect(300, 300, 380, 400) styleMask:NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES]) {
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

-(void)back {
    if(self.navigationController.viewControllerStack.count > 1)
        [self.navigationController goBackWithAnimation:YES];
}


-(void)dealloc {
    [allChatHeads removeObjectForKey:@(self.conversation.peer_id)];
    
    [self.navigationController.view removeFromSuperview];
    [_messagesViewController.view removeFromSuperview];
    
    [self.navigationController.viewControllerStack removeAllObjects];
    
    [_messagesViewController _didStackRemoved];
    [_messagesViewController viewDidDisappear:NO];
    [_messagesViewController drop];
    self.navigationController.currentController = nil;
    _messagesViewController.navigationViewController = nil;
    
    
    
    _messagesViewController = nil;
    self.navigationController = nil;
}


-(void)showWithConversation:(TL_conversation *)conversation {
    _conversation = conversation;
    
    [_messagesViewController setCurrentConversation:conversation];
}




-(void)initializeHeadChatPanel {
    
    self.canHide = NO;
    self.acceptEvents = YES;
    [self setReleasedWhenClosed:YES];
    
    [self setMinSize:NSMakeSize(380, 400)];
    
    self.contentView.wantsLayer = YES;
   // self.contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.navigationController = [[TMNavigationController alloc] initWithFrame:self.contentView.bounds];
    
    
    _messagesViewController = [[TGHCMessagesViewController alloc] initWithFrame:self.contentView.bounds];
    
    self.navigationController.messagesViewController = _messagesViewController;
    
    [_messagesViewController loadViewIfNeeded];
    [self.contentView addSubview:self.navigationController.view];
    
    [self.navigationController pushViewController:_messagesViewController animated:NO];

}

-(void)setFrame:(NSRect)frameRect display:(BOOL)flag {
    
    [super setFrame:frameRect display:flag];
  
    
   
   // [self.navigationController.view setFrameSize:NSMakeSize(frameRect.size.width, frameRect.size.height - 20)];
    
}

+(void)lockAllControllers {
    [allChatHeads enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TGHeadChatPanel  *obj, BOOL * _Nonnull stop) {
        
        if(obj.acceptEvents) {
            [obj.contentView addSubview:[[TGChatHeadLockView alloc] initWithFrame:obj.contentView.bounds]];
            
            [obj setAcceptEvents:NO];
        }
        
    }];
}

+(void)unlockAllControllers {
    [allChatHeads enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TGHeadChatPanel  *obj, BOOL * _Nonnull stop) {
        
        if(!obj.acceptEvents) {
            [[obj.contentView.subviews lastObject] removeFromSuperview];
            
            [obj setAcceptEvents:YES];
        }
        
    }];
}



@end
