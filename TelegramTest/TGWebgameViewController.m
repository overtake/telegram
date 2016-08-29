//
//  TGWebgameViewController.m
//  Telegram
//
//  Created by keepcoder on 23/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebgameViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WeakReference.h"
#import "TGModalForwardView.h"
@interface TGWebgameViewController () <WebFrameLoadDelegate,WebUIDelegate>
@property (nonatomic,strong) WebView *webView;
@property (nonatomic,strong) TLUser *bot;
@property (nonatomic,strong) TLKeyboardButton *keyboard;
@property (nonatomic,strong) TL_localMessage *message;
@property (nonatomic,strong) NSString *internalGameId;
@end


@implementation TGWebgameViewController

static NSMutableArray *games;

static NSString *kGameEventStart = @"game_start";
static NSString *kGameEventMute = @"mute";
static NSString *kGameEventUnmute = @"unmute";

+(void)initialize {
    games = [NSMutableArray array];
}

-(void)dealloc {
    __block NSUInteger index = NSNotFound;
    
    [games enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.originalObjectValue == (__bridge void *)(self)) {
            index = idx;
            *stop = YES;
        }
        
    }];
    
    assert(index != NSNotFound);
    
    [games removeObjectAtIndex:index];
}

-(BOOL)becomeFirstResponder {
    
    [self.view.window makeFirstResponder:_webView];
    
    return YES;
}


-(void)loadView {
    [super loadView];
    
    _internalGameId = [NSString stringWithFormat:@"%ld",rand_long()];
    
    [games addObject:[WeakReference weakReferenceWithObject:self]];
    
    _webView = [[WebView alloc] initWithFrame:self.view.bounds];
    
    _webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    
    
    
    [self addSubview:_webView];
    _webView.UIDelegate = self;
    _webView.frameLoadDelegate = self;
    
    
    
}



-(void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    alert(_bot.fullName, message);
}

-(void)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler {
    confirm(_bot.fullName, message, ^{
        completionHandler(YES);
    }, ^{
        completionHandler(NO);
    });
}

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    [frame.windowObject evaluateWebScript:@"TelegramWebviewProxy = { postEvent:function(eventType, eventData) {gameHandler(eventType,eventData)}}"];
    
    JSGlobalContextSetName(frame.globalContext, JSStringCreateWithCFString( (__bridge CFStringRef)(_internalGameId) ));
    JSStringRef funcName = JSStringCreateWithUTF8CString("gameHandler");
    JSObjectRef funcObj = JSObjectMakeFunctionWithCallback(frame.globalContext, funcName, gameHandler);
    JSObjectSetProperty(_webView.mainFrame.globalContext, JSContextGetGlobalObject(frame.globalContext), funcName, funcObj, kJSPropertyAttributeNone, NULL);
    JSStringRelease(funcName);
}



JSValueRef gameHandler (JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount == 2 && JSValueGetType (ctx, arguments[0]) == kJSTypeString && JSValueGetType (ctx, arguments[1]) == kJSTypeString)
    {
        NSString * eventType = CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault,JSValueToStringCopy (ctx, arguments[0],exception)));
        NSString * data = CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault,JSValueToStringCopy (ctx, arguments[1],exception)));
        
        NSString *controllerName = CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault,JSGlobalContextCopyName(JSContextGetGlobalContext(ctx))));
        
         TGWebgameViewController *controller = getController(controllerName);
        
        if(controller && [controller respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:",eventType])]) {
            
            IMP imp = [controller methodForSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:",eventType]) ];
            if(imp) {
                void (*func)(id, SEL, id) = (void *)imp;
                func(controller, NSSelectorFromString(eventType) , data);
            }
            
        }
    }
    
    return JSValueMakeNull(ctx);
}


/*
 Start game proxy methods
 */

-(void)game_loaded:(NSString *)data {
    [self pushEvent:@"game_start" data:@{@"event":@"game_loaded"}];
}

-(void)game_over:(NSString *)data {
     [self pushEvent:@"game_start" data:@{@"event":@"game_over"}];
}

-(void)share_game:(NSString *)data {
    [[Telegram rightViewController] showInlineBotSwitchModalView:_bot query:[NSString stringWithFormat:@"@%@ %@",_bot.username,data]];

}

-(void)share_score:(NSString *)data {
    [self pushEvent:@"game_start" data:@{@"event":@"share_score"}];
    TGModalForwardView *forward = [[TGModalForwardView alloc] init];
    forward.messagesViewController = self.navigationViewController.messagesViewController;
    
    
    forward.messageCaller = self.message;
    
    [forward show:self.view.window animated:YES];
}

/*
 End game proxy methods
 */



-(void)pushEvent:(NSString *)event data:(NSDictionary *)data {
     NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:NULL] encoding:NSUTF8StringEncoding];
    [_webView.mainFrame.windowObject evaluateWebScript:[NSString stringWithFormat:@"TelegramGameProxy.receiveEvent('%@',%@);",event,json]];
}


TGWebgameViewController *getController(NSString *controllerName) {
    
    __block TGWebgameViewController *findOut = nil;
    
    [games enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGWebgameViewController *controller = obj.nonretainedObjectValue;
        
        if([controller.internalGameId isEqualToString:controllerName]) {
            findOut = controller;
            *stop = YES;
        }
        
    }];
    
    return findOut;
}

- (BOOL)webView:(WebView *)webView shouldPerformAction:(SEL)action fromSender:(id)sender {
    return YES;
}

- (void)webViewClose:(WebView *)sender {
    int bp = 0;
}

-(void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    if(frame == _webView.mainFrame)
        [self setCenterBarViewText:title];
}

-(void)startWithUrl:(NSString *)urlString bot:(TLUser *)bot keyboard:(TLKeyboardButton *)keyboard message:(TL_localMessage *)message {
    [self loadViewIfNeeded];
    _bot = bot;
    _keyboard = keyboard;
    _message = message;
    [self setCenterBarViewText:bot.fullName];
    [_webView setMainFrameURL:urlString];
}



@end
