 //
//  AppDelegate.m
//  TelegramTest
//
//  Created by keepcoder on 07.09.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AppDelegate.h"
#import "CMath.h"
#import "DialogsManager.h"
//#import "AFnetworkActivityIndicatorManager.h"
#import "SSKeychain.h"
#import "TGSecretAction.h"


#import "FileUtils.h"
#import "MTNetwork.h"
#import "MessageSender.h"
#import <Quartz/Quartz.h>
#import "SelfDestructionController.h"
#import "TGProccessUpdates.h"
#import "TMMediaController.h"
#import "SettingsWindowController.h"
#import "TGTimer.h"
#import "NSString+Extended.h"
#import "TMTaskRequest.h"

#import "TMAudioRecorder.h"
#import "HackUtils.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "_TMSearchTextField.h"
#import "SecretChatAccepter.h"
#import "SenderItem.h"
#import "RBLPopover.h"
#import "NSTextView+EmojiExtension.h"
#import "TGPhotoViewer.h"
#import "TGPasslock.h"
#import "TGCTextView.h"
#import "TGPasslockModalView.h"
#import "ASCommon.h"
#import "TGModalView.h"
#import "TGAudioPlayerWindow.h"
#import "TGHeadChatPanel.h"
#import "NSArrayCategory.h"
#import "FullUsersManager.h"
#import "TGStickerPreviewModalView.h"
#import "SPMediaKeyTap.h"
#import "TGAudioPlayerWindow.h"
#import <SSignalKit/SSignal.h>
@interface NSUserNotification(For107)

@property (nonatomic, strong) NSAttributedString *response;



@end

@interface AppDelegate ()<SettingsListener>

@property (nonatomic,strong) NSSharingService *sharing;
#ifdef TGDEBUG
@property (weak) IBOutlet SUUpdater *updater;
#endif

@property (nonatomic,strong) SettingsWindowController *settingsWindow;


@end

@implementation AppDelegate

- (IBAction)logout:(id)sender {
    [self logoutWithForce:NO];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}



- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    
    
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if(url) {
        
        determinateURLLink([url absoluteString]);
    }
}

static void TGTelegramLoggingFunction(NSString *format, va_list args)
{
#ifdef TGDEBUG
#ifndef TGSTABLE
    
    TGLogv(format, args);
#endif
#endif
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    

    
#ifdef TGDEBUG
    
    
    _mediaKeyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    
    if([SPMediaKeyTap usesGlobalMediaKeyTap] && [SettingsArchiver checkMaskedSetting:HandleMediaKeysSettings])
        [_mediaKeyTap startWatchingMediaKeys];
    
#endif


    MTLogSetLoggingFunction(&TGTelegramLoggingFunction);
    
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
#ifdef TGDEBUG
    
#ifndef TGSTABLE
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:HOCKEY_APP_IDENTIFIER companyName:HOCKEY_APP_COMPANY delegate:self];
    [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled:YES];
    [[BITHockeyManager sharedHockeyManager].crashManager setAutoSubmitCrashReport: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
   
#else
    
    [self showMainApplicationWindowForCrashManager:nil];
    
#endif

#else 
    
    [self showMainApplicationWindowForCrashManager:nil];
    
#endif
    
    
}

+(void)initialize;
{
    
    // Register defaults for the whitelist of apps that want to use media keys
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event {
    NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
    // here be dragons...
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);
    
    if (keyIsPressed) {
        NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                
                if(_mainWindow.navigationController.currentController == _mainWindow.navigationController.messagesViewController || [TGAudioPlayerWindow isShown]) {
                    if([TGAudioPlayerWindow isShown]) {
                        if([TGAudioPlayerWindow playerState] == TGAudioPlayerGlobalStatePlaying)
                            [TGAudioPlayerWindow pause];
                        else
                            [TGAudioPlayerWindow resume];
                    } else {
                        [TGAudioPlayerWindow show:_mainWindow.navigationController.messagesViewController.conversation navigation:_mainWindow.navigationController];
                    }
                }
                
                
                
                break;
                
            case NX_KEYTYPE_FAST:
                debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                if([TGAudioPlayerWindow isShown]) {
                    [TGAudioPlayerWindow nextTrack];
                }
                break;
                
            case NX_KEYTYPE_REWIND:
                debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                if([TGAudioPlayerWindow isShown]) {
                    [TGAudioPlayerWindow prevTrack];
                }
                break;
            default:
                debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
                break;
                // More cases defined in hidsystem/ev_keymap.h
        }
        NSLog(@"%@",debugString);
    }

}

-(BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
    return [[MTNetwork instance] isAuth];
}

-(void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
    //  panel.currentPreviewItemIndex = [[TMMediaController getCurrentController] currentItemPosition];
    panel.delegate = [TMMediaController getCurrentController];
    panel.dataSource = [TMMediaController getCurrentController];
    panel.currentPreviewItemIndex  = [TMMediaController getCurrentController].currentItemPosition;
}

- (IBAction)openQuicklook:(id)sender {
    [[TMMediaController getCurrentController] show:nil];
}



-(BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
    return YES;
}

-(void)endPreviewPanelControl:(QLPreviewPanel *)panel {
    panel.delegate = nil;
    panel.dataSource = nil;
    // [[TMPreviewController controller] removeAllObjects];
    // [panel updateController];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    
    TL_conversation *dialog = [[DialogsManager sharedManager] find:[userInfo[KEY_PEER_ID] intValue]];
    
    if(dialog == nil) {
        ELog(@"nil dialog here, check it");
        return;
    }

    
    [self.mainWindow.navigationController showMessagesViewController:dialog];
    
    if (notification.activationType != 3) {
        // only deminiaturize the window if user clicked the notification itself
        // and not replied
        [self.mainWindow deminiaturize:self];
    } else if (floor(NSAppKitVersionNumber) > 1187 && notification.activationType == 3) { //NSUserNotificationActivationTypeReplied)
        NSString *userResponse = notification.response.string;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            TL_localMessage *msg = [[Storage manager] messageById:[userInfo[KEY_MESSAGE_ID] intValue] inChannel:dialog.type == DialogTypeChannel ? dialog.peer_id : 0];
            
            if(dialog.type == DialogTypeChat) {
                if(msg) {
                    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:msg.peer_id];
                    [template setReplyMessage:msg save:YES];
                    [template performNotification];
                }
            }
            
             [[Telegram rightViewController].messagesViewController sendMessage:userResponse forConversation:dialog];
            
        });
        
        return;
    }
    
}

-(void)didStatusItemClicked {
    [[NSApplication sharedApplication]  activateIgnoringOtherApps:YES];
   [self.mainWindow deminiaturize:self];
}

-(void)didChangeSettingsMask:(SettingsMask)mask {
    
    if([SettingsArchiver checkMaskedSetting:StatusBarIcon]) {
        
        if(!_statusItem) {
            _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
            
            
            [_statusItem setTarget:self];
            [_statusItem setAction:@selector(didStatusItemClicked)];
            
            NSImage *menuIcon = [NSImage imageNamed:@"StatusIcon"];
            [menuIcon setTemplate:YES];
            
            NSMenu *statusMenu = [StandartViewController attachMenu];
            
            
            [statusMenu addItem:[NSMenuItem separatorItem]];
            
            [statusMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Quit", nil) withBlock:^(id sender) {
                
                [[NSApplication sharedApplication] terminate:self];
                
            }]];
            
            [_statusItem setMenu:statusMenu];
            
            [_statusItem setImage:menuIcon];
        }
        
    } else {
        [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
        _statusItem = nil;
    }
    
}

void exceptionHandler(NSException * exception)
{
    NSArray *stack = [exception callStackReturnAddresses];
    NSLog(@"Stack trace: %@", stack);
}


- (void)showMainApplicationWindowForCrashManager:(id)crashManager {
    
    
    [self registerSleepNotification];
    
    [SettingsArchiver addEventListener:self];
    
    [self didChangeSettingsMask:0];
    
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    
    [SharedManager sharedManager];
    
    
    [self initializeUpdater];
    [self initializeKeyDownHandler];
    
    if ([NSUserNotification class] && [NSUserNotificationCenter class]) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    }
    
    CFStringRef bundleID = (__bridge CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    LSSetDefaultHandlerForURLScheme(CFSTR("tg"), bundleID);
    
    [self initializeMainWindow];


}


- (void)initializeUpdater {
    

#ifdef TGHUETA
   
    int bp = 0;
    
#endif
    
    
#ifdef TGDEBUG
    
    [self.updater setAutomaticallyChecksForUpdates:YES];
    
    [self.updater setFeedURL:[NSURL URLWithString:[NSBundle mainBundle].infoDictionary[@"SUFeedURL"]]];
    

    
    NSLog(@"%@",self.updater.feedURL.absoluteString);
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
    NSProcessInfo *pInfo = [NSProcessInfo processInfo];
    NSString *version = [[[pInfo operatingSystemVersionString] componentsSeparatedByString:@" "] objectAtIndex:1];
    
    [self.updater setUserAgentString:[NSString stringWithFormat:@"OS X: %@ / APP_VERSION: %@ / LANG : %@", version, API_VERSION, preferredLang]];
    
    [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(checkUpdates) userInfo:nil repeats:YES];
    [self.updater checkForUpdatesInBackground];
    
#endif
    
}

- (void)initializeKeyDownHandler {
    
    
    static BOOL buttonRecordIsUp = YES;
    
    id block = ^(NSEvent *incomingEvent) {

        
        NSEvent *result = incomingEvent;
        
        TelegramWindow *window = ((TelegramWindow *)result.window);
        
        if([window isKindOfClass:[TelegramWindow class]] && [window.navigationController.currentController isKindOfClass:NSClassFromString(@"TGWebgameViewController")]) {
           // [window.navigationController.currentController becomeFirstResponder];
            [window.firstResponder keyDown:incomingEvent];
            return [[NSEvent alloc] init];
        }
        
        if(result.window != self.mainWindow) {
            
            if(incomingEvent.keyCode == 53 && ![result.window respondsToSelector:@selector(popover)]) {
                
                if([[Telegram enterPasswordPanel] superview] != nil) {
                    [[Telegram enterPasswordPanel] showEnterPassword];
                    
                    return [[NSEvent alloc] init];
                }
                
                if(![result.window isKindOfClass:NSClassFromString(@"TGHeadChatPanel")]) {
                    if([result.window isKindOfClass:[NSPanel class]]) {
                        [result.window cancelOperation:nil];
                    } else {
                        [result.window close];
                    }
                }
                
                else
                {
                    TGHeadChatPanel *panel = (TGHeadChatPanel *) result.window;
                    
                    [panel back];
                }
                
                
                return result;
            }
            
            if([result.window isKindOfClass:[QLPreviewPanel class]] || [result.window isKindOfClass:[NSPanel class]] || [result.window isKindOfClass:[TGPhotoViewer class]]) {
                 return result;
            }
            
        }
        
        if([TGPhotoViewer isVisibility]) {
            
            
            if(incomingEvent.keyCode == 53) {
                [[TGPhotoViewer viewer] hide];
                return [[NSEvent alloc] init];
            }
            
            if(incomingEvent.keyCode == 123) {
                [TGPhotoViewer prevItem];
                return [[NSEvent alloc] init];
            }
            
            if(incomingEvent.keyCode == 124) {
                [TGPhotoViewer nextItem];
                return [[NSEvent alloc] init];
            }
            
            if(incomingEvent.keyCode == 49 ){
                [[TGPhotoViewer viewer] hide];
                return [[NSEvent alloc] init];
            }
            
            if(incomingEvent.keyCode == 24 || incomingEvent.keyCode == 69) {
                [TGPhotoViewer increaseZoom];
                return [[NSEvent alloc] init];
            }
            
            if(incomingEvent.keyCode == 27 || incomingEvent.keyCode == 78) {
                [TGPhotoViewer decreaseZoom];
                return [[NSEvent alloc] init];
            }
            
            if (incomingEvent.keyCode == 8 && incomingEvent.modifierFlags & NSEventModifierFlagCommand) {
                [TGPhotoViewer copyClipboard];
                return [[NSEvent alloc] init];
            }
            
            return result;
        }
        
        
        if([Telegram rightViewController].navigationViewController.isLocked)
            return result;
        
        
        id responder = incomingEvent.window.firstResponder;
                
        if(incomingEvent.keyCode == 48) {
            
            int keyCode = incomingEvent.keyCode;
            
            if(incomingEvent.modifierFlags == 262401)
                keyCode = 125;
            if(incomingEvent.modifierFlags == 393475)
                keyCode = 126;
            
             incomingEvent = [NSEvent keyEventWithType:incomingEvent.type location:incomingEvent.locationInWindow modifierFlags:incomingEvent.modifierFlags timestamp:incomingEvent.timestamp windowNumber:incomingEvent.windowNumber context:incomingEvent.context characters:incomingEvent.characters charactersIgnoringModifiers:incomingEvent.charactersIgnoringModifiers isARepeat:incomingEvent.isARepeat keyCode:keyCode];
            
        }
        
       
        /*
         typedef NS_OPTIONS(NSUInteger, NSEventModifierFlags) {
         NSAlphaShiftKeyMask         = 1 << 16,
         NSShiftKeyMask              = 1 << 17,
         NSControlKeyMask            = 1 << 18,
         NSAlternateKeyMask          = 1 << 19,
         NSCommandKeyMask            = 1 << 20,
         NSNumericPadKeyMask         = 1 << 21,
         NSHelpKeyMask               = 1 << 22,
         NSFunctionKeyMask           = 1 << 23,
         NSDeviceIndependentModifierFlagsMask    = 0xffff0000UL
         };
         */
        
        if((incomingEvent.modifierFlags & (NSControlKeyMask)) == NSControlKeyMask) {
            NSLog(@"keyCode:%d",incomingEvent.keyCode);
        }
        
        if(incomingEvent.keyCode == 125 || incomingEvent.keyCode == 126) {
            if(((incomingEvent.modifierFlags & (NSAlternateKeyMask)) > 0 || 
                (incomingEvent.modifierFlags & (NSControlKeyMask)) > 0 || 
                (incomingEvent.modifierFlags & (NSShiftKeyMask)) > 0)
                && incomingEvent.modifierFlags != 10617090) {
                BOOL result = YES;
                
//                if([responder isKindOfClass:[NSTextField class]]) {
//                    NSTextField *textField = responder;
//                    result = !textField.stringValue.length;
//                } else if([responder isKindOfClass:[TMSearchTextField class]]) {
//                    result = incomingEvent.keyCode == 126;
//                } else if ([responder isKindOfClass:[NSTextView class]]) {
//                    NSTextView *textView = responder;
//                    if([textView.superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
//                        result = incomingEvent.keyCode == 125;
//                    } else {
//                        result = !textView.string.length;
//                    }
//                }
                
                
                if(result) {
                    [[TMTableView current] keyDown:incomingEvent];
                    return [[NSEvent alloc] init];
                }
            }
            
            
        } else if(incomingEvent.keyCode == 53) {
            
            
            if([responder isKindOfClass:[NSTextView class]] && [((NSTextView *)responder).superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                [[Telegram leftViewController] resignFirstResponder];
                return [[NSEvent alloc] init];
            }
            
            if([Telegram rightViewController].navigationViewController.currentController == [Telegram rightViewController].currentEmptyController && ![responder isKindOfClass:NSClassFromString(@"_NSPopoverWindow")]) {
                
                if(![responder isKindOfClass:[NSTextView class]] || ![((NSTextView *)responder).superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                    [[Telegram leftViewController].currentTabController becomeFirstResponder:YES];
                    
                    return [[NSEvent alloc] init];
                } 
                
                return incomingEvent;
            }
            
            
            
            
            if(![TMViewController isModalActive]) {
                
//                BOOL res = [appWindow().navigationController.messagesViewController.bottomView removeQuickRecord];
//                
//                if(!res) {
//                    
//                    if([[TMAudioRecorder sharedInstance] isRecording]) {
//                        [appWindow().navigationController.messagesViewController.bottomView startOrStopQuickRecord];
//                        return incomingEvent;
//                        
//                    }
//                    
                    if(![appWindow().navigationController.currentController proccessEscAction]) {
                        
                        
                        [appWindow().navigationController goBackWithAnimation:YES];
                        
                        
                    } else {
                        if(appWindow().navigationController.currentController.messagesViewController == appWindow().navigationController.currentController) {
                            if(appWindow().navigationController.currentController.messagesViewController.editTemplate.attributedString.length > 0) {
                                return incomingEvent;
                            }
                        }
                    }
//                    
//                }
                
                
            
            } else {
                
                NSArray *modals = [TMViewController modalsView];
                
                if(modals.count > 0) {
                    [modals enumerateObjectsUsingBlock:^(TGModalView *obj, NSUInteger idx, BOOL *stop) {
                        [obj close:modals.count == 1];
                    }];
                    
                    return [[NSEvent alloc] init];
                }
                
                return incomingEvent;
            }
            
            
            
            return [[NSEvent alloc] init];
            
            
        } else if(incomingEvent.keyCode == 123) {
            
            BOOL send = YES;
            
            if([responder isKindOfClass:[NSTextField class]]) {
                NSTextField *textField = responder;
                send = !textField.stringValue.length;
            } else if ([responder isKindOfClass:[NSTextView class]]) {
                NSTextView *textView = responder;
                send = !textView.string.length;
            }
            
            if(send) {
                if([[Telegram rightViewController] isModalViewActive]) {
                    [[Telegram rightViewController] hideModalView:YES animation:YES];
                } else {
                    [[Telegram rightViewController] navigationGoBack];
                }
                return [[NSEvent alloc] init];
            }
        } else if(incomingEvent.keyCode == 124) {
            BOOL send = YES;
            
            if([responder isKindOfClass:[NSTextField class]]) {
                NSTextField *textField = responder;
                send = !textField.stringValue.length;
            } else if ([responder isKindOfClass:[NSTextView class]]) {
                NSTextView *textView = responder;
                send = !textView.string.length;
            }
            
            if(send) {
                [[Telegram rightViewController].navigationViewController.currentController rightButtonAction];
                return [[NSEvent alloc] init];
            }
        } else if(![responder isKindOfClass:[NSTextView class]] || ![responder isEditable]) {
            if(incomingEvent.modifierFlags == 256 && appWindow().navigationController.currentController == appWindow().navigationController.messagesViewController) {
                if(![TMViewController isModalActive])
                    [appWindow().navigationController.messagesViewController becomeFirstResponder];
                else
                {
                    [TMViewController becomeFirstResponderToModalView];
                }
            }
        }
        
        if(((result.modifierFlags & 1310720) == 1310720) && result.keyCode == 49) {
            NSTextView *textView = responder;
            if([responder isKindOfClass:[NSTextView class]] && ![textView.superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                [textView showEmoji];
                
            }
            
            return [[NSEvent alloc]init];
        }
        
        
        if(((result.modifierFlags & 1310985) == 1310985) && result.keyCode == 3) {

            
            return [[NSEvent alloc]init];
        }
        
        
        if((result.modifierFlags & 1048840 ) == 1048840 && result.keyCode == 3) {
            
            if(appWindow().navigationController.currentController == [appWindow().navigationController messagesViewController]) {
                [[appWindow().navigationController messagesViewController] showSearchBox];
            }
            
             return [[NSEvent alloc]init];
            
        }
        
        if((result.modifierFlags & 1048840 ) == 1048840 && result.keyCode == 29) {
            
            
            if([[Telegram rightViewController] isModalViewActive]) {
                [[Telegram rightViewController] modalViewSendAction:[UsersManager currentUser].dialog];
            } else {
                [appWindow().navigationController showMessagesViewController:[UsersManager currentUser].dialog];
            }
            
            return [[NSEvent alloc]init];
            
        }
        
        if((![responder isKindOfClass:[NSTextView class]] || ![responder isEditable]) && [SelectTextManager count] == 0  && ![responder isKindOfClass:[TGCTextView class]] && ![responder isKindOfClass:[TGModalView class]]) {
            if(![TMViewController isModalActive]) {
                if([appWindow().navigationController becomeFirstResponder]) {
                    
                    if(result.keyCode == 9 && (result.modifierFlags & NSCommandKeyMask) > 0) {
                        if([appWindow().navigationController.currentController isKindOfClass:[MessagesViewController class]]) {
                            [appWindow().navigationController.messagesViewController paste:nil];
                            return [[NSEvent alloc]init];
                        }
                    }
                    
                }
            } else {
                 [TMViewController becomeFirstResponderToModalView];
            }
            
            
        }
        
        
        if([TGPasslock isVisibility]) {
           
            
            if(![responder isKindOfClass:NSClassFromString(@"NSSecureTextView")]) {
                [TMViewController becomePasslock];
            }
        }
        
        // This section blocks tab keystrokes from propagating. 
        // Not sure whether it is still needed, hence commenting out first.
        // if(result.keyCode == 48) {
        //   //  NSTextView *textView = responder;
        //     return [[NSEvent alloc]init];
        // }
        
        if(isEnterAccess(result)) {
            if([appWindow().navigationController.currentController proccessEnterAction]) {
                return [[NSEvent alloc] init];
            }
        }
    
        
        if((result.modifierFlags & 1048840 ) == 1048840 ) {
            
            if(result.keyCode == 121 || result.keyCode == 116) {
                [[TMTableView current] keyDown:result];
                
                
                 return [[NSEvent alloc]init];
            } else if(result.keyCode == 15) { // cmd+r for audio record
//                if(buttonRecordIsUp) {
//                    buttonRecordIsUp = NO;
//                    [appWindow().navigationController.messagesViewController.bottomView startOrStopQuickRecord];
//                }
                return [[NSEvent alloc]init];
                
            }
            
            
        }
        
        return result;
    };
    
     id keyUpblock = ^(NSEvent *incomingEvent) {
         buttonRecordIsUp = YES;
         
         return incomingEvent;
     };
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyUpMask) handler:keyUpblock];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask) handler:block];
    
    ///MOuse
    id block2 = ^(NSEvent *incomingEvent) {
        NSEvent *result = incomingEvent;
        
        
        if(result.window != [TMMediaController controller].panel) {
            
            if(result.window == [NSApp mainWindow] && [result.window isKindOfClass:[MainWindow class]]) {
                
                if([result.window.contentView hitTest:[result locationInWindow]]) {
                    
                    TGModalView *modalView = (TGModalView *) [TMViewController modalView];
                    
                    if(modalView && (![modalView isKindOfClass:[TGModalView class]] || ![modalView mouse:[modalView convertPoint:[result locationInWindow] fromView:nil] inRect:modalView.contentRect])) {
                        if(result.type == NSMouseEntered || result.type == NSMouseMoved) {
                            result = nil;
                        }
                    }
                    
                    
                    if(![appWindow() isAcceptEvents]) {
                        
                        
                        result = nil;
                    }
                    
                }
                
            }
            
            
            if(result.type == NSLeftMouseUp) {
                
                if([result.window.firstResponder isKindOfClass:[NSClassFromString(@"TGMessagesTextView") class]])
                    [result.window.firstResponder mouseUp:result];
            }
            
            if(result.type == NSLeftMouseUp && [TMViewController isModalActive]) {
                
                NSArray *modals = [TMViewController modalsView];
                
                [modals enumerateObjectsUsingBlock:^(TGModalView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([obj isKindOfClass:[TGStickerPreviewModalView class]]) {
                        [obj close:YES];
                    }
                }];
                
            }
            
            return result;
            
        }
        
        
        if(( result.type == NSLeftMouseDown || result.type == NSLeftMouseUp) && result.clickCount > 1)
            return [NSEvent mouseEventWithType:result.type location:result.locationInWindow modifierFlags:result.modifierFlags timestamp:result.timestamp windowNumber:result.windowNumber context:result.context eventNumber:result.eventNumber clickCount:1 pressure:result.pressure];
        return result;
    };
    
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSLeftMouseUpMask | NSMouseEnteredMask | NSMouseMovedMask | NSCursorUpdateMask) handler:block2];
    
    
    id block3 = ^(NSEvent *incomingEvent) {
        
        if([incomingEvent.window.firstResponder class] == [SelectTextManager class]) { // hard fix for osx events bug
            
            
            
            MessagesViewController *viewController = [SelectTextManager currentTableView].viewController;
            
            
            NSPoint mouseLoc = [viewController.table.scrollView convertPoint:[incomingEvent locationInWindow] fromView:nil];
            
            
            BOOL isInside = [viewController.table.scrollView mouse:mouseLoc inRect:viewController.table.scrollView.bounds];
            
            
            if(isInside) {
                
                NSUInteger rowId = [viewController.table rowAtPoint:[viewController.table convertPoint:[incomingEvent locationInWindow] fromView:nil]];
                
                MessageTableItem *item = [viewController objectAtIndex:rowId];
                
                if([item isKindOfClass:NSClassFromString(@"MessageTableItemText")]) {
                    [viewController.table mouseDragged:incomingEvent];
                    
                    return [[NSEvent alloc] init];
                }
                
                
            }
            
            
        }
        
        return incomingEvent;
    };
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseDraggedMask) handler:block3];
    
    
    
//    id block4 = ^(NSEvent *incomingEvent) {
//        
//        return incomingEvent;
//    };
//    
//    [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskSwipe) handler:block4];

    
}





- (void)windowDidChangeBackingProperties:(NSNotification *)notification {
    
}


-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    if([SenderItem allSendersSaved])
        return NSTerminateNow;
    
    [SenderItem appTerminatedNeedSaveSenders];
    
    return NSTerminateCancel;
}




-(void)initializeSounds {
    // playSentMessage(NO);
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if([[MTNetwork instance] isAuth]) {
        [[Telegram sharedInstance] setIsWindowActive:YES];
        [[Telegram sharedInstance] setAccountOnline];
    }
    
    
    [TGPasslock appIncomeActive];
    
    if(![TMViewController isModalActive]) {
        
        if([Telegram isSingleLayout] && [[Telegram rightViewController].navigationViewController.currentController isKindOfClass:[StandartViewController class]])
            return;
        
        [[Telegram rightViewController] becomeFirstResponder];
    }
    
    else
        [[TMViewController modalView] becomeFirstResponder];
}

- (void) receiveSleepNote: (NSNotification*) note
{
    MTLog(@"receiveSleepNote: %@", [note name]);
    
}

- (void) receiveWakeNote: (NSNotification*) note
{
    [[MTNetwork instance] update];
    
    [[FullUsersManager sharedManager] drop];
    MTLog(@"receiveSleepNote: %@", [note name]);
}

- (void) registerSleepNotification
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    if([[MTNetwork instance] isAuth]) {
        [[Telegram sharedInstance] setIsWindowActive:NO];
        [[Telegram sharedInstance] setAccountOffline:NO];
    }
    [TGPasslock appResignActive];
}


- (void)initializeMainWindow {
    
    
    
    MainWindow *mainWindow = [[MainWindow alloc] init];
    
    [mainWindow makeKeyAndOrderFront:nil];
    
    
  
    
    [self releaseWindows];
    [self initializeSounds];
    
    self.mainWindow = mainWindow;
    
    
    [(MainViewController *)mainWindow.rootViewController updateWindowMinSize];
    
    
  //  [[Telegram rightViewController] addFirstControllerAfterLoadMainController:[[Telegram mainViewController] isSingleLayout] ? [Telegram leftViewController] : nil];

    
}

- (void)initializeLoginWindow {
    LoginWindow *loginWindow = [[LoginWindow alloc] init];
    [loginWindow makeKeyAndOrderFront:nil];
    [self releaseWindows];
    
    
    self.loginWindow = loginWindow;
    
    
    //[Telegram showEnterPasswordPanel];

}

- (void)releaseWindows {
    if(self.loginWindow) {
        [self.loginWindow realClose];
        self.loginWindow = nil;
    }
    
    if(self.mainWindow) {
        [self.mainWindow realClose];
        self.mainWindow = nil;
    }
}

- (TelegramWindow *)window {
    if(self.mainWindow) {
        return self.mainWindow;
    } else  {
        return self.loginWindow;
    }
}

static BOOL canNextLogout = true;

- (void)logoutWithForce:(BOOL)force {
    
    if (!canNextLogout) {
        return;
    }
    
    canNextLogout = false;
    
    dispatch_block_t block = ^ {
        
        [ASQueue dispatchOnMainQueue:^{
            [TMViewController hideModalProgress];
            
            [TGAudioPlayerWindow hide];
            
            [[MTNetwork instance] drop];
            
            [Storage drop];
            
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
            
            [Storage open:^{
                
                [[MTNetwork instance] initConnectionWithId:-1];
                
                [TGCache clear];
                [TGModernTypingManager drop];
                [SharedManager drop];
                [[MTNetwork instance] startNetwork];
                [Telegram drop];
                [TMViewController hidePasslock];
                [MessageSender drop];
                [Notification perform:LOGOUT_EVENT data:nil];
                
                [MessagesManager updateUnreadBadge];
                
                [self initializeLoginWindow];
                canNextLogout = true;
            }];
            
        }];
        
    };
    
    
    if([[MTNetwork instance] isAuth] && !force) {
        
        
        dispatch_block_t clearCache = ^ {
            [RPCRequest sendRequest:[TLAPI_auth_logOut create] successHandler:^(RPCRequest *request, id response) {
                
                [[Storage manager] drop:^{
                    block();
                }];
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                [TMViewController hideModalProgress];
                
                if(error.error_code == 502) {
                    confirm(NSLocalizedString(@"Auth.CantLogout", nil), NSLocalizedString(@"Auth.ForceLogout", nil), ^ {
                        
                        [[Storage manager] drop:^{
                            [self logoutWithForce:YES];
                        }];
                        
                    },nil);
                }
                
                
            } timeout:5];
        };
        
        confirm(appName(), NSLocalizedString(@"Confirm.ConfirmLogout", nil), ^{
            [TMViewController showModalProgress];
            
            [ASQueue dispatchOnStageQueue:^{
                
                [[NSFileManager defaultManager] removeItemAtPath:path() error:nil];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:path()
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
                
                clearCache();
                
            }];

        }, nil);
        

    } else {
        
        [ASQueue dispatchOnStageQueue:^{
            
            [[NSFileManager defaultManager] removeItemAtPath:path() error:nil];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path()
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
            
            block();
            
        }];
        
    }
    
}

//DCAudioFileRecorder		*gAudioFileRecorder = NULL;





- (void) checkUpdates {
#ifdef TGDEBUG
    [self.updater checkForUpdatesInBackground];
#endif
}




- (IBAction)updateProfilePhoto:(id)sender {
    
    //    TMImagePicker *pictureTaker = [TMImagePicker sharedInstance];
    //    [pictureTaker setType:TMImagePickerWebSearchDefaultSelection];
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    [pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
	[pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(640, 640)] forKey:IKPictureTakerOutputImageMaxSizeKey];
    [pictureTaker beginPictureTakerSheetForWindow:self.mainWindow withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
    
    //    [pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
    //	[pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(640, 640)] forKey:IKPictureTakerOutputImageMaxSizeKey];
    //    [pictureTaker beginPictureTakerSheetForWindow:self.mainWindow withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
}

- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf {
    if(returnCode == NSOKButton){
        NSImage *outputImage = [pictureTaker outputImage];
        
        [[UsersManager sharedManager] updateAccountPhotoByNSImage:outputImage completeHandler:^(TLUser *user) {
            
        } progressHandler:^(float progress) {
            
        } errorHandler:^(NSString *description) {
            
        }];
    }
}



- (BOOL)application:(NSApplication *)application
continueUserActivity: (id)userActivity
 restorationHandler: (void (^)(NSArray *))restorationHandler {
    
    BOOL handled = NO;
    
#ifdef __MAC_10_10
    
    
    // Extract the payload
    NSString *type = [(NSUserActivity *)userActivity activityType];
    
    
    
    NSDictionary *userInfo = [userActivity userInfo];
    
    
    
    int user_id = [userInfo[@"user_id"] intValue];
    
    if([UsersManager currentUserId] != user_id)
        return NO;
    
    
    
    
    
    if([type isEqualToString:USER_ACTIVITY_CONVERSATION]) {
        
        NSString *peerType = userInfo[@"peer"][@"type"];
        int peerId = [userInfo[@"peer"][@"id"] intValue];
        
        NSString *text = userInfo[@"text"];

        TLPeer *peer;
        
        TL_conversation *conversation;
        
        if(peerId > 0 ) {
            TLUser *user = [[UsersManager sharedManager] find:peerId];
            peer = [TL_peerUser createWithUser_id:peerId];
            conversation = user.dialog;
        } else {
            TLChat *chat = [[ChatsManager sharedManager] find:-peerId];
            peer = [TL_peerChat createWithChat_id:-peerId];
            conversation = chat.dialog;
        }
        
        if(!conversation)
            conversation = [[Storage manager] selectConversation:peer];
        
        if(!conversation)
        {
            handled = NO;
            
        } else {
            
            [[DialogsManager sharedManager] add:@[conversation]];
            
            [self.mainWindow.navigationController showMessagesViewController:conversation];
            
            TGInputMessageTemplate *template = conversation.inputTemplate;
            
            [template updateTextAndSave:[[NSAttributedString alloc] initWithString:text]];
            [template performNotification];
            
            BOOL didSetText = YES;
            
            
            if (didSetText)
            {
                [userActivity getContinuationStreamsWithCompletionHandler:^(__unused NSInputStream *inputStream, NSOutputStream *outputStream, NSError *error)
                 {
                     
                     if (error == nil)
                     {
                         @try {
                             [outputStream open];
                             [outputStream close];
                         }
                         @catch (NSException *exception) {
                         }
                         @finally {
                         }
                     }
                 }];
            }
            
            handled = YES;
            
            
            
        }
        
        
        
        [TMViewController hideModalProgress];
        
    }
    
    restorationHandler(@[]);
    
    [TMViewController hideModalProgress];
#endif
    
    
    
    return handled;
    
}

- (void)application:(NSApplication *)application didUpdateUserActivity:(id)userActivity  {
    [TMViewController hideModalProgress];
}

-(void)application:(NSApplication *)application
                  :(NSString *)userActivityType error:(NSError *)error {
    [TMViewController hideModalProgress];
}

- (BOOL)application:(NSApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    [TMViewController showModalProgress];
    
    NSArray *types = @[USER_ACTIVITY_CONVERSATION];
    
    BOOL accept = [types indexOfObject:userActivityType] != NSNotFound;;
    
    
    return accept;
}

- (void)setConnectionStatus:(NSString *)status {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.mainWindow setTitle:status ];
    //        [self.loginWindow setTitle:status];
    //    });
}

- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:BUNDLE_IDENTIFIER];
}

@end
