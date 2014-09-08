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
@property (nonatomic, strong) TMTextField *titleTextField;
@property (nonatomic,strong) TMTextField *lastSeenTextField;
@property (nonatomic, strong) BTRButton *selectButton;

-(SelectUserItem *)rowItem;


@end

@implementation SelectUserRowView
static int offsetEditable = 30;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSelectedBackgroundColor: NSColorFromRGB(0xfafafa)];
        [self setNormalBackgroundColor:NSColorFromRGB(0xffffff)];
        self.avatarImageView = [TMAvatarImageView standartNewConversationTableAvatar];
        [self addSubview:self.avatarImageView];
        [self.avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:16]];
        [self.avatarImageView setFrameSize:NSMakeSize(36, 36)];
        
        
        self.titleTextField = [[TMTextField alloc] init];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setBackgroundColor:[NSColor clearColor]];
        [self.titleTextField setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12]];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.titleTextField];
        
        [self.titleTextField setAutoresizingMask:NSViewWidthSizable];
        
        self.lastSeenTextField = [[TMTextField alloc] init];
        [self.lastSeenTextField setEditable:NO];
        [self.lastSeenTextField setBordered:NO];
        [self.lastSeenTextField setBackgroundColor:[NSColor clearColor]];
        [self.lastSeenTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [[self.lastSeenTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.lastSeenTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.lastSeenTextField];
        
        
        
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(20, roundf((50 - composeCheckActiveImage().size.height )/ 2), composeCheckActiveImage().size.width, composeCheckActiveImage().size.height)];
       // [self.selectButton setAutoresizingMask:NSViewMinXMargin];
        [self.selectButton setHidden:NO];
        
        weakify();
        
        [self.selectButton setBackgroundImage:composeCheckImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:composeCheckImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:composeCheckImage() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:composeCheckActiveImage() forControlState:BTRControlStateSelected];
        self.selectButton.layer.opacity = 0;
        [self.selectButton addBlock:^(BTRControlEvents events) {
            [strongSelf mouseDown:[NSApp currentEvent]];
        } forControlEvents:BTRControlEventLeftClick];
        [self addSubview:self.selectButton];

        
        
    }
    return self;
}

- (void) redrawRow {
    
    [super redrawRow];
    
    
    
    [self.titleTextField setAttributedStringValue:[self rowItem].title];
    [self.lastSeenTextField setAttributedStringValue:[self rowItem].lastSeen];
    
    if([self rowItem].titleSize.width == 0) {
        [self.titleTextField sizeToFit];
        NSSize size = self.titleTextField.frame.size;
        
        int maxTitleSize = self.frame.size.width - 69;
        if(size.width > maxTitleSize)
            size.width = maxTitleSize;
        
        [self rowItem].titleSize = size;
    }
    
    
    [self setEditable:[self isEditable] animation:NO];
    [self setSelected:[self rowItem].isSelected animation:NO];
    
    
    
    [self.titleTextField setFrameSize:[self rowItem].titleSize];
    [self.lastSeenTextField setFrameSize:[self rowItem].lastSeenSize];
    
    
    [self.titleTextField  setFrameOrigin:self.isEditable ? [self rowItem].titlePoint : [self rowItem].noSelectTitlePoint];
    [self.lastSeenTextField setFrameOrigin:self.isEditable ? [self rowItem].lastSeenPoint : [self rowItem].noSelectLastSeenPoint];
        
    [self.avatarImageView setFrameOrigin:self.isEditable ? [self rowItem].avatarPoint : [self rowItem].noSelectAvatarPoint];
    
    
    [self.avatarImageView setUser:[self rowItem].contact.user];
    [self setNeedsDisplay:YES];
    
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
    return [[self rowItem].table selectLimit] > 0;
}

- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    
    animation = NO;
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
    
    
    float from = self.selectButton.layer.frame.origin.x;
    float to = self.selectButton.layer.frame.origin.x + (editable ? -offsetEditable : offsetEditable);
    
    
    int oldOpacity = self.selectButton.layer.opacity;
    
    [self.selectButton.layer setOpacity:editable ? 0 : 1];
    
    [self.selectButton setHidden:oldOpacity == 0 && !editable];
    
    
    POPBasicAnimation *position = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    position.fromValue = @(from);
    position.toValue = @(to);
    position.duration = duration;
    [position setCompletionBlock:^(POPAnimation *anim, BOOL result) {
       
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
    [self.selectButton.layer pop_addAnimation:opacityAnim forKey:@"slide"];
    
}

- (void)needUpdateSelectType {
    [self setEditable:[self isEditable] animation:YES];
    [self setSelected:[self rowItem].isSelected animation:YES];
}

- (void)setSelected:(BOOL)isSelected {
    [self setSelected:isSelected animation:NO];
}

NSImage *composeCheckImage() {
    return [NSImage imageNamed:@"ComposeCheck"];
}

NSImage *composeCheckActiveImage() {
    return [NSImage imageNamed:@"ComposeCheckActive"];
}

- (void)setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
    
    [self.selectButton setSelected:isSelected];
    
    if(self.selectButton.layer.anchorPoint.x != 0.5) {
        CGPoint point = self.selectButton.layer.position;
        
        point.x += roundf(composeCheckActiveImage().size.width / 2);
        point.y += roundf(composeCheckActiveImage().size.height / 2);
        
        self.selectButton.layer.position = point;
        self.selectButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    if(self.selectButton.isSelected) {
        [self.selectButton setBackgroundImage:composeCheckActiveImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:composeCheckActiveImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:composeCheckActiveImage() forControlState:BTRControlStateHighlighted];
    } else {
        [self.selectButton setBackgroundImage:composeCheckImage() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:composeCheckImage() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:composeCheckImage() forControlState:BTRControlStateHighlighted];
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

-(SelectUserItem *)rowItem {
    return (SelectUserItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    NSPoint point = self.isEditable ? [self rowItem].titlePoint : [self rowItem].noSelectTitlePoint;
	
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(point.x+2, 0, NSWidth(self.frame) - point.x - [self rowItem].rightBorderMargin, 1));
//    
//    [NSColorFromRGB(arc4random() % 16000000) setFill];
//    
//    NSRectFill(self.frame);
}



@end
