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
#import "TGCTextView.h"
@interface MessageTableCellContactView()

@property (nonatomic, strong) TMAvatarImageView *photoView;
@property (nonatomic, strong) TGCTextView *textView;
@end

@implementation MessageTableCellContactView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        dispatch_block_t block = ^{
            MessageTableItemContact *contactItem = (MessageTableItemContact *)weakSelf.item;
            if(contactItem.contactUser) {
                open_link([TMInAppLinks userProfile:contactItem.user_id]);
            }
        };
        
        self.photoView = [TMAvatarImageView standartTableAvatar];
        [self.photoView setFrameOrigin:NSMakePoint(0, 0)];
        [self.photoView setTapBlock:block];
        [self.containerView addSubview:self.photoView];
        
        self.textView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        [self.textView setLinkCallback:^(NSString *link) {
            
            MessageTableItemContact *item = (MessageTableItemContact *) weakSelf.item;
            
            if([link isEqualToString:@"chat://addcontact"]) {
                [weakSelf.messagesViewController showModalProgress];
                
                [[NewContactsManager sharedManager] importContact:[TL_inputPhoneContact createWithClient_id:rand_long() phone:item.message.media.phone_number first_name:item.message.media.first_name last_name:item.message.media.last_name] callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
                    
                    [item doAfterDownload];
                    
                    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                        
                        [[weakSelf.textView animator] setFrameSize:item.textSize];
                        [[weakSelf.textView animator] setFrameOrigin:NSMakePoint(NSMinX(weakSelf.textView.frame), roundf((item.blockSize.height - item.textSize.height)/2))];
                        
                    } completionHandler:^{
                        
                    }];
                    
                    [weakSelf.messagesViewController hideModalProgress];
                    
                }];
                
            } else {
                open_link(link);
            }
            
        }];
        
        [self.containerView addSubview:_textView];
        
    
    }
    return self;
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}

- (void)setItem:(MessageTableItemContact *)item {
    [super setItem:item];
    
    if(item.contactUser)
        [self.photoView setUser:item.contactUser];
     else
         [self.photoView setText:item.contactText];
    
    [self.textView setEditable:item.contactUser == nil];
    
    [_textView setAttributedString:item.attributedText];
    [_textView setFrame:NSMakeRect(NSMaxX(self.photoView.frame) + item.defaultOffset, 0, item.textSize.width, item.textSize.height)];
    [_textView setCenteredYByView:_textView.superview];
    
}

-(void)onStateChanged:(SenderItem *)item {
    
    if(item == self.item.messageSender) {
        if(item.state == MessageSendingStateSent) {
            MessageTableItemContact *contact =  (MessageTableItemContact *)self.item;
            
            [contact doAfterDownload];
            
            [self setItem:contact];
        }
    }
    
    [super onStateChanged:item];
    
}


-(void)clearSelection {
    [super clearSelection];
    [_textView setSelectionRange:NSMakeRange(NSNotFound, 0)];
}

-(BOOL)mouseInText:(NSEvent *)theEvent {
    return [_textView mouseInText:theEvent] || [super mouseInText:theEvent];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim)
        _textView.backgroundColor = color;
    else
        [_textView pop_addAnimation:anim forKey:@"background"];
}


@end
