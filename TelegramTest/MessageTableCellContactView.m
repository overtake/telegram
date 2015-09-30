//
//  MessageTableCellContactView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellContactView.h"
#import "TMAvatarImageView.h"
#import "TMBlueAddButtonView.h"
@interface MessageTableCellContactView()

@property (nonatomic, strong) TMAvatarImageView *contactImageView;
@property (nonatomic, strong) TMTextButton *titleTextButton;
@property (nonatomic, strong) NSTextView *phoneNumberTextView;
@property (nonatomic, strong) TMBlueAddButtonView *addButton;
@end

@implementation MessageTableCellContactView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        dispatch_block_t block = ^{
            MessageTableItemContact *contactItem = (MessageTableItemContact *)weakSelf.item;
            [TMInAppLinks parseUrlAndDo:[TMInAppLinks userProfile:contactItem.user_id]];
        };
        
        self.contactImageView = [TMAvatarImageView standartMessageTableAvatar];
        [self.contactImageView setFrameOrigin:NSMakePoint(0, 0)];
        [self.contactImageView setTapBlock:block];
        [self.containerView addSubview:self.contactImageView];
        
        self.titleTextButton = [[TMTextButton alloc] init];
        [[self.titleTextButton cell] setTruncatesLastVisibleLine:YES];
        [[self.titleTextButton cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleTextButton setFont:TGSystemFont(12)];
        [self.titleTextButton setTextColor:LINK_COLOR];
        [self.titleTextButton setTapBlock:block];
        [self.titleTextButton setFrameOrigin:NSMakePoint(self.contactImageView.bounds.size.width + 10, 20)];
        [self.containerView addSubview:self.titleTextButton];
        
        self.phoneNumberTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        [self.phoneNumberTextView setDrawsBackground:NO];
        [self.phoneNumberTextView setEditable:NO];
        [self.phoneNumberTextView setFrameOrigin:NSMakePoint(self.contactImageView.bounds.size.width + 8, -3)];
        [self.phoneNumberTextView setFont:TGSystemFont(12)];
        [self.containerView addSubview:self.phoneNumberTextView];
        
        self.addButton = [[TMBlueAddButtonView alloc] initWithFrame:NSMakeRect(0, 0, 60, 25)];
    }
    return self;
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    [TMInAppLinks parseUrlAndDo:url];
}

- (void)setItem:(MessageTableItemContact *)item {
    [super setItem:item];
    
    self.titleTextButton.stringValue = item.contactName;
    [self.titleTextButton setFrameSize:item.contactNameSize];
    
    NSPoint point = self.phoneNumberTextView.frame.origin;


    [self.phoneNumberTextView setString:item.contactNumberString];
    [self.phoneNumberTextView setFrameSize:item.contactNumberSize];
    [self.phoneNumberTextView setNeedsDisplay:YES];
    
    [self.phoneNumberTextView setFrameOrigin:point];
    
    
    
    if(item.contactUser) {
        [self.contactImageView setUser:item.contactUser];
    } else {
        [self.contactImageView setText:item.contactText];
    }
    
    [self.titleTextButton setTextColor:item.contactUser ? LINK_COLOR : NSColorFromRGB(0x222222)];
    [self.titleTextButton setDisable:!item.contactUser];
    
    [self.addButton setHidden:item.contactUser.type != TLUserTypeForeign && item.contactUser.type != TLUserTypeRequest];
    
    if(item.contactUser.type == TLUserTypeForeign || item.contactUser.type == TLUserTypeRequest) {
        
        self.addButton.phoneNumber = item.contactNumberString;
        self.addButton.contact = item.contactUser;
        
        if(!self.addButton.superview) {
            [self.addButton setString:NSLocalizedString(@"Messages.AddContact", nil)];
            [self.containerView addSubview:self.addButton];
            [self.addButton setFrameOrigin:NSMakePoint(MAX(NSMaxX(self.phoneNumberTextView.frame),NSMaxX(_titleTextButton.frame)) + 0, 4)];
        }
    }
    
}


@end
