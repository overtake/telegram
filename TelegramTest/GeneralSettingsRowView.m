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
@interface GeneralSettingsRowView ()
@property (nonatomic,strong) TMTextField *descriptionField;

@property (nonatomic,strong) TMTextField *nextDesc;
@property (nonatomic,strong) ITSwitch *switchControl;
@property (nonatomic,strong) NSImageView *nextImage;
@property (nonatomic,strong) NSImageView *selectedImageView;
@property (nonatomic,strong) NSProgressIndicator *lockedIndicator;
@end

@implementation GeneralSettingsRowView



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.descriptionField = [TMTextField defaultTextField];
        self.subdescField = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 200, 20)];
        
        self.nextDesc = [TMTextField defaultTextField];
        [self.nextDesc setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:14]];
        self.nextDesc.textColor = GRAY_TEXT_COLOR;
        
        
        
        [self.descriptionField setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [self.subdescField setTitleFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forControlState:BTRControlStateNormal];
        
        self.descriptionField.textColor = DARK_BLACK;
        
        [self.subdescField setTitleColor:GRAY_TEXT_COLOR forControlState:BTRControlStateNormal];
        
        
        self.lockedIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        [self.lockedIndicator setStyle:NSProgressIndicatorSpinningStyle];
        
        self.switchControl = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        weak();
        [self.descriptionField setFrameOrigin:NSMakePoint(100, 12)];
        
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

-(void)mouseDown:(NSEvent *)theEvent {
    GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    if(item.type == SettingsRowItemTypeNext || item.type == SettingsRowItemTypeSelected) {
        item.callback(item);
    }
}


-(void)redrawRow {
    
    GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    [self.descriptionField setStringValue:item.description];
    
    [self.nextDesc setStringValue:item.subdesc];
    
    [self.nextDesc sizeToFit];
    
    
    
    [self.switchControl setDidChangeHandler:^(BOOL isOn) {
        item.callback(item);
    }];
    
   switch (item.type) {
        case SettingsRowItemTypeSwitch:
            [self.subdescField setHidden:YES];
            [self.switchControl setHidden:item.locked];
            [self.nextImage setHidden:YES];
            [self.switchControl setOn:[item.stateback(item) boolValue]];
            [self.selectedImageView setHidden:YES];
            [self.nextDesc setHidden:YES];
           
            break;
        case SettingsRowItemTypeChoice:
            [self.subdescField setHidden:item.locked];
            [self.switchControl setHidden:YES];
            [self.nextImage setHidden:YES];
            [self.subdescField setTitle:item.stateback(item) forControlState:BTRControlStateNormal];
            [self.selectedImageView setHidden:YES];
            [self.nextDesc setHidden:YES];
            break;
        case SettingsRowItemTypeNext:
            [self.subdescField setHidden:YES];
            [self.switchControl setHidden:YES];
            [self.nextImage setHidden:item.locked];
            [self.selectedImageView setHidden:YES];
            [self.nextDesc setHidden:self.nextDesc.stringValue.length == 0 || item.locked];
            break;
        case SettingsRowItemTypeSelected:
           [self.subdescField setHidden:YES];
           [self.switchControl setHidden:YES];
           [self.nextImage setHidden:YES];
           [self.selectedImageView setHidden:![item.stateback(item) boolValue] || item.locked];
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
    
    [self.descriptionField sizeToFit];
    [self.subdescField.titleLabel sizeToFit];
    [self.subdescField setFrameSize:self.subdescField.titleLabel.frame.size];
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.subdescField setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.subdescField.frame), 10)];
    
    [self.switchControl setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.switchControl.frame), 10)];
    
    [self.selectedImageView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.selectedImageView.frame), 10)];
    
    [self.nextImage setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - image_ArrowGrey().size.width - 4, 14)];
    
    [self.nextDesc setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.nextImage.frame) - NSWidth(self.nextDesc.frame) - 8, 13)];
    
    [self.lockedIndicator setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.lockedIndicator.frame), 10)];
    
    [self.descriptionField setFrameSize:NSMakeSize(NSWidth(self.frame) - 250, NSHeight(self.descriptionField.frame))];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(100, 0, NSWidth(self.frame) - 200, 1));
}

@end
