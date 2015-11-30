//
//  BlockedUsersRowView.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BlockedUserRowView.h"

@interface BlockedUserRowView ()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) TMTextField *titleTextField;
@property (nonatomic, strong) TMTextField *numberTextField;
@property (nonatomic, strong) TMTextButton *unblockButton;

-(BlockedUserRowItem *)rowItem;


@end

@implementation BlockedUserRowView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        [self addSubview:self.avatarImageView];

        
        self.titleTextField = [[TMTextField alloc] init];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setBackgroundColor:[NSColor clearColor]];
        [self.titleTextField setFont:TGSystemFont(13)];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.titleTextField];
        
        [self.titleTextField setFrameOrigin:NSMakePoint(80, 27)];
        
        
        self.numberTextField = [[TMTextField alloc] init];
        [self.numberTextField setEditable:NO];
        [self.numberTextField setBordered:NO];
        [self.numberTextField setBackgroundColor:[NSColor clearColor]];
        [self.numberTextField setFont:TGSystemFont(12)];
        [self.numberTextField setTextColor:GRAY_TEXT_COLOR];
        [[self.numberTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.numberTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.numberTextField];
        
        [self.numberTextField setFrameOrigin:NSMakePoint(80, 10)];
        
        
        
        [self.avatarImageView setFrameOrigin:NSMakePoint(30, 7)];
        
        self.unblockButton = [TMTextButton standartUserProfileButtonWithTitle:NSLocalizedString(@"User.Unlock", nil)];
        
        [self.unblockButton setFont:TGSystemFont(14)];
        [self.unblockButton setTextColor:BLUE_UI_COLOR];
        
        [self.unblockButton sizeToFit];
       
        weak();
        
        [self.unblockButton setTapBlock:^ {
           
            [[BlockedUsersManager sharedManager] unblock:[weakSelf rowItem].contact.user_id completeHandler:nil];
            
        }];
        
        
        [self addSubview:self.unblockButton];
        
    }
    return self;
}

- (void) redrawRow {
    
    [super redrawRow];
    
    
    [self.titleTextField setStringValue:[self rowItem].user.fullName];
    
    [self.titleTextField sizeToFit];
    
    [self.numberTextField setStringValue:[self rowItem].user.phoneWithFormat];
    
    [self.numberTextField sizeToFit];
    
    [self.avatarImageView setUser:[self rowItem].user];
    [self setNeedsDisplay:YES];
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.unblockButton setFrameOrigin:NSMakePoint( NSWidth(self.frame) - NSWidth(self.unblockButton.frame) - 30, 18)];
    
    [self.titleTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSWidth(self.unblockButton.frame) - 110, NSHeight(_titleTextField.frame))];
    [self.numberTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSWidth(self.unblockButton.frame) - 110, NSHeight(_numberTextField.frame))];
}


-(BlockedUserRowItem *)rowItem {
    return (BlockedUserRowItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(80, 0, NSWidth(self.frame) - 110, 1));

}


@end
