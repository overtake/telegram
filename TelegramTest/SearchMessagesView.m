//
//  SearchMessagesView.m
//  Telegram
//
//  Created by keepcoder on 07.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchMessagesView.h"
#import "SpacemanBlocks.h"
@interface SearchMessagesView ()<TMSearchTextFieldDelegate>
@property (nonatomic,strong) TMSearchTextField *searchField;
@property (nonatomic,strong) TMTextButton *cancelButton;
@property (nonatomic,strong) BTRButton *nextButton;
@property (nonatomic,strong) BTRButton *prevButton;

@property (nonatomic,strong) NSProgressIndicator *progressIndicator;

@property (nonatomic,copy) void (^goToMessage)(TL_localMessage *msg, NSString *searchString);
@property (nonatomic,copy) dispatch_block_t closeCallback;


@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,assign) BOOL locked;

@property (nonatomic,strong) SMDelayedBlockHandle block;

@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic,assign) int currentIdx;


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
            [strongSelf.controller jumpToLastMessages:YES];
            [strongSelf.request cancelRequest];
            strongSelf.request = nil;
        }];
        
        [self.cancelButton setCenterByView:self];
        [self.cancelButton setFrameOrigin:NSMakePoint(NSMinX(self.cancelButton.frame), NSMinY(self.cancelButton.frame) + 1)];
       
        
        [self addSubview:self.cancelButton];
        
        
        
        self.prevButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_SearchUp().size.width, image_SearchUp().size.height)];
        self.nextButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_SearchDown().size.width, image_SearchDown().size.height)];
        
        [self.prevButton setBackgroundImage:image_SearchUp() forControlState:BTRControlStateNormal];
        [self.nextButton setBackgroundImage:image_SearchDown() forControlState:BTRControlStateNormal];
        
        [self.prevButton addBlock:^(BTRControlEvents events) {
           [strongSelf prev];
        } forControlEvents:BTRControlEventClick];
        
        [self.nextButton addBlock:^(BTRControlEvents events) {
           [strongSelf next];
        } forControlEvents:BTRControlEventClick];
        
        
        [self.prevButton setCenterByView:self];
        [self.nextButton setCenterByView:self];
        
        [self.prevButton setFrameOrigin:NSMakePoint(23, NSMinY(self.prevButton.frame))];
        [self.nextButton setFrameOrigin:NSMakePoint(46, NSMinY(self.prevButton.frame))];
        
        self.progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(25, 0, 20, 20)];
        
        [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        
        [self.progressIndicator setCenteredYByView:self];
        
        [self addSubview:_progressIndicator];
        
        _locked = YES;
        self.locked = NO;
        
        [self addSubview:self.prevButton];
        [self addSubview:self.nextButton];
        
    }
    
    return self;
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_searchField setFrameSize:NSMakeSize(newSize.width - 160, NSHeight(_searchField.frame))];
    
    int minX = NSMinX(self.searchField.frame) + NSWidth(self.searchField.frame);
    int maxX = NSWidth(self.frame);
    
    int dif = ((maxX - minX) - NSWidth(self.cancelButton.frame)) /2;
    
    [self.cancelButton setFrameOrigin:NSMakePoint(minX + dif, NSMinY(self.cancelButton.frame) )];
}

-(BOOL)becomeFirstResponder {
    return [self.searchField becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    return [self.searchField resignFirstResponder];
}

-(void)searchFieldTextChange:(NSString *)searchString {
    
    self.locked = YES;
    
    self.messages = [[NSMutableArray alloc] init];
    
    _currentIdx = -1;
    
    cancel_delayed_block(_block);
    [_request cancelRequest];
    
    if(searchString.length > 0) {
        _block = perform_block_after_delay(0.3,  ^{
            
            _block = nil;
            
            [self load:YES];
            
        });
    } else {
        self.locked = NO;
    }
    
}

-(void)load:(BOOL)first {
    
    [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:self.controller.conversation.inputPeer q:self.searchField.stringValue filter:[TL_inputMessagesFilterEmpty create] min_date:0 max_date:0 offset:(int)self.messages.count max_id:0 limit:100] successHandler:^(id request, TL_messages_messages *response) {
        
        
        [TL_localMessage convertReceivedMessages:response.messages];
        
        if(response.messages.count > 0) {
            [self.messages addObjectsFromArray:response.messages];
        }
        
        if([response isKindOfClass:[TL_messages_messagesSlice class]]) {
           if(response.messages.count > 0)
               [self load:NO];
        }
        if(first){
            self.locked = NO;
            [self next];
        }
        
        [self updateSearchArrows];
        
        
    } errorHandler:^(id request, RpcError *error) {
        self.locked = NO;
    }];
}

-(void)updateSearchArrows {
    [self.prevButton setBackgroundImage:self.messages.count == 0 ? image_SearchUpDisabled() : image_SearchUp() forControlState:BTRControlStateNormal];
    
    [self.nextButton setBackgroundImage:self.messages.count == 0 ? image_SearchDownDisabled() : image_SearchDown() forControlState:BTRControlStateNormal];
    
    
}

-(void)next {
    
    if(_messages.count == 0)
        return;
    
    if(++_currentIdx == _messages.count)
    {
        _currentIdx = 0;
    }
    
    _goToMessage(_messages[_currentIdx],_searchField.stringValue);
}

-(void)prev {
    if(_messages.count == 0)
        return;
    
    
    if(--_currentIdx == -1)
    {
        _currentIdx = (int)_messages.count - 1;
    }
    
    _goToMessage(_messages[_currentIdx],_searchField.stringValue);
}

-(void)setLocked:(BOOL)locked {
    
    if(_locked == locked)
        return;
    
    
    _locked = locked;
    
    if(_locked)
    {
        [self.progressIndicator startAnimation:self];
    } else {
        [self.progressIndicator stopAnimation:self];
    }
    
    [self.progressIndicator setHidden:!locked];
    [self.nextButton setHidden:locked];
    [self.prevButton setHidden:locked];
}

-(void)searchFieldDidEnter {
    [self next];
    
    [self.searchField setSelectedRange:NSMakeRange(self.searchField.stringValue.length,0)];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}



-(void)showSearchBox:( void (^)(TL_localMessage *msg, NSString *searchString))callback closeCallback:(dispatch_block_t) closeCallback {
    
    self.messages = nil;
    self.currentIdx = -1;
    [self.searchField setStringValue:@""];
    
    [self.searchField becomeFirstResponder];
    
    self.goToMessage = callback;
    self.closeCallback = closeCallback;
    
    [self setFrameSize:NSMakeSize(self.controller.view.frame.size.width, NSHeight(self.frame))];
    
    [self updateSearchArrows];
    
}

-(NSString *)currentString {
    return self.searchField.stringValue;
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
