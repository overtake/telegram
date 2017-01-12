//
//  TGBottomKeyboardContainerVIew.m
//  Telegram
//
//  Created by keepcoder on 16/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomKeyboardContainerView.h"
#import "TGBottomSignals.h"
#import "TGBotCommandsKeyboard.h"
#import "TGCAActions.h"
#import "CAAnimateLayer.h"
@interface TGBottomKeyboardContainerView ()
@property (nonatomic,assign) BOOL cshow;
@end

@implementation TGBottomKeyboardContainerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
    }
    
    return self;
}

-(TGBotCommandsKeyboard *)botContainer {
    TGBotCommandsKeyboard *botKeyboard = [[TGBotCommandsKeyboard alloc] initWithFrame:NSMakeRect(20, 10, NSWidth(self.frame) - 40, 30)];
    botKeyboard.wantsLayer = YES;
    [botKeyboard setBackgroundColor:[NSColor whiteColor]];
    [botKeyboard setButtonBorderColor:LIGHT_GRAY_BORDER_COLOR];
    [botKeyboard setButtonColor:LIGHT_GRAY_BORDER_COLOR];
    [botKeyboard setButtonTextColor:TEXT_COLOR];
    return botKeyboard;
}


-(SSignal *)resignalKeyboard:(MessagesViewController *)messagesController forceShow:(BOOL)force changeState:(BOOL)changeState {
    
    
    __block BOOL forceShow = force;
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [[TGBottomSignals botKeyboardSignal:messagesController.conversation] startWithNext:^(TL_localMessage *keyboard) {
            
            
            if(keyboard) {
                

              //  [self removeAllSubviews];
                
                [self.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    [obj removeFromSuperview:YES];
                    
                }];
                
                weak();
                
                 TGBotCommandsKeyboard *botKeyboard = [self botContainer];
                
                __weak TGBotCommandsKeyboard *weakKeyboard = botKeyboard;
                
                [self addSubview:botKeyboard];
                
                [botKeyboard setKeyboard:keyboard fillToSize:NO keyboadrdCallback:^(TLKeyboardButton *botCommand) {
                    
                    strongWeak();
                    
                    if(strongSelf == weakSelf) {
                        
                        [MessageSender proccessInlineKeyboardButton:botCommand messagesViewController:messagesController conversation:keyboard.conversation message:nil handler:^(TGInlineKeyboardProccessType type) {
                            
                            [weakKeyboard setProccessing:type == TGInlineKeyboardProccessingType forKeyboardButton:botCommand];
                            
                            if(type == TGInlineKeyboardSuccessType) {
                                if(keyboard.reply_markup.isSingle_use ) {
                                    
                                    
                                    //ФЛАГ SINGLE_USE (1 << 5) ЗАНЯТ. Предупредить.
                                    keyboard.reply_markup.flags|= (1 << 5);
                                    
                                    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                                        [transaction setObject:keyboard forKey:keyboard.conversation.cacheKey inCollection:BOT_COMMANDS];
                                    }];
                                    
                                    [subscriber putNext:@(0)];
                                    
                                    //[Notification perform:[Notification notificationNameByDialog:keyboard.conversation action:@"hideBotKeyboard"] data:@{KEY_DIALOG:keyboard.conversation}];
                                }
                            }
                            
                            
                        }];
                        
                        
                    }
                    
                }];
                
                

                if(!forceShow) {
                    
                    if((botKeyboard.keyboard.reply_markup.flags & (1 << 1)) == 0) {
                        forceShow = YES;
                    } else {
                        forceShow = (botKeyboard.keyboard.reply_markup.flags & (1 << 5)) == 0;
                    }
                    
                    if(forceShow && !changeState && !_cshow)
                        _cshow = YES;
                    else if(!forceShow && !changeState && _cshow)
                        _cshow = NO;

                }
                
            } else {
                forceShow = NO;
                [[self.subviews lastObject] removeFromSuperview:YES];
            }
            
            if(changeState)
                _cshow = !_cshow;

            
            //
            [subscriber putNext:@(forceShow && (!changeState || _cshow) ? NSHeight([self.subviews lastObject].frame) + 10 : 0)];
            

        }];
        
        
        return nil;
        
    }];
}




@end
