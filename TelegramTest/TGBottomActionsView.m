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
#import "TGModernESGViewController.h"
#import "TMCircularProgress.h"
#import "SpacemanBlocks.h"


@interface TGBottomActionsView (){
    RBLPopover *_emojipopover;
}
@property (nonatomic,weak) MessagesViewController *messagesController;

@property (nonatomic, strong) BTRButton *silentMode;
@property (nonatomic, strong) BTRButton *botCommand;
@property (nonatomic, strong) BTRButton *botKeyboard;
@property (nonatomic, strong) BTRButton *secretTimer;
@property (nonatomic, strong) BTRButton *emoji;

@property (nonatomic,strong) TMCircularProgress *progressView;

@property (nonatomic,assign) int progress;

@end

@implementation TGBottomActionsView

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        _messagesController = messagesController;
        _animates = YES;
        
        
        _progressView = [[TMCircularProgress alloc] initWithFrame:NSMakeRect(0, 0, 26, 26)];
        [_progressView setBackgroundColor:[NSColor whiteColor]];
        
        _emoji = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_smile().size.width, image_smile().size.height)];
        [_emoji setBackgroundImage:image_smile() forControlState:BTRControlStateNormal];
        [_emoji setBackgroundImage:image_smileActive() forControlState:BTRControlStateHighlighted];
        [_emoji setBackgroundImage:image_smileActive() forControlState:BTRControlStateSelected | BTRControlStateHover];
        [_emoji setBackgroundImage:image_smileActive() forControlState:BTRControlStateSelected];
        
        [_emoji addTarget:self action:@selector(emojiEntered:) forControlEvents:BTRControlEventMouseEntered];
        [_emoji addTarget:self action:@selector(emojiClick:) forControlEvents:BTRControlEventClick];
        
        
        _botKeyboard = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_botKeyboard().size.width, image_botKeyboard().size.height)];
        [_botKeyboard setImage:image_botKeyboard() forControlState:BTRControlStateNormal];
        
        
        _botCommand = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_botCommand().size.width, image_botCommand().size.height)];
        [_botCommand setBackgroundImage: image_botCommand() forControlState:BTRControlStateNormal];
        
        
        _silentMode = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ConversationInputFieldBroadcastIconInactive().size.width, image_ConversationInputFieldBroadcastIconInactive().size.height)];
        [_silentMode setImage:image_ConversationInputFieldBroadcastIconInactive() forControlState:BTRControlStateNormal];
        
        
        
         _secretTimer = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ModernConversationSecretAccessoryTimer().size.width, image_ModernConversationSecretAccessoryTimer().size.height)];
        [_secretTimer setImage: image_ModernConversationSecretAccessoryTimer() forControlState:BTRControlStateNormal];
        
        [_secretTimer addTarget:self action:@selector(secretTimerAction:) forControlEvents:BTRControlEventMouseDownInside];

         [_progressView setCenteredYByView:self];
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
        [self addSubview:_progressView];
        
        [_silentMode addTarget:self action:@selector(silentModeAction:) forControlEvents:BTRControlEventMouseDownInside];
        [_secretTimer addTarget:self action:@selector(secretTimerAction:) forControlEvents:BTRControlEventMouseDownInside];
        [_botKeyboard addTarget:self action:@selector(botKeyboardAction:) forControlEvents:BTRControlEventMouseDownInside];
        
        [_progressView setProgressColor:GRAY_TEXT_COLOR];
        
        
        
        
    }
    
    return self;
}

-(void)botKeyboardAction:(BTRButton *)button {
    [_delegate _showOrHideBotKeyboardAction:nil];
}

-(void)silentModeAction:(id)sender {
    [_delegate _changeSilentMode:nil];


}



-(void)secretTimerAction:(BTRButton *)sender {
    
    
    static TMMenuPopover *popover;
    
    NSMenu *menu = [MessagesViewController destructMenu:^ {
        
    } click:^{
        [popover close];
        popover = nil;
    }];
    
    
    [popover close];
    popover = nil;
    
    
    popover = [[TMMenuPopover alloc] initWithMenu:menu];
    
    [popover showRelativeToRect:sender.bounds ofView:sender preferredEdge:CGRectMaxYEdge];
    
}

-(void)setActiveKeyboardButton:(BOOL)active {
    [_botKeyboard setSelected:active];
    [_botKeyboard setImage:active ? image_botKeyboardActive() : image_botKeyboard() forControlState:BTRControlStateNormal];
}

-(void)setActiveSilentMode:(BOOL)active {
    [_silentMode setSelected:active];
    [_silentMode setImage:active ? image_ConversationInputFieldBroadcastIconActive() : image_ConversationInputFieldBroadcastIconInactive() forControlState:BTRControlStateNormal];
}

-(void)setActiveEmoji:(BOOL)active {
    [_emoji setSelected:active];
}

- (void)emojiEntered:(BTRButton *)button {
    
    if(!([SettingsArchiver checkMaskedSetting:ESGLayoutSettings] && [_messagesController canShownESGController])) {
        [self emojiClick:button];
    }
    
}

- (void)emojiClick:(BTRButton *)button {
    
    if([SettingsArchiver checkMaskedSetting:ESGLayoutSettings] && [_messagesController canShownESGController])
    {
        [_messagesController showOrHideESGController:NO toggle:YES];
        return;
    }
    
    
    TGModernESGViewController *egsViewController = [TGModernESGViewController controller];
    
    //
    weak();
    if(!_emojipopover) {
        
        _emojipopover = [[RBLPopover alloc] initWithContentViewController:(NSViewController *)egsViewController];
        [_emojipopover setHoverView:_emoji];
        _emojipopover.animates = NO;
        [_emojipopover setDidCloseBlock:^(RBLPopover *popover){
            [weakSelf.emoji setSelected:NO];
            [egsViewController close];
        }];
        
    }
    
    egsViewController.messagesViewController = _messagesController;
    egsViewController.epopover = _emojipopover;
    
    [egsViewController.emojiViewController setInsertEmoji:^(NSString *emoji) {
        [weakSelf.delegate _insertEmoji:emoji];
    }];
    
    [_emoji setSelected:YES];
    
    NSRect frame = _emoji.bounds;
    frame.origin.y += 4;
    
    if(!_emojipopover.isShown) {
        [_emojipopover showRelativeToRect:frame ofView:_emoji preferredEdge:CGRectMaxYEdge];
        [egsViewController show];
    }
    
    
}



-(SSignal *)resignal:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        [[TGBottomSignals actions:_messagesController.conversation actionType:actionType] startWithNext:^(NSArray *next) {
            
            [_progressView setCurrentProgress:0.0f];
            
            __block BOOL changed = next == nil;
            
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
                
                const int offset = 0;
                const int itemXOffset = 5;
                
                __block int x = offset;
                
                
                [next enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    BOOL show = [obj boolValue];
                    BTRButton *action = self.subviews[idx];
                    [action setHidden:!show];
                    [action setAlphaValue:show];
                    if(show) {
                        [action setFrameOrigin:NSMakePoint(x, NSMinY(action.frame))];
                        if(![[next lastObject] boolValue] || idx != next.count - 2)
                            x+=NSWidth(action.frame)+itemXOffset;
                    }
                    
                }];
                
                x-=itemXOffset;
                
                changed = NSWidth(self.frame) != x;
                
                [self setFrameSize:NSMakeSize(MAX(0,x), NSHeight(self.frame))];
            }
            
            
            
            [subscriber putNext:@(changed)];
            [subscriber putCompletion];
            
        }];
        
        return nil;
        
    }];
}

-(void)setInlineProgress:(int)progress {
    

    [[NSAnimationContext currentContext] setDuration:0.5];
    [[_progressView animator] setAlphaValue:progress == 0 ? 0.0f : 1.0f];

    
    if(_progressView.currentProgress == 100.f)
        [_progressView setCurrentProgress:0.0f];
    
    
    if(progress == 0) {
        _progressView->duration = 0.2;
        [_progressView setProgress:100.0f animated:YES];
        

       
    } else {
        _progressView->duration = 3.0;
        [_progressView setProgress:progress animated:YES];
    }
    
    

}

@end
