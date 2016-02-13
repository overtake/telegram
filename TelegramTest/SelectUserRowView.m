//
//  SelectUserRowView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectUserRowView.h"
#import "SelectUserItem.h"
#import "TMAvatarImageView.h"
#import "TMCheckBox.h"
#import "SelectUsersTableView.h"


@interface SelectUserRowView ()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;

@property (nonatomic, strong) BTRButton *selectButton;

-(SelectUserItem *)rowItem;

@property (nonatomic,strong) TMView *animatedBackground;


@end

@implementation SelectUserRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _animatedBackground = [[TMView alloc] initWithFrame:self.bounds];
        _animatedBackground.backgroundColor = LIGHT_GRAY_BORDER_COLOR;
        [_animatedBackground setHidden:YES];
        [self addSubview:_animatedBackground];
        
        
        [self setSelectedBackgroundColor: NSColorFromRGB(0xfafafa)];
        [self setNormalBackgroundColor:NSColorFromRGB(0xffffff)];
        self.avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        
        [self addSubview:self.avatarImageView];
        
       

        _titleTextField = [[TMNameTextField alloc] init];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setBackgroundColor:[NSColor clearColor]];
        [self.titleTextField setFont:TGSystemMediumFont(12)];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        
        [_titleTextField setSelector:@selector(dialogTitle)];
        [self addSubview:self.titleTextField];
        
        _lastSeenTextField = [[TMStatusTextField alloc] init];
        [self.lastSeenTextField setEditable:NO];
        [self.lastSeenTextField setBordered:NO];
        [self.lastSeenTextField setBackgroundColor:[NSColor clearColor]];
        [self.lastSeenTextField setFont:TGSystemFont(12)];
        [[self.lastSeenTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.lastSeenTextField cell] setTruncatesLastVisibleLine:YES];
        [self.lastSeenTextField setSelector:@selector(statusForSearchTableView)];
        [self.lastSeenTextField setTextColor:GRAY_TEXT_COLOR];
        [self addSubview:self.lastSeenTextField];
        
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(20, roundf((50 - image_ComposeCheckActive().size.height )/ 2), image_ComposeCheckActive().size.width, image_ComposeCheckActive().size.height)];

        weak();
        
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateSelected];
        [self.selectButton addBlock:^(BTRControlEvents events) {
            [weakSelf mouseDown:[NSApp currentEvent]];
        } forControlEvents:BTRControlEventLeftClick];
        
        [self addSubview:self.selectButton];

    }
    return self;
}

- (void) redrawRow {
    
    [super redrawRow];
    
    if([self rowItem].user) {
        [self.titleTextField setUser:[self rowItem].user];
        [self.lastSeenTextField setUser:[self rowItem].user];
        [self.avatarImageView setUser:[self rowItem].user];
    } else {
        [self.titleTextField setChat:[self rowItem].chat];
        [self.lastSeenTextField setChat:[self rowItem].chat];
        [self.avatarImageView setChat:[self rowItem].chat];
    }
    
    if([self rowItem].isSearchUser) {
        [self.lastSeenTextField setUser:nil];
        [self.lastSeenTextField setStringValue:[NSString stringWithFormat:@"@%@",[self rowItem].user.username]];
    }
    
    [self setSelected:[[self rowItem] isSelected]];
    [self.selectButton setHidden:![self isEditable]];
    
    [self.titleTextField sizeToFit];
    
    [self.lastSeenTextField sizeToFit];
    
    [self.selectButton setFrameOrigin:[self selectOrigin]];
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(self.xOffset, 0)];
    [self.avatarImageView setCenteredYByView:self.avatarImageView.superview];
    
    [self.lastSeenTextField setFrameOrigin:NSMakePoint(self.xOffset + NSWidth(self.avatarImageView.frame) + 10, NSHeight(self.frame)/2 - NSHeight(self.titleTextField.frame) )];
    [self.titleTextField setFrameOrigin:NSMakePoint(self.xOffset + NSWidth(self.avatarImageView.frame) + 10, NSHeight(self.frame)/2 )];
  
    
    [self setNeedsDisplay:YES];
    
}

-(int)xOffset {
    return 12;
}

-(NSPoint)selectOrigin {
    return NSMakePoint(NSWidth(self.frame) - self.xOffset - NSWidth(self.selectButton.frame), NSMinY(self.selectButton.frame));
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.titleTextField setFrameSize:NSMakeSize(newSize.width - self.titleTextField.frame.origin.x - self.xOffset - NSWidth(self.selectButton.frame) - 5, self.titleTextField.frame.size.height)];
    
    [self.lastSeenTextField setFrameSize:NSMakeSize(newSize.width - self.lastSeenTextField.frame.origin.x - self.xOffset - NSWidth(self.selectButton.frame) - 5, self.lastSeenTextField.frame.size.height)];
    
    [_animatedBackground setFrameSize:newSize];
}


- (void)mouseDown:(NSEvent *)theEvent {
    if(((SelectUsersTableView *)[self rowItem].table).canSelectItem || [self rowItem].isSelected) {
        [self rowItem].isSelected = ![self rowItem].isSelected;
        if(!self.isEditable) {
            [super mouseDown:theEvent];
            return;
        }
        
        if([self rowItem].user.n_id != [UsersManager currentUserId]) {
            [self setSelected:[self rowItem].isSelected animation:YES];
            
            [((SelectUsersTableView *)[self rowItem].table).selectDelegate selectTableDidChangedItem:[self rowItem]];
        }
    }
    
}

- (BOOL)isEditable {
    return [(SelectUsersTableView *)[self rowItem].table selectLimit] > 0;
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    
    static float duration = 0.1f;
    
    weak();
    
    if((!self.visibleRect.size.width && !self.visibleRect.size.height) || !animation) {
        
        if(editable) {
            [self.selectButton.layer setOpacity:1];
            [self.selectButton setHidden:NO];
        } else {
            [self.selectButton setHidden:YES];
        }
        
        return;
    }
    
    int oldOpacity = self.selectButton.layer.opacity;
    
    [self.selectButton.layer setOpacity:editable ? 0 : 1];
    
    [self.selectButton setHidden:oldOpacity == 0 && !editable];
    
    
    POPBasicAnimation *position = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    position.toValue = @(editable ? 20 : 0);
    position.duration = duration;
    [position setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        [weakSelf.selectButton setFrameOrigin:[weakSelf selectOrigin]];
    }];
    
    
    [self.selectButton.layer pop_addAnimation:position forKey:@"slide"];
    
    POPBasicAnimation *opacityAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacityAnim.fromValue = @(editable ? 0 : 1);
    opacityAnim.toValue = @(editable ? 1 : 0);
    opacityAnim.duration = duration;
    [opacityAnim setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        if(result) {
            [weakSelf.selectButton setHidden:!editable];
        }
    }];
    [self.selectButton.layer pop_addAnimation:opacityAnim forKey:@"opacity"];
    
}

- (void)needUpdateSelectType {
    [self setEditable:[self isEditable] animation:NO];
    [self setSelected:[self rowItem].isSelected animation:NO];
}

- (void)setSelected:(BOOL)isSelected {
    [self setSelected:isSelected animation:NO];
}

-(void)checkSelected:(BOOL)isSelected {

}

- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
    weak();
    
    [self.selectButton setSelected:isSelected];
    
    if(self.selectButton.layer.anchorPoint.x != 0.5) {
        CGPoint point = self.selectButton.layer.position;
        
        point.x += roundf(image_ComposeCheckActive().size.width / 2);
        point.y += roundf(image_ComposeCheckActive().size.height / 2);
        
        self.selectButton.layer.position = point;
        self.selectButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    if(self.selectButton.isSelected) {
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateHighlighted];
    } else {
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
    }
    
    if(animation) {
        
        [self.animatedBackground setHidden:NO];
        
        [self.animatedBackground setAlphaValue:0];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [context setDuration:0.1];
            [[_animatedBackground animator] setAlphaValue:1.0];
            
        } completionHandler:^{
            
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                
                [[_animatedBackground animator] setAlphaValue:0];
                
            } completionHandler:^{
                [[_animatedBackground animator] setAlphaValue:0];
                [_animatedBackground setHidden:YES];
            }];
            
        }];
        
        float duration = 0.2;
        float to = 0.9;
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
        scaleAnimation.duration = duration / 2;
        [scaleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL result) {
            if(result) {
                POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
                scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
                scaleAnimation.duration = duration / 2;
                [weakSelf.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
            }
        }];
        
        [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
        
    }
}

-(SelectUserItem *)rowItem {
    return (SelectUserItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    [DIALOG_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(NSMinX(self.titleTextField.frame), 0, NSWidth(self.frame) -  NSMinX(self.titleTextField.frame), 1));

}



@end
