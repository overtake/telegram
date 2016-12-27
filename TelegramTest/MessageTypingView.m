//
//  MessageTypingView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTypingView.h"
#import "NSAttributedString+Hyperlink.h"
#import "TMAttributedString.h"
#import "TGAnimationBlockDelegate.h"
#import "TGTimerTarget.h"
#import "TGModernTypingManager.h"
#import "TGModernConversationTitleActivityIndicator.h"
@interface MessageTypingView() {
    NSArray *_typingDots;
    NSTimer *_typingDotTimer;
    int _typingDotState;
    bool _typingAnimation;
    bool _animationsAreSuspended;
}

@property (nonatomic, strong) TL_conversation *currentDialog;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) TMTextField *textField;
@property (nonatomic, strong) BTRImageView *imageView;


@property (nonatomic,strong) TMView *typingView;

@property (nonatomic) int endString;
@property (nonatomic) int haveDots;
@property (nonatomic) int needDots;

@property (nonatomic,strong) TGModernConversationTitleActivityIndicator *activity;
@end


@implementation MessageTypingView

const NSTimeInterval typingIntervalFirst = 0.16;
const NSTimeInterval typingIntervalSecond = 0.14;


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.typingView = [[TMView alloc] initWithFrame:NSMakeRect(20+3, 10, 30, 16)];
        
        self.typingView.wantsLayer = YES;
        
        [self addSubview:self.typingView];
        
        self.attributedString = [[NSMutableAttributedString alloc] init];
        self.textField = [[TMTextField alloc] initWithFrame:NSMakeRect(20+36+8, 10, 0,20)];
        [self.textField setBordered:NO];
        [self.textField setEditable:NO];
        [self.textField setEnabled:NO];
        [self.textField setSelectable:NO];
        
        [[self.textField cell] setTruncatesLastVisibleLine:YES];

        [self addSubview:self.textField];
        
        self.backgroundColor = NSColorFromRGBWithAlpha(0xffffff,0.5);
        
        _activity = [[TGModernConversationTitleActivityIndicator alloc] initWithFrame:NSMakeRect(20+3, 10, 30, 20)];
        [self addSubview:_activity];
        
    }
    return self;
}

- (void) setDialog:(TL_conversation *) dialog {
    self.currentDialog = dialog;
    [Notification removeObserver:self];
    [Notification addObserver:self selector:@selector(typingRedrawNotification:) name:[Notification notificationNameByDialog:dialog action:@"typing"]];
    
    [TGModernTypingManager asyncTypingWithConversation:dialog handler:^(TMTypingObject *typing) {
        
        [self redrawByArray:[typing currentActions] animated:NO];
        
    }];
    
}

- (void) typingRedrawNotification:(NSNotification *)notification {
    NSArray *users = (NSArray *)([notification.userInfo objectForKey:@"users"]);
    
    [self redrawByArray:users animated:YES];
}

- (void) redrawByArray:(NSArray *)actions animated:(BOOL)animated {
    [[self.attributedString mutableString] setString:@""];
    
    NSString *string = nil;
    
    [_activity setNone];
    
    if(actions.count) {

        if(actions.count == 1) {
            
            TGActionTyping *action = actions[0];
            
            if([action.action isKindOfClass:[TL_sendMessageRecordAudioAction class]])
                [_activity setAudioRecording];
            else if([action.action isKindOfClass:[TL_sendMessageUploadPhotoAction class]] || [action.action isKindOfClass:[TL_sendMessageUploadVideoAction class]] || [action.action isKindOfClass:[TL_sendMessageUploadDocumentAction class]])
                [_activity setUploading];
            else
                [_activity setTyping];
            
            TLUser *user = action.user;
            if(user)
                string =[NSString stringWithFormat:NSLocalizedString(NSStringFromClass(action.action.class), nil),user.fullName];
        } else {
            
            [_activity setTyping];
            
            NSMutableArray *usersStrings = [[NSMutableArray alloc] init];
            for(TGActionTyping *action in actions) {
                TLUser *user = action.user;
                if(user) {
                    [usersStrings addObject:user.fullName];
                }
            }
            
            string = [NSString stringWithFormat:NSLocalizedString(@"Typing.AreTyping", nil), [usersStrings componentsJoinedByString:@", "]];
            
        }
        
        [self.attributedString appendString:string withColor:GRAY_TEXT_COLOR];
    } else {
        [_activity setNone];
        
        self.needDots = 0;
    }
    
    if(animated && self.textField.attributedStringValue.length == 0 && string.length > 0) {
        [self.textField setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), -20)];
    }
    
    [self.textField setFont:[SettingsArchiver font12]];
    self.textField.attributedStringValue = self.attributedString;
    self.endString = (int) self.attributedString.length;
    [self.textField sizeToFit];
    
    
    id typingF = animated ? [_activity animator] : _activity;
    
    
    [typingF setFrameOrigin:NSMakePoint(NSMinX(_typingView.frame), string.length > 0 ? 10 : - 20)];
    
    id fieldF = animated ? [self.textField animator] : self.textField;
    
    [fieldF setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), string.length > 0 ? 10 : - 20)];
    
    int maxWidth = NSWidth(self.frame)-NSMinX(self.textField.frame) - 20;
    
    [self.textField setFrameSize:NSMakeSize(maxWidth, NSHeight(self.textField.frame))];
    
    self.haveDots = 0;
}

-(void)layout {
    [super layout];
    [self.textField setFrameOrigin:NSMakePoint(20+36+8, 10)];
}


-(BOOL)isActive {
    return self.textField.attributedStringValue.length != 0;
}

@end
