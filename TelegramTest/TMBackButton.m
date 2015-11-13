//
//  TMBackButton.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/8/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBackButton.h"
#import "Telegram.h"
#import "TGUnreadMarkView.h"

@interface TMBackButton ()
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic,strong) TGUnreadMarkView *backUnreadMarkView;

@end

@implementation TMBackButton

- (id)initWithFrame:(NSRect)frame string:(NSString *)string {
    self = [super init];
    if (self) {
        
       
        
        
        NSImage *backImage = image_boxBack();
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 5, backImage.size.width, backImage.size.height)];
        self.imageView.image = backImage;
        
        [self addSubview:self.imageView];
        
       
        self.field = [TMTextField defaultTextField];
        
        [self.field setEditable:NO];
        [self.field setDrawsBackground:NO];
        [self.field setSelectable:NO];
        [self.field setBezeled:NO];
        [self.field setBordered:NO];
        [self.field setStringValue:string];
        
        [self.field setFont:TGSystemFont(14)];
        
        [self.field setFrameOrigin:NSMakePoint(0, 0)];
        
        [self.field setTextColor:BLUE_UI_COLOR];
        
        [self addSubview:self.field];
        
    
        
        self.backUnreadMarkView = [[TGUnreadMarkView alloc] init];
        
        [self.backUnreadMarkView setUnreadCount:@"100"];
        
        
        [self addSubview:self.backUnreadMarkView];
        
        
        
        [self setTarget:self selector:@selector(click)];
        
        [Notification addObserver:self selector:@selector(didChangedLayout:) name:LAYOUT_CHANGED];
    }
    return self;
}

-(void)didChangedLayout:(NSNotification *)notification {
    [self updateBackButton];
}

-(void)setTarget:(id)target selector:(SEL)selector {
    self.target = target;
    self.selector = selector;
}


-(void)mouseDown:(NSEvent *)theEvent {
    if(self.target && self.selector) {
        [self.target performSelector:self.selector];
    } else {
        [super mouseDown:theEvent];
    }
}

-(void)updateBackButton {
    
    
    if(self.controller.navigationViewController == ((TelegramWindow *)[NSApp mainWindow]).navigationController) {
        if((self.controller.navigationViewController.viewControllerStack.count > 2 || [[Telegram mainViewController] isSingleLayout]) && ![[Telegram rightViewController] isModalViewActive]) {
            [self.field setStringValue:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"Compose.Back",nil)]];
        } else if([[Telegram rightViewController] isModalViewActive]) {
            [self.field setStringValue:NSLocalizedString(@"Cancel", nil)];
        } else {
            [self.field setStringValue:NSLocalizedString(@"Close", nil)];
        }
        
        [self.imageView setHidden:(self.controller.navigationViewController.viewControllerStack.count <= 2 && ![Telegram isSingleLayout]) || [[Telegram rightViewController] isModalViewActive]];
        
        
        [self.backUnreadMarkView setHidden:!([self.controller.navigationViewController.currentController isKindOfClass:[MessagesViewController class]] && [[Telegram mainViewController] isSingleLayout])];
    } else {
        [self.field setStringValue:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"Compose.Back",nil)]];
        [self.imageView setHidden:NO];
        [self.backUnreadMarkView setHidden:YES];
    }
   
    
   
    
    [self.field sizeToFit];
    
    
    [self setFrameSize:NSMakeSize(NSWidth(self.field.frame) + 20, NSHeight(self.field.frame) + 20)];
    
    [self.field setCenterByView:self];
    
    [self.field setFrameOrigin:NSMakePoint(2, self.field.frame.origin.y)];
    
    [self.backUnreadMarkView setFrameOrigin:NSMakePoint(3, NSHeight(self.frame) - NSHeight(self.backUnreadMarkView.frame)  )];
    
    [self.imageView setCenterByView:self];
    
    [self.imageView setFrameOrigin:NSMakePoint(0, self.imageView.frame.origin.y -2)];
}


-(void)setDrawUnreadView:(BOOL)drawUnreadView {
    self->_drawUnreadView = drawUnreadView;
    
    [self draw];
}

-(void)draw {
    
}

- (void)click {
    [self.controller.navigationViewController goBackWithAnimation:YES];
}





@end
