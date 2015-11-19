//
//  SearchTableCell.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchTableCell.h"
#import "SearchItem.h"
#import "TMAvatarImageView.h"
@interface SearchTableCell()
@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) TMTextField *dateTextField;
- (SearchItem *)rowItem;
@end

@implementation SearchTableCell

- (SearchItem *)rowItem {
    return (SearchItem *)[super rowItem];
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        self.wantsLayer = YES;
        
    self.titleTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(68, 33, 200, 20)];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setSelectable:NO];
        [self.titleTextField setAutoresizingMask:NSViewWidthSizable];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleTextField setFont:TGSystemFont(14)];
        [self.titleTextField setDrawsBackground:NO];
//        [self.titleTextField setBackgroundColor:[NSColor redColor]];

        [self addSubview:self.titleTextField];
        
        self.statusTextField = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(68, 14, 200, 20)];
        [self.statusTextField setEditable:NO];
        [self.statusTextField setBordered:NO];
        [self.statusTextField setDrawsBackground:NO];
        [self.statusTextField setFont:TGSystemFont(13)];
        [self.statusTextField setSelector:@selector(statusForSearchTableView)];
        [self.statusTextField setAutoresizingMask:NSViewWidthSizable];
        [[self.statusTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.statusTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.statusTextField];

        
        self.dateTextField = [[TMTextField alloc] init];
        [self.dateTextField setEditable:NO];
        [self.dateTextField setBordered:NO];
        [self.dateTextField setAutoresizingMask:NSViewMinXMargin];
        [self.dateTextField setBackgroundColor:[NSColor clearColor]];
        [self.dateTextField setFont:TGSystemLightFont(12)];
        [self addSubview:self.dateTextField];
        
        self.avatarImageView = [TMAvatarImageView standartTableAvatar];
        [self addSubview:self.avatarImageView];

    }
    return self;
}

- (void) changeSelected:(BOOL)isSelected {

}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [TGConversationsViewController showPopupMenuForDialog:[self rowItem].conversation withEvent:theEvent forView:self];
}

- (void) checkSelected:(BOOL)isSelected {
    [self.titleTextField setSelected:isSelected];
    
   
    
    [self.statusTextField setSelected:isSelected];
    [[self rowItem].date setSelected:isSelected];
       
}

- (void)redrawRow {
    [super redrawRow];
    
    SearchItem *item = [self rowItem];
    
    
    if(item.conversation.type == DialogTypeChat || item.conversation.type == DialogTypeChannel) {
         [self.titleTextField setChat:item.chat];
    }
    
    if(item.conversation.type == DialogTypeUser) {
         [self.titleTextField setUser:item.user];
    }
    
    if(item.conversation.type == DialogTypeSecretChat) {
        [self.titleTextField setUser:item.user isEncrypted:YES];
    }
    
    if(item.conversation.type == DialogTypeBroadcast) {
        [self.titleTextField setBroadcast:item.conversation.broadcast];
    }
    
    
    
    
    [self.titleTextField sizeToFit];
    
    
    if(item.type != SearchItemMessage) {
        
        
      //  MTLog(@"%@",NSStringFromSelector(self.statusTextField.selector));
        
        if(item.chat) {
            [self.avatarImageView setChat:item.chat];
            [self.statusTextField setChat:item.chat];
        } else {
            [self.avatarImageView setUser:item.user];
            [self.statusTextField setUser:item.user];

            
        }
        
        if(item.type == SearchItemGlobalUser) {
            [self.statusTextField setUser:nil];
            [self.statusTextField setChat:nil];
            [self.statusTextField setAttributedStringValue:item.status];
        }
        
        [self.titleTextField sizeToFit];
        
        [self.titleTextField setFrameSize:NSMakeSize(MIN(self.bounds.size.width - 75,NSWidth(self.titleTextField.frame)), self.titleTextField.bounds.size.height)];

        
        [self.dateTextField setHidden:YES];
    } else {
        
        
        
        if(item.conversation.type == DialogTypeChat || item.conversation.type == DialogTypeChannel) {
            [self.avatarImageView setChat:item.chat];
        }
        
        if(item.conversation.type == DialogTypeUser || item.conversation.type == DialogTypeSecretChat) {
            [self.avatarImageView setUser:item.user];
        }
        
        if(item.conversation.type == DialogTypeBroadcast) {
            [self.avatarImageView setBroadcast:item.conversation.broadcast];
        }
        

        
        [self.statusTextField setUser:nil];
        [self.statusTextField setChat:nil];
        [self.statusTextField setAttributedStringValue:item.status];
        
        [self.dateTextField setHidden:NO];
        self.dateTextField.attributedStringValue = item.date;
        if(item.dateSize.width == 0) {
            [self.dateTextField sizeToFit];
            item.dateSize = self.dateTextField.frame.size;
        }
        
        [self.dateTextField setFrameSize:item.dateSize];
        
        [self.titleTextField setFrameSize:NSMakeSize(self.bounds.size.width - item.dateSize.width - 75, self.titleTextField.bounds.size.height)];
        
        [self.dateTextField setFrameOrigin:NSMakePoint(self.bounds.size.width - item.dateSize.width - 10, 34)];
    }
    
}

- (void)setHover:(BOOL)hover redraw:(BOOL)redraw {
    [super setHover:hover redraw:redraw];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.statusTextField setFrameSize:NSMakeSize(NSWidth(self.bounds) - 110, NSHeight(self.statusTextField.frame))];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    
    if(self.isSelected) {
        [BLUE_COLOR_SELECT set];
        NSRectFill(self.bounds);
    } else {
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(68, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH - 68, 1));
        
    }
    
    if([self rowItem].conversation.isVerified) {
        [self.isSelected ? image_VerifyWhite() : image_Verify() drawInRect:NSMakeRect(NSMaxX(self.titleTextField.frame),NSMinY(self.titleTextField.frame) , image_Verify().size.width, image_Verify().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
    }
    
}

@end
