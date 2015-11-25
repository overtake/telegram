//
//  TMBlueAddButtonView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 03.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMBlueAddButtonView.h"

@interface TMBlueAddButtonView ()
@property (nonatomic,strong) TMTextLayer *textLayer;
@property (nonatomic,assign) BOOL locker;
@property (nonatomic,strong) NSProgressIndicator *progress;
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) NSImageView *addImageView;
@end

@implementation TMBlueAddButtonView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.containerView = [[TMView alloc] initWithFrame:self.bounds];
        
        [self addSubview:self.containerView];
        
        self.containerView.wantsLayer = YES;
        self.containerView.layer.borderColor = NSColorFromRGB(0x64bbe3).CGColor;
        self.containerView.layer.borderWidth = 1.0f;
        self.containerView.layer.cornerRadius = 12;
        
        self.progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect((frame.size.width-10)/2, 2, 20, 20)];
        [self.progress setHidden:YES];
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [self addSubview:self.progress];
        
        self.textLayer = [TMTextLayer layer];
        self.textLayer.contentsScale = self.containerView.layer.contentsScale;
        self.textLayer.textFont = TGSystemFont(13);
        
        [self.containerView.layer addSublayer:self.textLayer];
        
        NSImage *img = image_AddSharedContact();
        
        self.addImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(9, 7, img.size.width, img.size.height)];
        
        self.addImageView.image = img;
        
        [self.containerView addSubview:self.addImageView];
        
      //  [self setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateHover];
        
        [self addTarget:self action:@selector(didNeedAddContact) forControlEvents:BTRControlEventClick];
        
        [self handleStateChange];
    }
    return self;
}

- (void)handleStateChange {
    [super handleStateChange];
    
    if(self.state & BTRControlStateHover) {
        self.containerView.layer.backgroundColor = NSColorFromRGB(0x64bbe3).CGColor;
        self.textLayer.textColor = NSColorFromRGB(0xffffff);
        self.addImageView.image = image_AddSharedContactHighlighted();
    } else {
        self.containerView.layer.borderColor = NSColorFromRGB(0x64bbe3).CGColor;
        self.containerView.layer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
        self.textLayer.textColor = NSColorFromRGB(0x3395ce);
        self.addImageView.image = image_AddSharedContact();
    }
}

- (void)didNeedAddContact {
    if(!self.phoneNumber || !self.contact)
        return;
    
    CHECK_LOCKER(self.locker);
    
    self.locker = YES;

    
    [[NewContactsManager sharedManager] importContact:[TL_inputPhoneContact createWithClient_id:rand_long() phone:self.phoneNumber first_name:self.contact.first_name last_name:self.contact.last_name] callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
        
        self.locker = NO;
        
        if(isAdd) {
            [self removeFromSuperview];
        }
        
    }];
}

-(void)setLocker:(BOOL)locker {
    self->_locker = locker;
    
    [self.progress setHidden:!self.locker];
    
    if(!self.progress.isHidden) {
        [self.progress startAnimation:self];
    } else {
        [self.progress stopAnimation:self];
    }
    
    [self.containerView setHidden:self.locker];
}

-(void)setContact:(TLUser *)contact {
    self->_contact = contact;
    
    self.locker = self.locker;
}

-(void)setString:(NSString *)string {
    self->_string = string;
    [self.textLayer setString:string];
    [self.textLayer sizeToFit];
    
    [self setFrameSize:NSMakeSize( self.textLayer.frame.size.width+60, self.frame.size.height)];
    [self.containerView setFrameSize:NSMakeSize(self.textLayer.frame.size.width+38, self.containerView.frame.size.height)];
    [self.textLayer setFrameOrigin:NSMakePoint(25, 2)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    // [NSColorFromRGB(0x64bbe3) set];
    // NSRectFill(NSMakeRect(10, 7, 1, 12));
    
    // NSRectFill(NSMakeRect(5, 12, 12, 1));
}

@end
