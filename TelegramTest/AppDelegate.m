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
#import "TGDialog+Extensions.h"
//#import "AFnetworkActivityIndicatorManager.h"
#import "SSKeychain.h"

#ifdef TGDEBUG

#import <Sparkle/Sparkle.h>
#import "FFYDaemonController.h"
#endif

#import "ImageStorage.h"
#import "FileUtils.h"
#import "MTNetwork.h"
#import "MessageSender.h"
#import <Quartz/Quartz.h>
#import "SelfDestructionController.h"
#import "TGProccessUpdates.h"
#import "TMMediaController.h"
#import "DialogsHistoryController.h"
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
#import "EmojiViewController.h"
#import "RBLPopover.h"
#import "NSTextView+EmojiExtension.h"


@interface NSUserNotification(For107)

@property (nonatomic, strong) NSAttributedString *response;

@end

@interface AppDelegate ()


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
    
    if(!self.mainWindow.isKeyWindow)
        return;
    
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if(url) {
        
        if([[url absoluteString] hasPrefix:TGImportCardPrefix]) {
            open_card([[url absoluteString] substringFromIndex:TGImportCardPrefix.length]);
            return;
        }
        
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        NSString *absoluteString = [url absoluteString];
        NSRange range = [absoluteString rangeOfString:@"?"];
        if(range.length == 1) {
            NSString *query = [absoluteString substringFromIndex:range.location+1];
            for (NSString *param in [query componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2)
                    continue;
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }
        }
        
        if(range.location > 12) {
            NSString *method = [absoluteString substringWithRange:NSMakeRange(11, range.location-11)];
            DLog(@"method %@", method);
            
            if([method isEqualToString:@"msg"]) {
                
                NSString *number = [params objectForKey:@"to"];
                NSString *msg = [params objectForKey:@"msg"];
                
                if(msg) {
                    msg = [[msg trim] URLDecode];
                }
                if(!number) {
                    [self.telegram.firstController newMessage:[[NSMenuItem alloc] initWithTitle:@"lol" action:@selector(newMessage:) keyEquivalent:@""]];
                    return;
                }
                
                if([number hasPrefix:@"+"] && number.length > 1)
                    number = [number substringFromIndex:1];
                
                NSArray *users = [[UsersManager sharedManager] all];
                TGUser *searchUser = nil;
                for(TGUser *user in users) {
                    if([user.phone isEqualToString:number]) {
                        searchUser = user;
                        break;
                    }
                }
                
                TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:searchUser.n_id];
                
                if(searchUser) {
                    [[Telegram rightViewController] showByDialog:dialog sender:self];
                    if(msg) {
                        [[[Telegram rightViewController] messagesViewController] setStringValueToTextField:msg];
                    }
                }
            }
        }
    }
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
#ifdef TGDEBUG
    
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:HOCKEY_APP_IDENTIFIER companyName:HOCKEY_APP_COMPANY delegate:self];
    [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled:YES];
    [[BITHockeyManager sharedHockeyManager].crashManager setAutoSubmitCrashReport: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
#else 
    
    [self showMainApplicationWindowForCrashManager:nil];
    
#endif
    
    
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
    
    TL_conversation *dialog = [[DialogsManager sharedManager] find:[[userInfo objectForKey:@"peer_id"] intValue]];
    
    if(dialog == nil) {
        ELog(@"nil dialog here, check it");
        return;
    }
    
    [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:self];
    
    
    
    if (floor(NSAppKitVersionNumber) > 1187 && notification.activationType == 3) { //NSUserNotificationActivationTypeReplied)
        NSString *userResponse = notification.response.string;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Telegram rightViewController].messagesViewController sendMessage:userResponse];
        });
        
        return;
    }
    
    
}

- (void)initializeApplication {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSThread currentThread] setName:@"Real Main Thread"];
    });
}


- (void)showMainApplicationWindowForCrashManager:(id)crashManager {
    

//    NSString *keeper = [[NSBundle mainBundle] pathForResource:@"TGKeeper" ofType:@""];
//
//    FFYDaemonController *daemonController = [[FFYDaemonController alloc] init];
//    
//    daemonController.launchPath = keeper;
//    
//    [daemonController setDaemonStartedCallback:^(NSNumber *pid) {
//        NSLog(@"started");
//    }];
//    
//    [daemonController setDaemonStoppedCallback:^ {
//        NSLog(@"stopped");
//    }];
//    
//    [daemonController start];
//    
    
    [self initializeApplication];
    
    
    [SharedManager sharedManager];
    
    [SecretChatAccepter instance];
    
    [self initializeUpdater];
    [self initializeKeyDownHandler];
    
    if ([NSUserNotification class] && [NSUserNotificationCenter class]) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    }
    
    if([[MTNetwork instance] isAuth]) {
        [self initializeMainWindow];
    } else {
        //[self initializeLoginWindow];
        [self logoutWithForce:NO];
    }
    
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        NSImageView *imageView = [[NSImageView alloc] init];
    //        imageView.frame = NSMakeRect(0, 0, image.size.width, image.size.height);
    //        imageView.alphaValue = 0.5;
    //        imageView.image = image;
    //
    //        imageView.wantsLayer = YES;
    //        NSWindow *window = self.mainWindow;
    //        [window setFrame:NSMakeRect(0, 0, image.size.width, image.size.height) display:YES];
    //        [window.contentView addSubview:imageView];
    //    });
    
    
}



- (void)initializeUpdater {
    
    
#ifdef TGDEBUG
    
    [self.updater setAutomaticallyChecksForUpdates:YES];
  //  [self.updater setAutomaticallyDownloadsUpdates:NO];
    
    NSString *feedURL = @"https://rink.hockeyapp.net/api/2/apps/c55f5e74ae5d0ad254df29f71a1b5f0e";
    
    #ifdef TGStable
    
    feedURL = @"https://rink.hockeyapp.net/api/2/apps/d77af558b21e0878953100680b5ac66a";
    
    #endif
    
    [self.updater setFeedURL:[NSURL URLWithString:feedURL]];
    
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
    id block = ^(NSEvent *incomingEvent) {
        NSEvent *result = incomingEvent;
        
        if(result.window != self.mainWindow) {
            
            if(incomingEvent.keyCode == 53 && ![result.window respondsToSelector:@selector(popover)]) {
                [result.window close];
                
                return result;
            }
            
            if([result.window isKindOfClass:[QLPreviewPanel class]]) {
                 return result;
            }
            
        }
        
        if([Telegram rightViewController].navigationViewController.isLocked)
            return result;
        
        
        id responder = self.mainWindow.firstResponder;
                
        if(incomingEvent.keyCode == 48) {
            
            int keyCode = incomingEvent.keyCode;
            
            if(incomingEvent.modifierFlags == 262401)
                keyCode = 125;
            if(incomingEvent.modifierFlags == 393475)
                keyCode = 126;
            
             incomingEvent = [NSEvent keyEventWithType:incomingEvent.type location:incomingEvent.locationInWindow modifierFlags:incomingEvent.modifierFlags timestamp:incomingEvent.timestamp windowNumber:incomingEvent.windowNumber context:incomingEvent.context characters:incomingEvent.characters charactersIgnoringModifiers:incomingEvent.charactersIgnoringModifiers isARepeat:incomingEvent.isARepeat keyCode:keyCode];
            
        }
        
       
        
        if(incomingEvent.keyCode == 125 || incomingEvent.keyCode == 126) {
            BOOL result = YES;
            
            if([responder isKindOfClass:[NSTextField class]]) {
                NSTextField *textField = responder;
                result = !textField.stringValue.length;
            } else if([responder isKindOfClass:[TMSearchTextField class]]) {
                result = incomingEvent.keyCode == 126;
            } else if ([responder isKindOfClass:[NSTextView class]]) {
                NSTextView *textView = responder;
                if([textView.superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                    result = incomingEvent.keyCode == 125;
                } else {
                    result = !textView.string.length;
                }
            }
            
            
            if(result) {
                [[TMTableView current] keyDown:incomingEvent];
                return [[NSEvent alloc] init];
            }
            
        } else if(incomingEvent.keyCode == 53) {
            
            if([Telegram rightViewController].messagesViewController.dialog == nil && ![responder isKindOfClass:NSClassFromString(@"_NSPopoverWindow")]) {
                
                if(![responder isKindOfClass:[NSTextView class]] || ![((NSTextView *)responder).superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                    [[Telegram leftViewController] becomeFirstResponder];
                } else if([((NSTextView *)responder).superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                    [((NSTextView *)responder) setString:@""];
                    [((NSTextView *)responder) didChangeText];
                }
                
                return incomingEvent;
            }
            
            
            
            [[[Telegram sharedInstance] firstController] backOrClose:[[NSMenuItem alloc] initWithTitle:@"Profile.Back" action:@selector(backOrClose:) keyEquivalent:@""]];
            
            
            
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
            if(incomingEvent.modifierFlags == 256 && [Telegram rightViewController].navigationViewController.currentController == [Telegram rightViewController].messagesViewController) {
                [[[Telegram rightViewController] messagesViewController] becomeFirstResponder];
            }
        }
        
        if(((result.modifierFlags & 1310720) == 1310720) && result.keyCode == 49) {
            NSTextView *textView = responder;
            if([responder isKindOfClass:[NSTextView class]] && ![textView.superview.superview isKindOfClass:NSClassFromString(@"_TMSearchTextField")]) {
                [textView showEmoji];
                
            }
            
            return [[NSEvent alloc]init];
        }
        
        if((result.modifierFlags & 1048840 ) == 1048840 && result.keyCode == 3) {
            
            if([Telegram rightViewController].navigationViewController.currentController == [[Telegram rightViewController] messagesViewController]) {
                [[[Telegram rightViewController] messagesViewController] showSearchBox];
            }
            
             return [[NSEvent alloc]init];
            
        }
        
        return result;
    };
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask) handler:block];
    
    ///MOuse
    id block2 = ^(NSEvent *incomingEvent) {
        NSEvent *result = incomingEvent;
        
        if(result.window != [TMMediaController controller].panel) {
            
            if(result.window == [NSApp mainWindow] && [result.window isKindOfClass:[MainWindow class]]) {
                if(![(MainWindow *)[NSApp mainWindow] isAcceptEvents]) {
                    if([result.window.contentView hitTest:[result locationInWindow]]) {
                        result = nil;
                    }
                    
                }
                
            }
            
            return result;
            
        }
        
        if(( result.type == NSLeftMouseDown || result.type == NSLeftMouseUp) && result.clickCount > 1)
            return [NSEvent mouseEventWithType:result.type location:result.locationInWindow modifierFlags:result.modifierFlags timestamp:result.timestamp windowNumber:result.windowNumber context:result.context eventNumber:result.eventNumber clickCount:1 pressure:result.pressure];
        return result;
    };
    
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSLeftMouseUpMask | NSMouseEnteredMask | NSMouseMovedMask | NSCursorUpdateMask) handler:block2];
}


-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
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
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    if([[MTNetwork instance] isAuth]) {
        [[Telegram sharedInstance] setIsWindowActive:NO];
        [[Telegram sharedInstance] setAccountOffline:NO];
    }
    
}


- (void)initializeMainWindow {
    
    MainWindow *mainWindow = [[MainWindow alloc] init];
    
    [mainWindow makeKeyAndOrderFront:nil];
    
    
    [self releaseWindows];
    [self initializeSounds];
    
    self.mainWindow = mainWindow;
    
    
    [(MainViewController *)mainWindow.rootViewController updateWindowMinSize];
    
}

- (void)initializeLoginWindow {
    LoginWindow *loginWindow = [[LoginWindow alloc] init];
    [loginWindow makeKeyAndOrderFront:nil];
    [self releaseWindows];
    
    self.loginWindow = loginWindow;
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

- (void)logoutWithForce:(BOOL)force {
    
    dispatch_block_t block = ^ {
        [[Storage manager] drop:^{
            
            [[TMTypingManager sharedManager] drop];
            [SharedManager drop];
            [[MTNetwork instance] drop];
            [Telegram drop];
            [MessageSender drop];
            [Notification perform:LOGOUT_EVENT data:nil];
            
            [[MessagesManager sharedManager] setUnread_count:0];
            
            [self initializeLoginWindow];
        }];
    };
    
    if([[MTNetwork instance] isAuth] && !force) {
        [RPCRequest sendRequest:[TLAPI_auth_logOut create] successHandler:^(RPCRequest *request, id response) {
            
            block();
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            if(error.error_code == 502) {
                confirm(NSLocalizedString(@"Auth.CantLogout", nil), NSLocalizedString(@"Auth.ForceLogout", nil), ^ {
                    [self logoutWithForce:YES];
                });
            }
        } timeout:5];
    } else {
        block();
    }
    
}

//DCAudioFileRecorder		*gAudioFileRecorder = NULL;





- (void) checkUpdates {
#ifdef TGDEBUG
    [self.updater checkForUpdatesInBackground];
#endif
}


- (IBAction)clearImagesCache:(id)sender {
    [ImageStorage clearCache];
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
        
        [[UsersManager sharedManager] updateAccountPhotoByNSImage:outputImage completeHandler:^(TGUser *user) {
            
        } progressHandler:^(float progress) {
            
        } errorHandler:^(NSString *description) {
            
        }];
    }
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
