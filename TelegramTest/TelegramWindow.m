//
//  TelegramWindow.m
//  TelegramTest
//
//  Created by keepcoder on 02.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TelegramWindow.h"
#import "Telegram.h"
#import "HackUtils.h"

@interface TelegramWindow ()
@end

@implementation TelegramWindow

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if(self) {

       
    }
    return self;
}



- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType    defer:flag];
    if(self) {
        //[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self initialize:nil];
    
}

- (void)initialize:(TGWindowArchiver *)archiver {
    self.delegate = self;
    self.canHide = YES;
    [self setTitle:NSLocalizedString(@"App.Name", nil)];
    self.styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
    
    
     NSRect rect = self.frame;
    
    int width = 805;
    int height = 600;
    
    
    [self setMinSize:NSMakeSize(width-70, height)];
    
    if(!archiver) {
       
        
       
        rect.size = self.minSize;
        
        NSScreen *screen = [NSScreen mainScreen];
        rect.origin.x = roundf((screen.frame.size.width - rect.size.width) / 2);
        rect.origin.y = roundf((screen.frame.size.height - rect.size.height) / 2);
        
    } else {
        rect.origin = archiver.origin;
        rect.size = archiver.size;
    }
    
   
    [self setFrame:rect display:NO];
    
    [self.contentView setWantsLayer:YES];
    
}

-(void)windowDidResize:(NSNotification *)notification {
    _autoSaver.origin = self.frame.origin;
    _autoSaver.size = self.frame.size;
    
    [_autoSaver save];
}

-(void)windowDidMove:(NSNotification *)notification {
    _autoSaver.origin = self.frame.origin;
    _autoSaver.size = self.frame.size;
    
    [_autoSaver save];
}



- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)setRootViewController:(TMViewController *)rootViewController {
    self->_rootViewController = rootViewController;
    [self->_rootViewController viewWillAppear:NO];
    
    MTLog(@"%@",NSStringFromRect(self->_rootViewController.view.frame));
    
    self->_rootViewController.view.frame = NSMakeRect(self->_rootViewController.view.frame.origin.x, 0, self->_rootViewController.view.frame.size.width, self->_rootViewController.view.frame.size.height);
    
    [self.contentView addSubview:self->_rootViewController.view];
    
    
    [self->_rootViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self->_rootViewController viewDidAppear:NO];
}

- (void)close {
    if(self.class != NSClassFromString(@"TGHeadChatPanel")) {
        [(NSApplication *)[NSApplication sharedApplication] hide:nil];
    } else {
        [super close];
    }
    
    
}

- (void)dealloc {
    
}

- (void)realClose {
    [self setReleasedWhenClosed:NO];
    [super close];
}

@end
