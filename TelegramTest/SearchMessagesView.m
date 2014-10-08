//
//  SearchMessagesView.m
//  Telegram
//
//  Created by keepcoder on 07.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchMessagesView.h"

@interface SearchMessagesView ()<TMSearchTextFieldDelegate>
@property (nonatomic,strong) TMSearchTextField *searchField;
@property (nonatomic,strong) TMTextButton *cancelButton;
@property (nonatomic,strong) BTRButton *nextButton;
@property (nonatomic,strong) BTRButton *prevButton;

@property (nonatomic,copy) void (^searchCallback)(NSString *search);
@property (nonatomic,copy) dispatch_block_t nextCallback;
@property (nonatomic,copy) dispatch_block_t prevCallback;
@property (nonatomic,copy) dispatch_block_t closeCallback;


@end

@implementation SearchMessagesView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super  initWithFrame:frameRect]) {
        
        self.searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect) - 160, 30)];
        
        self.searchField.autoresizingMask = NSViewWidthSizable;
        
        self.searchField.wantsLayer = YES;
        
        [self addSubview:self.searchField];
        
        
        self.searchField.delegate = self;
        
        [self.searchField setCenterByView:self];
        
        self.cancelButton = [TMTextButton standartUserProfileButtonWithTitle:NSLocalizedString(@"Search.Cancel", nil)];
        
        weakify();
        
        [self.cancelButton setTapBlock:^ {
            strongSelf.closeCallback();
        }];
        
        [self.cancelButton setCenterByView:self];

        [self.cancelButton setFrameOrigin:NSMakePoint(NSMinX(self.searchField.frame) + NSWidth(self.searchField.frame) + NSWidth(self.cancelButton.frame)/2 - 12, NSMinY(self.cancelButton.frame))];
        
        
        self.cancelButton.autoresizingMask =   NSViewMinXMargin;
        
        [self addSubview:self.cancelButton];
        
        NSImage *searchUp = [NSImage imageNamed:@"SearchUp"];
        NSImage *searchDown = [NSImage imageNamed:@"SearchDown"];
        
        
        self.prevButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, searchUp.size.width, searchUp.size.height)];
        self.nextButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, searchDown.size.width, searchDown.size.height)];
        
        [self.prevButton setBackgroundImage:searchUp forControlState:BTRControlStateNormal];
        [self.nextButton setBackgroundImage:searchDown forControlState:BTRControlStateNormal];
        
        [self.prevButton addBlock:^(BTRControlEvents events) {
            strongSelf.prevCallback();
        } forControlEvents:BTRControlEventClick];
        
        [self.nextButton addBlock:^(BTRControlEvents events) {
            strongSelf.nextCallback();
        } forControlEvents:BTRControlEventClick];
        
        
        [self.prevButton setCenterByView:self];
        [self.nextButton setCenterByView:self];
        
        [self.prevButton setFrameOrigin:NSMakePoint(23, NSMinY(self.prevButton.frame))];
        [self.nextButton setFrameOrigin:NSMakePoint(46, NSMinY(self.prevButton.frame))];
        
        [self addSubview:self.prevButton];
        [self addSubview:self.nextButton];
        
    }
    
    return self;
}


-(BOOL)becomeFirstResponder {
    return [self.searchField becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    return [self.searchField resignFirstResponder];
}

-(void)searchFieldTextChange:(NSString *)searchString {
    if(self.searchCallback != nil)
        self.searchCallback(searchString);
}

-(void)searchFieldDidEnter {
    if(self.nextCallback != nil)
        self.nextCallback();
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}



-(void)showSearchBox:(void (^)(NSString *search))callback next:(dispatch_block_t)nextCallback prevCallback:(dispatch_block_t)prevCallback closeCallback:(dispatch_block_t) closeCallback {
    
    self.searchCallback = callback;
    self.nextCallback = nextCallback;
    
    self.prevCallback = prevCallback;
    self.closeCallback = closeCallback;
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
    
    [GRAY_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
    
}
@end
