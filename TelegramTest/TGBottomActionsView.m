//
//  TGBottomActionsView.m
//  Telegram
//
//  Created by keepcoder on 13/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomActionsView.h"
#import "TGBottomSignals.h"
#import "TGModernMessagesBottomView.h"
@interface TGModernMessagesBottomView ()

-(void)_showOrHideBotKeyboardAction:(id)notify;

@end

@interface TGBottomActionsView ()
@property (nonatomic,weak) MessagesViewController *messagesController;
@property (nonatomic,weak) TGModernMessagesBottomView *controller;

@property (nonatomic, strong) BTRButton *silentMode;
@property (nonatomic, strong) BTRButton *botCommand;
@property (nonatomic, strong) BTRButton *botKeyboard;
@property (nonatomic, strong) BTRButton *secretTimer;
@property (nonatomic, strong) BTRButton *emoji;


@end

@implementation TGBottomActionsView

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController bottomController:(TGModernMessagesBottomView *)bottomControler {
    if(self = [super initWithFrame:frameRect]) {
        _messagesController = messagesController;
        _animates = YES;
        _controller = bottomControler;
        
        
        
        _emoji = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_smile().size.width, image_smile().size.height)];
        [_emoji setBackgroundImage:image_smile() forControlState:BTRControlStateNormal];
        [_emoji setBackgroundImage:image_smileActive() forControlState:BTRControlStateHighlighted];
        [_emoji setBackgroundImage:image_smileActive() forControlState:BTRControlStateSelected | BTRControlStateHover];
        [_emoji setBackgroundImage:image_smileActive() forControlState:BTRControlStateSelected];
        
       
        
        
        _botKeyboard = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_botKeyboard().size.width, image_botKeyboard().size.height)];
      //  [_botKeyboard setImage:image_botKeyboardActive() forControlState:BTRControlStateSelected];
        [_botKeyboard setImage:image_botKeyboard() forControlState:BTRControlStateNormal];
        
        
        _botCommand = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_botCommand().size.width, image_botCommand().size.height)];
        [_botCommand setBackgroundImage: image_botCommand() forControlState:BTRControlStateNormal];
        
        
        _silentMode = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ConversationInputFieldBroadcastIconInactive().size.width, image_ConversationInputFieldBroadcastIconInactive().size.height)];
        [_silentMode setBackgroundImage:image_ConversationInputFieldBroadcastIconInactive() forControlState:BTRControlStateNormal];
        
        
        
         _secretTimer = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ModernConversationSecretAccessoryTimer().size.width, image_ModernConversationSecretAccessoryTimer().size.height)];
        [_secretTimer.layer disableActions];
        
        [_secretTimer setImage: image_ModernConversationSecretAccessoryTimer() forControlState:BTRControlStateNormal];
        
        
        
         [_silentMode setCenteredYByView:self];
         [_botCommand setCenteredYByView:self];
         [_botKeyboard setCenteredYByView:self];
         [_secretTimer setCenteredYByView:self];
         [_emoji setCenteredYByView:self];
        
        [self addSubview:_silentMode];
        [self addSubview:_botCommand];
        [self addSubview:_botKeyboard];
        [self addSubview:_secretTimer];
        [self addSubview:_emoji];
        
        
        [_silentMode addTarget:self action:@selector(silentModeAction:) forControlEvents:BTRControlEventMouseDownInside];
        [_secretTimer addTarget:self action:@selector(secretTimerAction:) forControlEvents:BTRControlEventMouseDownInside];
        [_botKeyboard addTarget:self action:@selector(botKeyboardAction:) forControlEvents:BTRControlEventMouseDownInside];
        [_botCommand addTarget:self action:@selector(botCommandAction:) forControlEvents:BTRControlEventMouseDownInside];
        
        
    }
    
    return self;
}

-(void)botKeyboardAction:(BTRButton *)button {
    
    [_controller _showOrHideBotKeyboardAction:nil];
    
    
}

-(void)setActiveKeyboardButton:(BOOL)active {
    [_botKeyboard setSelected:active];
    [_botKeyboard setImage:active ? image_botKeyboardActive() : image_botKeyboard() forControlState:BTRControlStateNormal];

}

-(SSignal *)resignal:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        [[TGBottomSignals actions:_messagesController.conversation actionType:actionType] startWithNext:^(id next) {
            
            __block BOOL changed = NO;
            
            [next enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BOOL show = [obj boolValue];
                BTRButton *action = self.subviews[idx];
            
                if(show == !action.isHidden) {
                    changed = YES;
                    *stop = YES;
                }
                
            }];
            
            
            if(changed) {
                assert(self.subviews.count == [next count]);
                
                const int offset = 10;
                
                __block int x = offset;
                
                
                [next enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    BOOL show = [obj boolValue];
                    BTRButton *action = self.subviews[idx];
                    [action setHidden:!show];
                    
                    if(show) {
                        [action setFrameOrigin:NSMakePoint(x, NSMinY(action.frame))];
                        
                        x+=NSWidth(action.frame)+offset;
                    }
                    
                }];
                
                changed = NSWidth(self.frame) != x;
                
                [self setFrameSize:NSMakeSize(x, NSHeight(self.frame))];
            }
            
            
            
            [subscriber putNext:@(changed)];
            [subscriber putCompletion];
            
        }];
        
        return nil;
        
    }];
}

@end
