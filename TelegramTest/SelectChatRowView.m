//
//  SelectUserRowView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectChatRowView.h"
#import "SelectChatItem.h"
#import "TMAvatarImageView.h"
#import "TMCheckBox.h"
#import "SelectUsersTableView.h"


@interface SelectChatRowView ()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;

@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;


@property (nonatomic, strong) BTRButton *selectButton;

-(SelectChatItem *)rowItem;


@end

@implementation SelectChatRowView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSelectedBackgroundColor: NSColorFromRGB(0xfafafa)];
        [self setNormalBackgroundColor:NSColorFromRGB(0xffffff)];
        _avatarImageView = [TMAvatarImageView standartMessageTableAvatar];
        [self addSubview:_avatarImageView];

        
        
        _titleTextField = [[TMNameTextField alloc] init];
        [_titleTextField setEditable:NO];
        [_titleTextField setBordered:NO];
        [_titleTextField setBackgroundColor:[NSColor clearColor]];
        [_titleTextField setFont:TGSystemMediumFont(12)];
        [[_titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_titleTextField cell] setTruncatesLastVisibleLine:YES];
        
        [_titleTextField setSelector:@selector(dialogTitle)];
        [self addSubview:_titleTextField];
        
        
        
        _statusTextField = [[TMStatusTextField alloc] init];
        [_statusTextField setEditable:NO];
        [_statusTextField setBordered:NO];
        [_statusTextField setBackgroundColor:[NSColor clearColor]];
        [_statusTextField setFont:TGSystemFont(12)];
        [[_statusTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_statusTextField cell] setTruncatesLastVisibleLine:YES];
        [_statusTextField setSelector:@selector(statusForSearchTableView)];
        
        [self addSubview:_statusTextField];
        
        
        
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(20, roundf((50 - image_ComposeCheckActive().size.height )/ 2), image_ComposeCheckActive().size.width, image_ComposeCheckActive().size.height)];
        // [self.selectButton setAutoresizingMask:NSViewMinXMargin];
        
        weakify();
        
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateSelected];
        [self.selectButton addBlock:^(BTRControlEvents events) {
            [strongSelf mouseDown:[NSApp currentEvent]];
        } forControlEvents:BTRControlEventLeftClick];
        
        
        [self addSubview:self.selectButton];
        
        
    }
    return self;
}

- (void) redrawRow {
    
    [super redrawRow];
    
    [_titleTextField setChat:[self rowItem].chat];
    
    
    [_statusTextField setChat:[self rowItem].chat];
    
    [self setSelected:[[self rowItem] isSelected]];
    [self.selectButton setHidden:![self isEditable]];
    
    [_titleTextField sizeToFit];
    
    [_statusTextField sizeToFit];
    
    
    const int editableOffset = 20;
    
    [self.titleTextField setFrameOrigin:NSMakePoint(self.isEditable ? 77 + editableOffset : 56,25)];
    [self.statusTextField setFrameOrigin:NSMakePoint(self.isEditable ? 77 + editableOffset : 56, 8)];
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(self.isEditable ? 30 + 20 : 10, (50 - 36) / 2)];


    
    
    [_avatarImageView setChat:[self rowItem].chat];
    [self setNeedsDisplay:YES];
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_titleTextField setFrameSize:NSMakeSize(newSize.width - _titleTextField.frame.origin.x - 14, _titleTextField.frame.size.height)];
    
    [_statusTextField setFrameSize:NSMakeSize(newSize.width - _statusTextField.frame.origin.x - 14, _statusTextField.frame.size.height)];
}



- (void)needUpdateSelectType {
    [self setEditable:[self isEditable] animation:NO];
    [self setSelected:[self rowItem].isSelected animation:NO];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(((SelectUsersTableView *)[self rowItem].table).canSelectItem || [self rowItem].isSelected) {
        [self rowItem].isSelected = ![self rowItem].isSelected;
        if(!self.isEditable) {
            [super mouseDown:theEvent];
            return;
        }
        
        [self setSelected:[self rowItem].isSelected animation:YES];
        
        [((SelectUsersTableView *)[self rowItem].table).selectDelegate selectTableDidChangedItem:[self rowItem]];
        
    }
    
}


- (BOOL)isEditable {
    return [(SelectUsersTableView *)[self rowItem].table selectLimit] > 0;
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    
    // animation = NO;
    static float duration = 0.1f;
    
    
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
        [self.selectButton setFrameOrigin:[self selectOrigin]];
    }];
    
    
    [self.selectButton.layer pop_addAnimation:position forKey:@"slide"];
    
    POPBasicAnimation *opacityAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacityAnim.fromValue = @(editable ? 0 : 1);
    opacityAnim.toValue = @(editable ? 1 : 0);
    opacityAnim.duration = duration;
    [opacityAnim setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        if(result) {
            [self.selectButton setHidden:!editable];
        }
    }];
    [self.selectButton.layer pop_addAnimation:opacityAnim forKey:@"opacity"];
    
}

-(NSPoint)selectOrigin {
    return NSMakePoint([self isEditable] ? 20 : 0, NSMinY(self.selectButton.frame));
}

- (void)setSelected:(BOOL)isSelected {
    [self setSelected:isSelected animation:NO];
}

-(void)checkSelected:(BOOL)isSelected {
    //   [self.lastSeenTextField setSelected:isSelected];
    //  [self.titleTextField setSelected:isSelected];
}


- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
    
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
        float duration = 1 / 18.f;
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
                [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
            }
        }];
        
        [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
        
        
    }
}


-(SelectChatItem *)rowItem {
    return (SelectChatItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(NSMinX(self.titleTextField.frame), 0, NSWidth(self.frame) - 60 , 1));

}



@end
