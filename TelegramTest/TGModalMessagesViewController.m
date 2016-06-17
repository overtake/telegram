//
//  TGModalMessagesViewController.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModalMessagesViewController.h"
#import "TGContextMessagesvViewController.h"
#import "TGMessagesNavigationController.h"
#import "ComposeActionCustomBehavior.h"
@interface TGModalMessagesViewController ()
@property (nonatomic,strong) TMNavigationController *navigationController;
@end
@implementation TGModalMessagesViewController



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(300, 370)];
        
        [self initialize];
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    
    [super setFrameSize:newSize];
    
    [self setContainerFrameSize:NSMakeSize(MAX(300,MIN(450,newSize.width - 60)), MAX(320,MIN(555,newSize.height - 60)))];
    
}


-(void)modalViewDidShow {
    [self setContainerFrameSize:NSMakeSize(MAX(300,MIN(450,NSWidth(self.frame) - 60)), MAX(330,MIN(555,NSHeight(self.frame) - 60)))];
    
    if(self.action) {
        TL_inlineBotSwitchPM *pm = _action.reservedObject1;
        [_messagesViewController sendStartBot:pm.start_param forConversation:_action.object bot:_action.reservedObject2];
    }
}



-(void)didNeedCloseAndSwitch:(TLKeyboardButton *)keyboard {
    TLUser *user = _action.reservedObject2;
    TL_conversation *parentConversation = _action.reservedObject3;
    
    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:parentConversation.peer_id];
    [template updateTextAndSave:[NSString stringWithFormat:@"@%@ %@",user.username,keyboard.query]];

    [template performNotification];
    
    [self close:YES];
}

-(void)modalViewDidHide {
    [Notification removeObserver:self];
    
    ComposeActionCustomBehavior *behavior = (ComposeActionCustomBehavior *)self.action.behavior;
    
    if(behavior.composeDone != nil)
        behavior.composeDone();
    
    behavior.composeDone = nil;
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)setAction:(ComposeAction *)action {
    _action = action;
    
    [_messagesViewController setCurrentConversation:action.object];
    
}



-(void)initialize {
    
    self.acceptEvents = YES;
    
    _navigationController = [[TGMessagesNavigationController alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, self.containerSize.height)];
    
    
    _messagesViewController = [[TGContextMessagesvViewController alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, self.containerSize.height)];
    
    _messagesViewController.contextModalView = self;
    
    self.navigationController.messagesViewController = _messagesViewController;
    
    [_messagesViewController loadViewIfNeeded];
    [self addSubview:_navigationController.view];
    
    [self.navigationController pushViewController:_messagesViewController animated:NO];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}



@end
