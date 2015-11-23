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


@end

@implementation SelectUserRowView
static int offsetEditable = 30;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        
        [self.titleTextField setSelector:@selector(chatInfoTitle)];
        [self addSubview:self.titleTextField];
        
        
        
        _lastSeenTextField = [[TMStatusTextField alloc] init];
        [self.lastSeenTextField setEditable:NO];
        [self.lastSeenTextField setBordered:NO];
        [self.lastSeenTextField setBackgroundColor:[NSColor clearColor]];
        [self.lastSeenTextField setFont:TGSystemFont(12)];
        [[self.lastSeenTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.lastSeenTextField cell] setTruncatesLastVisibleLine:YES];
        [self.lastSeenTextField setSelector:@selector(statusForGroupInfo)];
        [self.lastSeenTextField setTextColor:GRAY_TEXT_COLOR];
        [self addSubview:self.lastSeenTextField];
        
        
        
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
    
    [self.titleTextField setUser:[self rowItem].user];
    
   // [self.titleTextField setAttributedStringValue:[self rowItem].title];
    
    [self.lastSeenTextField setUser:[self rowItem].user];
    
    if([self rowItem].isSearchUser) {
        [self.lastSeenTextField setUser:nil];
        [self.lastSeenTextField setStringValue:[NSString stringWithFormat:@"@%@",[self rowItem].user.username]];
    }

    
    [self setSelected:[[self rowItem] isSelected]];
    [self.selectButton setHidden:![self isEditable]];
    
    [self.titleTextField sizeToFit];
    
    [self.lastSeenTextField sizeToFit];
    
   
    
  //  [self.titleTextField setFrameSize:[self rowItem].titleSize];
    //[self.lastSeenTextField setFrameSize:[self rowItem].lastSeenSize];
    
    [self.selectButton setFrameOrigin:[self selectOrigin]];
    
    
    [self.titleTextField setFrameOrigin:self.isEditable ? [self rowItem].titlePoint : [self rowItem].noSelectTitlePoint];
    [self.lastSeenTextField setFrameOrigin:self.isEditable ? [self rowItem].lastSeenPoint : [self rowItem].noSelectLastSeenPoint];
        
    [self.avatarImageView setFrameOrigin:self.isEditable ? [self rowItem].avatarPoint : [self rowItem].noSelectAvatarPoint];
    
    
    [self.avatarImageView setUser:[self rowItem].user];
    [self setNeedsDisplay:YES];
    
}

-(NSPoint)selectOrigin {
    return NSMakePoint([self isEditable] ? 20 : 0, NSMinY(self.selectButton.frame));
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.titleTextField setFrameSize:NSMakeSize(newSize.width - self.titleTextField.frame.origin.x - 14, self.titleTextField.frame.size.height)];
    
     [self.lastSeenTextField setFrameSize:NSMakeSize(newSize.width - self.lastSeenTextField.frame.origin.x - 14, self.lastSeenTextField.frame.size.height)];
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

- (void)needUpdateSelectType {
    [self setEditable:[self isEditable] animation:NO];
    [self setSelected:[self rowItem].isSelected animation:NO];
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

-(SelectUserItem *)rowItem {
    return (SelectUserItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    NSPoint point = self.isEditable ? [self rowItem].titlePoint : [self rowItem].noSelectTitlePoint;
	
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(point.x+2, 0, NSWidth(self.frame) - point.x - 10, 1));
//    
//    [NSColorFromRGB(arc4random() % 16000000) setFill];
//    
//    NSRectFill(self.frame);
}



@end
