//
//  NewConversationRowView.m
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NewConversationRowView.h"
#import "TMAvatarImageView.h"
#import "NewConversationRowItem.h"
#import "TMCheckBox.h"
@interface NewConversationRowView ()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) TMTextField *titleTextField;
@property (nonatomic,strong) TMTextField *lastSeenTextField;
@property (nonatomic,strong) TMCheckBox *checkBox;

-(NewConversationRowItem *)rowItem;
@end

@implementation NewConversationRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSelectedBackgroundColor:NSColorFromRGB(0x6896ba)];
        self.checkBox = [[TMCheckBox alloc] initWithFrame:NSMakeRect(10, 60/2-10, 20, 20)];
        [self addSubview:self.checkBox];
        
        self.avatarImageView = [TMAvatarImageView standartNewConversationTableAvatar];
        [self addSubview:self.avatarImageView];
        
        
        self.titleTextField = [[TMTextField alloc] init];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setBackgroundColor:[NSColor clearColor]];
        [self.titleTextField setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12]];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.titleTextField];
        
        self.lastSeenTextField = [[TMTextField alloc] init];
        [self.lastSeenTextField setEditable:NO];
        [self.lastSeenTextField setBordered:NO];
        [self.lastSeenTextField setBackgroundColor:[NSColor clearColor]];
        [self.lastSeenTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [[self.lastSeenTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.lastSeenTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.lastSeenTextField];
        
        
        [self setNormalBackgroundColor:NSColorFromRGB(0xffffff)];
    }
    return self;
}

- (void) redrawRow {
    [self setSelected:[self rowItem].isChecked animation:NO];
    
    [super redrawRow];
    
   
    [self.checkBox setSelected:[self rowItem].isChecked];
    [self.checkBox setChecked:[self rowItem].isChecked];
    
    float duration = [[self rowItem] animated] ? 0.0 : 0.0f;
  
    [self.checkBox setHidden:!([self rowItem].action == NewConversationActionCreateGroup || [self rowItem].action == NewConversationActionChoosePeople)];
    
 
    [self.titleTextField setFrameOrigin:[self rowItem].titlePoint];
    [self.lastSeenTextField setFrameOrigin:[self rowItem].lastSeenPoint];
    
    
    
    [self.avatarImageView setFrameOrigin:[self rowItem].avatarPoint];
    
    
    [self rowItem].avatarPoint = NSMakePoint(([self rowItem].action == NewConversationActionWrite || [self rowItem].action == NewConversationActionCreateSecretChat) ? 10 : 40, self.avatarImageView.frame.origin.y);
    
    [self rowItem].titlePoint = NSMakePoint(([self rowItem].action == NewConversationActionWrite || [self rowItem].action == NewConversationActionCreateSecretChat) ? 67 : 97, 31);
    
    
    [self rowItem].lastSeenPoint = NSMakePoint(([self rowItem].action == NewConversationActionWrite || [self rowItem].action == NewConversationActionCreateSecretChat) ? 67 : 97, 2);
    
    
    
    [self.titleTextField setAttributedStringValue:[self rowItem].title];
    [self.lastSeenTextField setAttributedStringValue:[self rowItem].lastSeen];
    
    if([self rowItem].titleSize.width == 0) {
        [self.titleTextField sizeToFit];
        NSSize size = self.titleTextField.frame.size;
        
        int maxTitleSize = 200 ;
        if(size.width > maxTitleSize)
            size.width = maxTitleSize;
        
        [self rowItem].titleSize = size;
    }

    
    [self.titleTextField setFrameSize:[self rowItem].titleSize];
    [self.lastSeenTextField setFrameSize:[self rowItem].lastSeenSize];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:duration];
        
        [[self.titleTextField animator] setFrameOrigin:[self rowItem].titlePoint];
        [[self.lastSeenTextField animator] setFrameOrigin:[self rowItem].lastSeenPoint];
        
        [[self.avatarImageView animator] setFrameOrigin:[self rowItem].avatarPoint];
        
    } completionHandler:^{
        
    }];
    
    
    
 
    [self.avatarImageView setUser:[self rowItem].user];
    [self setNeedsDisplay:YES];
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    if( ([self rowItem].action == NewConversationActionCreateGroup || [self rowItem].action == NewConversationActionChoosePeople) && [[self rowItem] canSelect]) {
        
        [self rowItem].isChecked = ![self rowItem].isChecked;
        
        [[self rowItem].title setSelected:[self rowItem].isChecked];
        [[self rowItem].lastSeen setSelected:[self rowItem].isChecked];
        [self.titleTextField setAttributedStringValue:[self rowItem].title];
        [self.lastSeenTextField setAttributedStringValue:[self rowItem].lastSeen];
        [self.checkBox setSelected:[self rowItem].isChecked];
        [self.checkBox setChecked:[self rowItem].isChecked];
        
        [self setSelected:[self rowItem].isChecked animation:NO];
        TMTableView *table = [[self rowItem] table];
        if([table.tm_delegate respondsToSelector:@selector(selectionDidChange:item:)]) {
            [table.tm_delegate selectionDidChange:0 item:[self rowItem]];
        }
        
    }
    
    [super mouseDown:theEvent];
}

- (void) setSelected:(BOOL)isSelected animation:(BOOL)animation {
    
    if(self.isSelected == isSelected)
        return;
    
    self.isSelected = isSelected;
    NSColor *color = isSelected ? self.selectedBackgroundColor : self.normalBackgroundColor;
    [self setBackgroundColor:color];
    [self setNeedsDisplay:YES];
    /*  if(animation) {
     
        NSColor *oldColor = !isSelected ? self.selectedBackgroundColor : self.normalBackgroundColor;
        
        [self.layer setBackgroundColor:color.CGColorNew];
        
        [self.layer removeAnimationForKey:@"selectionAnimation"];
        
        CABasicAnimation *selectionAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        selectionAnimation.duration = 0.1f;
        selectionAnimation.fromValue = oldColor;
        selectionAnimation.toValue = color;
        [self.layer addAnimation:selectionAnimation forKey:@"selectionAnimation"];
    } else {
        NSColor *color = isSelected ? self.selectedBackgroundColor : self.normalBackgroundColor;
        [self.layer setBackgroundColor:color.CGColorNew];
    } */
}

- (void)checkSelected:(BOOL)isSelected {
  //  if([self rowItem].action != NewConversationActionCreateGroup) {
        [[self rowItem].title setSelected:isSelected];
        [[self rowItem].lastSeen setSelected:isSelected];
        //[self.checkBox setSelected:isSelected];
       // if(isSelected) {
         //   [self.checkBox setChecked:![self rowItem].isChecked];
           // [self rowItem].isChecked = self.checkBox.isChecked;
       // }
   // }
}


-(NewConversationRowItem *)rowItem {
    return (NewConversationRowItem *) [super rowItem];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}



@end
