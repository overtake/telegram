//
//  PrivacyUserListItemView.m
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacyUserListItemView.h"
#import "PrivacyUserListController.h"
@interface PrivacyUserListItemView ()


@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) TMTextField *titleTextField;
@property (nonatomic, strong) TMTextField *numberTextField;
@property (nonatomic, strong) TMTextButton *removeButton;

-(PrivacyUserListItem *)rowItem;


@end

@implementation PrivacyUserListItemView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImageView = [TMAvatarImageView standartNewConversationTableAvatar];
        [self addSubview:self.avatarImageView];
        [self.avatarImageView setFont:TGSystemLightFont(15)];
        [self.avatarImageView setFrameSize:NSMakeSize(36, 36)];
        
        
        self.titleTextField = [[TMTextField alloc] init];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setBackgroundColor:[NSColor clearColor]];
        [self.titleTextField setFont:TGSystemFont(13)];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.titleTextField];
        
        [self.titleTextField setFrameOrigin:NSMakePoint(145, 27)];
        
        
        self.numberTextField = [[TMTextField alloc] init];
        [self.numberTextField setEditable:NO];
        [self.numberTextField setBordered:NO];
        [self.numberTextField setBackgroundColor:[NSColor clearColor]];
        [self.numberTextField setFont:TGSystemFont(12)];
        [self.numberTextField setTextColor:GRAY_TEXT_COLOR];
        [[self.numberTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.numberTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.numberTextField];
        
        [self.numberTextField setFrameOrigin:NSMakePoint(145, 10)];
        
        
        
        [self.avatarImageView setFrameOrigin:NSMakePoint(100, 7)];
        
        self.removeButton = [TMTextButton standartUserProfileButtonWithTitle:NSLocalizedString(@"Remove", nil)];
        
        [self.removeButton setFont:TGSystemFont(14)];
        [self.removeButton setTextColor:BLUE_UI_COLOR];
        
        [self.removeButton sizeToFit];
        
        weak();
        
        [self.removeButton setTapBlock:^ {
            
            [[weakSelf rowItem].controller _didRemoveItem:[weakSelf rowItem]];
            
        }];
        
        
        [self addSubview:self.removeButton];
        
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
    
    [self.removeButton setFrameOrigin:NSMakePoint( NSWidth(self.frame) - NSWidth(self.removeButton.frame) - 113, 18)];
}


-(BlockedUserRowItem *)rowItem {
    return (BlockedUserRowItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(145, 0, NSWidth(self.frame) - 245, 1));
    
}


@end
