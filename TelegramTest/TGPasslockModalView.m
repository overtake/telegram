//
//  TGPasslockModalView.m
//  Telegram
//
//  Created by keepcoder on 23.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasslockModalView.h"
#import "TGPasslock.h"

@interface TGPasslockModalView ()
@property (nonatomic,strong) TMAvatarImageView *avatar;
@property (nonatomic,strong) NSSecureTextField *secureField;
@property (nonatomic,strong) BTRButton *enterButton;
@property (nonatomic,strong) TMNameTextField *descriptionField;
@property (nonatomic,strong) BTRButton *closeButton;

@property (nonatomic,assign) int state;

@property (nonatomic,strong) NSMutableArray *md5Hashs;


@end

@implementation TGPasslockModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _md5Hashs = [[NSMutableArray alloc] init];
        
        self.wantsLayer = YES;
        self.layer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
        
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        TMView *containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        
        [containerView setCenterByView:self];
        
        [containerView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMaxYMargin];
        
        [self addSubview:containerView];
        
        
        self.avatar = [TMAvatarImageView standartUserInfoAvatar];
        [self.avatar setFrameSize:NSMakeSize(100, 100)];
        
       
        
        
        [self.avatar setCenterByView:containerView];
        
        [self.avatar setFrameOrigin:NSMakePoint(NSMinX(self.avatar.frame), NSMinY(self.avatar.frame) + 50)];
        
        [containerView addSubview:self.avatar];
        
        
        [self.avatar setUser:[UsersManager currentUser]];
        
        
        self.secureField = [[BTRSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
        
        
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        
        [attrs appendString:NSLocalizedString(@"Passcode.EnterPlaceholder", nil) withColor:NSColorFromRGB(0xc8c8c8)];
        
        [attrs setAttributes:@{NSFontAttributeName:TGSystemFont(12)} range:attrs.range];
        
        [[self.secureField cell] setPlaceholderAttributedString:attrs];
        
        [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
        
       // [[self.secureField cell] setPlaceholderAttributedString:attrs];
        
        [self.secureField setAlignment:NSLeftTextAlignment];
        
        [self.secureField setCenterByView:containerView];
        
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
        
        [self.secureField setFrameOrigin:NSMakePoint(NSMinX(self.secureField.frame), NSMinY(self.avatar.frame) - 100)];
        
        
        [containerView addSubview:self.secureField];
        
        
        self.descriptionField = [[TMNameTextField alloc] initWithFrame:NSZeroRect];
        
        
        [self.descriptionField setSelector:@selector(profileTitle)];
        [self.descriptionField setUser:[UsersManager currentUser]];
        
        [self.descriptionField setFont:TGSystemFont(14)];
        
        [self.descriptionField setTextColor:DARK_BLACK];
        

        
        
        [self.descriptionField sizeToFit];
        
        [self.descriptionField setCenterByView:containerView];
        
        [self.descriptionField setFrameOrigin:NSMakePoint(NSMinX(self.descriptionField.frame), NSMinY(self.avatar.frame) - 40)];
        
        [containerView addSubview:self.descriptionField];
        
        self.closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ClosePopupDialog().size.width, image_ClosePopupDialog().size.height)];
        
        [self.closeButton setImage:image_ClosePopupDialog() forControlState:BTRControlStateNormal];
        
        
        [self.closeButton setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(self.closeButton.frame) - 20, NSHeight(self.frame) - NSHeight(self.closeButton.frame) - 20)];
        
        [self.closeButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
        
        weak();
        
        [self.closeButton addBlock:^(BTRControlEvents events) {
            
            
             weakSelf.passlockResult(NO,nil);
            
            [TMViewController hidePasslock];
            
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [self addSubview:self.closeButton];
        
        
        
        self.enterButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_PasslockEnter().size.width, image_PasslockEnter().size.height)];
        
        [self.enterButton setImage:image_PasslockEnter() forControlState:BTRControlStateNormal];
        [self.enterButton setImage:image_PasslockEnterHighlighted() forControlState:BTRControlStateHover];
        
        [self.enterButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf checkPassword];
            
        } forControlEvents:BTRControlEventClick];
        
        
        [self.enterButton setFrameOrigin:NSMakePoint(NSMaxX(self.secureField.frame) + 20, NSMinY(self.secureField.frame) + 3)];
        
        [containerView addSubview:self.enterButton];
        
      //  [self updateDescription];
        
    }
    
    return self;
}

-(void)updateDescription {
    NSDictionary *d = @{@(TGPassLockViewCreateType):@[NSLocalizedString(@"Passcode.EnterYourNewPasscode", nil),NSLocalizedString(@"Passcode.ReEnterYourPasscode", nil)],
                        @(TGPassLockViewChangeType):@[NSLocalizedString(@"Passcode.EnterYourOldPasscode", nil),NSLocalizedString(@"Passcode.EnterYourNewPasscode", nil),NSLocalizedString(@"Passcode.ReEnterYourPasscode", nil)],
                        @(TGPassLockViewConfirmType):@[NSLocalizedString(@"Passcode.EnterYourPasscode", nil)]};
    
    
    [[self.secureField cell] setPlaceholderString:d[@(_type)][_state]];
    
    
}


- (void)performShake {
    float a = 3;
    float duration = 0.04;
    
    NSBeep();
    
    [self.secureField prepareForAnimation];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.secureField setWantsLayer:NO];
        [self.secureField.window makeFirstResponder:self.secureField];
        [self.secureField setSelectionRange:NSMakeRange(0, self.secureField.stringValue.length)];
    }];
    
    [self.secureField setAnimation:[TMAnimations shakeWithDuration:duration fromValue:CGPointMake(-a + self.secureField.layer.position.x, self.secureField.layer.position.y) toValue:CGPointMake(a + self.secureField.layer.position.x, self.secureField.layer.position.y)] forKey:@"position"];
    [CATransaction commit];
}

-(void)checkPassword {
    
    NSString *hash = [self.secureField.stringValue md5];
    
    if(_type == TGPassLockViewConfirmType) {
        
        BOOL result = _passlockResult(YES,hash);
        
        if(!result) {
            [self performShake];
        } else {
            [TMViewController hidePasslock];
        }
        
        return;
        
    } else if(_type == TGPassLockViewCreateType) {
        
        if(_state == 1) {
            if([_md5Hashs[_state - 1] isEqualToString:hash]) {
                
                _passlockResult(YES,hash);
                
                [TMViewController hidePasslock];
                
            } else {
               [self performShake];
            }
            
            return;
        }
        
        
        
    } else if(_type == TGPassLockViewChangeType) {
        
        if(_state == 0) {
            
            if(![[MTNetwork instance] checkPasscode:[hash dataUsingEncoding:NSUTF8StringEncoding]]) {
                [self performShake];
                return;
            }
            
        } else if(_state == 2) {
            if([_md5Hashs[_state - 1] isEqualToString:hash]) {
                
               _passlockResult(YES,hash);
                
                
            } else {
                [self performShake];
            }
            
            return;
        }
    }
    
    [_secureField setStringValue:@""];
    
    _md5Hashs[_state] = hash;
    
    _state++;
    
    [self updateDescription];
    
    
    
}


-(void)showError {
    
}

-(void)setType:(TGPassLockViewType)type {
    _type = type;
    _state = 0;
    [_md5Hashs removeAllObjects];
    [self updateDescription];
    _closable = YES;
}

-(void)setClosable:(BOOL)closable {
    _closable = closable;
    
    [self.closeButton setHidden:!closable];
}

-(BOOL)becomeFirstResponder
{
    [self.window makeFirstResponder:self.secureField];
    
    return [self.secureField becomeFirstResponder];
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)scrollWheel:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)keyDown:(NSEvent *)theEvent {
    
}

-(void)keyUp:(NSEvent *)theEvent {
    
}

@end
