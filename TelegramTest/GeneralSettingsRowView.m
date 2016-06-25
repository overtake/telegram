//
//  GeneralSettingsRowView.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "GeneralSettingsRowView.h"
#import "ITSwitch.h"
#import "GeneralSettingsRowItem.h"
#import "NSMenuCategory.h"
#import "TGTextLabel.h"
#import "TGCirclularCounter.h"
@interface GeneralSettingsRowView ()
@property (nonatomic,strong) TGTextLabel *descriptionField;
@property (nonatomic,strong) TGTextLabel *nextDesc;
@property (nonatomic,strong) BTRButton *subdescField;

@property (nonatomic,strong) ITSwitch *switchControl;
@property (nonatomic,strong) NSImageView *nextImage;
@property (nonatomic,strong) NSImageView *selectedImageView;
@property (nonatomic,strong) NSProgressIndicator *lockedIndicator;

@property (nonatomic,strong) TGCirclularCounter *badgeCounter;
@end

@implementation GeneralSettingsRowView



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _descriptionField = [[TGTextLabel alloc] init];
        _subdescField = [[BTRButton alloc] init];
        _nextDesc = [[TGTextLabel alloc] init];
        
        _badgeCounter = [[TGCirclularCounter alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        [_badgeCounter setTextFont:TGSystemFont(12)];
        
        _badgeCounter.animated = NO;
        [self addSubview:_badgeCounter];
        
        [_subdescField setTitleFont:TGSystemFont(14) forControlState:BTRControlStateNormal];
        [_subdescField setTitleColor:GRAY_TEXT_COLOR forControlState:BTRControlStateNormal];
        
        self.lockedIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        [self.lockedIndicator setStyle:NSProgressIndicatorSpinningStyle];
        
        self.switchControl = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        
        [self.descriptionField setFrameOrigin:NSMakePoint(100, 12)];
        weak();
        [self.subdescField addBlock:^(BTRControlEvents events) {
            
            GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [weakSelf rowItem];
            
            if(item.type == SettingsRowItemTypeChoice) {
                
                TMMenuPopover *popover = [[TMMenuPopover alloc] initWithMenu:item.menu];
                
                [popover showRelativeToRect:weakSelf.subdescField.bounds ofView:weakSelf.subdescField preferredEdge:CGRectMinYEdge];
                                
            }
            
        } forControlEvents:BTRControlEventClick];
        

        self.nextImage = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_ArrowGrey().size.width, image_ArrowGrey().size.height)];
        
        self.nextImage.image = image_ArrowGrey();
        
        self.selectedImageView = imageViewWithImage(image_UsernameCheck());
        
        [self addSubview:self.nextImage];
        [self addSubview:self.descriptionField];
        [self addSubview:self.subdescField];
        [self addSubview:self.switchControl];
        [self addSubview:self.selectedImageView];
        [self addSubview:self.nextDesc];
        [self addSubview:self.lockedIndicator];
        
        
    }
    
    return self;
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
}


-(void)mouseDown:(NSEvent *)theEvent {
    TGGeneralRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    if(item.type == SettingsRowItemTypeNext || item.type == SettingsRowItemTypeNextBadge || item.type == SettingsRowItemTypeSelected || item.type == SettingsRowItemTypeNone) {
        item.callback(item);
    }

}


-(void)redrawRow {
    
    GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    [self.descriptionField setText:item.desc maxWidth:item.descSize.width];
    
    [self.nextDesc setText:item.subdesc maxWidth:item.subdescSize.width];
    
    [self.switchControl setEnabled:item.isEnabled];
    
    [self.switchControl setDidChangeHandler:^(BOOL isOn) {
        item.callback(item);
    }];
    
   switch (item.type) {
        case SettingsRowItemTypeSwitch:
           [self.badgeCounter setHidden:YES];
            [self.subdescField setHidden:YES];
            [self.switchControl setHidden:item.locked];
            [self.nextImage setHidden:YES];
            [self.switchControl setOn:[item.stateback(item) boolValue] animated:NO];
            [self.selectedImageView setHidden:YES];
            [self.nextDesc setHidden:YES];
           
            break;
        case SettingsRowItemTypeChoice:
           [self.badgeCounter setHidden:YES];
            [self.subdescField setHidden:item.locked];
            [self.switchControl setHidden:YES];
            [self.nextImage setHidden:YES];
           
            [self.subdescField setTitle:item.stateback(item) forControlState:BTRControlStateNormal];
            [self.subdescField.titleLabel sizeToFit];
            [self.selectedImageView setHidden:YES];
            [self.nextDesc setHidden:YES];
            break;
       case SettingsRowItemTypeNext: case SettingsRowItemTypeNextBadge :
            [self.subdescField setHidden:YES];
            [self.switchControl setHidden:YES];
            [self.nextImage setHidden:item.locked];
            [self.selectedImageView setHidden:YES];
            [self.nextDesc setHidden:self.nextDesc.text.length == 0 || item.locked];
            [self.badgeCounter setHidden:YES];
            if(item.type == SettingsRowItemTypeNextBadge) {
                [self.nextDesc setHidden:YES];
                [self.badgeCounter setHidden:[item.subdesc.string intValue] == 0];
            }
           
           [self.badgeCounter setStringValue:item.subdesc.string];
           
            break;
        case SettingsRowItemTypeSelected:
           [self.badgeCounter setHidden:YES];
           [self.subdescField setHidden:YES];
           [self.switchControl setHidden:YES];
           [self.nextImage setHidden:YES];
           [self.selectedImageView setHidden:![item.stateback(item) boolValue] || item.locked];
           [self.nextDesc setHidden:YES];
           break;
        case SettingsRowItemTypeNone:
           [self.badgeCounter setHidden:YES];
           [self.subdescField setHidden:YES];
           [self.switchControl setHidden:YES];
           [self.nextImage setHidden:YES];
           [self.selectedImageView setHidden:YES];
           [self.nextDesc setHidden:YES];
        default:
            break;
    }
    
    [self.lockedIndicator setHidden:!item.locked];
    
    if(item.locked) {
        [self.lockedIndicator startAnimation:self];
    } else {
        [self.lockedIndicator stopAnimation:self];
    }
    
     [self.subdescField setFrameSize:self.subdescField.titleLabel.frame.size];
  //  [_nextDesc sizeToFit];
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    
    [self.descriptionField setText:item.desc maxWidth:MIN(item.descSize.width, NSWidth(self.frame) - (item.xOffset * 2 + 50))];
    
    [self.nextDesc setText:item.subdesc maxWidth:MIN(item.subdescSize.width, NSWidth(self.frame) - (item.xOffset * 2 + 30 + NSWidth(_descriptionField.frame)))];
    
    
    
    [self.descriptionField setFrameOrigin:NSMakePoint( item.xOffset, 12)];
    
    [self.subdescField setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - NSWidth(self.subdescField.frame), 13)];
    
    [self.switchControl setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - NSWidth(self.switchControl.frame), 10)];
    
    [self.selectedImageView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - NSWidth(self.selectedImageView.frame), 12)];
        
    
    [self.nextImage setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - image_ArrowGrey().size.width - 4, 15)];
    
    
    
    [self.lockedIndicator setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - NSWidth(self.lockedIndicator.frame), 10)];
    
    
    
    [self.badgeCounter setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - NSWidth(self.badgeCounter.frame) - 15, 6)];
    [self.nextDesc setFrameOrigin:NSMakePoint(NSWidth(self.frame) - item.xOffset - NSWidth(self.nextImage.frame) - NSWidth(self.nextDesc.frame) - 10, 13)];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    
    TGGeneralRowItem *item = (TGGeneralRowItem *) [self rowItem];
    
    if(item.drawsSeparator) {
        [NSColorFromRGB(0xe0e0e0) setFill];
        
        NSRectFill(NSMakeRect(item.xOffset, 0, NSWidth(self.frame) - item.xOffset * 2, 1));
    }
    
    if(item.type == SettingsRowItemTypeNext && item.stateback != nil) {
        NSImage *image = item.stateback(item);
        
        if([image isKindOfClass:[NSImage class]]) {
            
            int y = roundf(NSHeight(self.frame)/2 - image.size.height/2);
            
            [image drawInRect:NSMakeRect(NSWidth(self.frame) - item.xOffset - image_ArrowGrey().size.width - image.size.width - 8, y , image.size.width, image.size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        }
    }
    
}

@end
