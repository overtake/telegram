//
//  MessageTableNavigationTitleView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableNavigationTitleView.h"
#import "TGEncryptedChat+Extensions.h"
#import "TGTimer.h"
#import "ImageUtils.h"
#import "TGAnimationBlockDelegate.h"
#import "TGTimerTarget.h"
@interface MessageTableNavigationTitleView()<TMTextFieldDelegate>
@property (nonatomic, strong) TMNameTextField *nameTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;

@property (nonatomic,strong) TMTextField *typingTextField;

@property (nonatomic,strong) TMView *containerView;



@end



@implementation MessageTableNavigationTitleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable];
        
        self.typingTextField = [TMTextField defaultTextField];
        
        self.typingTextField.fieldDelegate = self;
        
        self.nameTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(0, 3, 0, 0)];
        [self.nameTextField setAlignment:NSCenterTextAlignment];
        [self.nameTextField setAutoresizingMask:NSViewWidthSizable];
        [self.nameTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        [self.nameTextField setTextColor:NSColorFromRGB(0x222222)];
        [self.nameTextField setSelector:@selector(titleForMessage)];
        [self.nameTextField setEncryptedSelector:@selector(encryptedTitleForMessage)];
        [[self.nameTextField cell] setTruncatesLastVisibleLine:YES];
        [[self.nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameTextField setDrawsBackground:NO];
        [self.nameTextField setNameDelegate:self];
        [self addSubview:self.nameTextField];
    
        self.statusTextField = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(0, 3, 0, 0)];
        [self.statusTextField setSelector:@selector(statusForMessagesHeaderView)];
        [self.statusTextField setAlignment:NSCenterTextAlignment];
        [self.statusTextField setStatusDelegate:self];
        [self.statusTextField setDrawsBackground:NO];
        
        //[self.statusTextField setBackgroundColor:NSColorFromRGB(0x000000)];
        
        [self addSubview:self.statusTextField];
        
        self.attributedString = [[NSMutableAttributedString alloc] init];
        
        self.containerView = [[TMView alloc] initWithFrame:NSZeroRect];
        
        [self addSubview:self.containerView];
        
         self.containerView.wantsLayer = YES;
        
        
        [self.containerView addSubview:self.typingTextField];
    
        
    }
    return self;
}

-(void)textFieldDidChange:(id)field {
   [self buildForSize:self.bounds.size];
}

- (void)setDialog:(TL_conversation *)dialog {
    self->_dialog = dialog;
    
    
    
    if(self.dialog.type == DialogTypeChat) {
        TGChat *chat = self.dialog.chat;
        [self.nameTextField setChat:chat];
        [self.statusTextField setChat:chat];
    } else if(self.dialog.type == DialogTypeSecretChat) {
        TGUser *user = self.dialog.encryptedChat.peerUser;
        [self.nameTextField setUser:user isEncrypted:YES];
        [self.statusTextField setUser:user];
    } else if(self.dialog.type == DialogTypeBroadcast) {
        
        TL_broadcast *broadcast = self.dialog.broadcast;
        [self.nameTextField setBroadcast:broadcast];
        
        [self.statusTextField setBroadcast:broadcast];
        
    } else {
        TGUser *user = self.dialog.user;
        [self.nameTextField setUser:user isEncrypted:NO];
        [self.statusTextField setUser:user];
    }
    
    
    [self sizeToFit];
}






- (void)buildForSize:(NSSize)size {

    [self.nameTextField sizeToFit];
    [self.nameTextField setFrame:NSMakeRect(10, self.bounds.size.height - self.nameTextField.bounds.size.height - 4, self.bounds.size.width - 20, self.nameTextField.bounds.size.height)];
    
    
    [self.typingTextField sizeToFit];
    
    [self.typingTextField setCenterByView:self];
    
    self.typingTextField.backgroundColor = NSColorFromRGB(0x000000);
    
    
    int totalSize = NSWidth(self.typingTextField.frame);
    
    
    [self.containerView setFrameSize:NSMakeSize(totalSize, self.typingTextField.frame.size.height)];
    
    [self.containerView setCenterByView:self];
    
    [self.containerView setFrameOrigin:NSMakePoint(self.containerView.frame.origin.x, 9)];
    
    
    
    


    

    [self.statusTextField setFrame:NSMakeRect(10, 9, self.bounds.size.width - 20, self.statusTextField.frame.size.height)];
    

}

- (void) TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [self.statusTextField sizeToFit];
    [self buildForSize:self.bounds.size];
}

- (void) TMNameTextFieldDidChanged:(TMNameTextField *)textField {
    [self buildForSize:self.bounds.size];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
//    NSLog(@"newSize %@", NSStringFromSize(newSize));
    [self buildForSize:newSize];
}



- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if(self.tapBlock)
        self.tapBlock();
}

@end
