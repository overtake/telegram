//
//  TGSEnterPasscodeView.m
//  Telegram
//
//  Created by keepcoder on 19.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSEnterPasscodeView.h"
#import "BTRButton.h"
#import "BTRSecureTextField.h"
#import "TMAttributedString.h"
#import "TGSAppManager.h"
#import "NSStringCategory.h"
#import "TGS_MTNetwork.h"
#import "TGImageView.h"
#import "TGSImageObject.h"
#import "ShareViewController.h"
@interface TGSEnterPasscodeView ()
@property (nonatomic,strong) NSSecureTextField *secureField;
@property (nonatomic,strong) BTRButton *enterButton;
@property (nonatomic,strong) TGImageView *avatar;
@property (nonatomic,strong) BTRButton *cancelButton;
@end

@implementation TGSEnterPasscodeView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        
//        _avatar = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
//        
//        
//         [_avatar setCenterByView:self];
//        
//        [_avatar setFrameOrigin:NSMakePoint(NSMinX(_avatar.frame), NSMinY(_avatar.frame) + 50)];
//        
//        [self addSubview:_avatar];
//        
//        TLUser *user = [ClassStore deserialize:[[TGSAppManager standartUserDefaults] objectForKey:@"selfUser"]];
//        
//        TGSImageObject *imageObject = [[TGSImageObject alloc] initWithLocation:user.photo.photo_small];
//        
//        imageObject.imageSize = NSMakeSize(100, 100);
//        
//        _avatar.object = imageObject;
//        
//        
        
        self.backgroundColor = [NSColor whiteColor];
        
        self.secureField = [[BTRSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
        
        
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        
        [attrs appendString:NSLocalizedString(@"Passcode.EnterPlaceholder", nil) withColor:NSColorFromRGB(0xc8c8c8)];
        
        [attrs setAttributes:@{NSFontAttributeName:TGSystemFont(12)} range:attrs.range];
        
        [[self.secureField cell] setPlaceholderAttributedString:attrs];
        
        [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
        
        // [[self.secureField cell] setPlaceholderAttributedString:attrs];
        
        [self.secureField setAlignment:NSLeftTextAlignment];
        
        [self.secureField setCenterByView:self];
        
        [self.secureField setBordered:NO];
        [self.secureField setDrawsBackground:YES];
        
        [self.secureField setBackgroundColor:NSColorFromRGB(0xF1F1F1)];
        
        [self.secureField setFocusRingType:NSFocusRingTypeNone];
        
        [self.secureField setBezeled:NO];
        
        
        self.secureField.wantsLayer = YES;
        self.secureField.layer.cornerRadius = 4;
        
        //  self.secureField.layer.masksToBounds = YES;
        
        
        [self.secureField setAction:@selector(checkPassword)];
        [self.secureField setTarget:self];
        
        [self.secureField setFont:TGSystemFont(14)];
        [self.secureField setTextColor:DARK_BLACK];
        
        [self.secureField setCenterByView:self];
        
//        [self.secureField setFrameOrigin:NSMakePoint(NSMinX(_secureField.frame), NSMinY(_secureField.frame) - 30)];
        
        
        [self addSubview:self.secureField];
        
        
        weak();
        
         self.enterButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_PasslockEnter().size.width, image_PasslockEnter().size.height)];
        
        [self.enterButton setImage:image_PasslockEnter() forControlState:BTRControlStateNormal];
        [self.enterButton setImage:image_PasslockEnterHighlighted() forControlState:BTRControlStateHover];
        
        [self.enterButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf checkPassword];
            
        } forControlEvents:BTRControlEventClick];
        
        
        [self.enterButton setFrameOrigin:NSMakePoint(NSMaxX(self.secureField.frame) + 20, NSMinY(self.secureField.frame) + 3)];
        
        [self addSubview:self.enterButton];
        
        
        
        _cancelButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_cancelButton.frame), 0, NSWidth(self.frame), 50)];
        
        _cancelButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [_cancelButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
        
        [_cancelButton addBlock:^(BTRControlEvents events) {
            
            [ShareViewController close];
            
            
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:_cancelButton];
        
        TMView *topSeparator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, NSWidth(self.frame), DIALOG_BORDER_WIDTH)];
        
        topSeparator.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self addSubview:topSeparator];
        
    }
    
    return self;
}

-(void)checkPassword {
    
     NSString *hash = [self.secureField.stringValue md5];
    
    BOOL result = _passlockResult(YES,hash);
    
    if(!result) {
        [self.secureField performShake:nil];
    } else {
        [TGSAppManager hidePasslock];
    }
    
    return;
}

@end
