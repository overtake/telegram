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
@property (nonatomic,strong) BTRButton *subdescField;
@property (nonatomic,strong) ITSwitch *switchControl;
@property (nonatomic,strong) NSImageView *nextImage;
@end

@implementation GeneralSettingsRowView



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.descriptionField = [TMTextField defaultTextField];
        self.subdescField = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 200, 20)];
        
        
        [self.descriptionField setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [self.subdescField setTitleFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forControlState:BTRControlStateNormal];
        
        self.descriptionField.textColor = DARK_BLACK;
        
        [self.subdescField setTitleColor:NSColorFromRGB(0x999999) forControlState:BTRControlStateNormal];
        
        
        self.switchControl = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 20)];
        
        
        [self.descriptionField setFrameOrigin:NSMakePoint(100, 10)];
        
        [self.subdescField addBlock:^(BTRControlEvents events) {
            
            GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
            
            if(item.type == SettingsRowItemTypeChoice) {
                
                NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
                
                NSArray *list = soundsList();
                
                for (int i = 0; i < list.count; i++) {
                    
                    NSMenuItem *item = [NSMenuItem menuItemWithTitle:NSLocalizedString(list[i], nil) withBlock:^(NSMenuItem *sender) {
                        
                        if([sender.title isEqualToString:NSLocalizedString(@"DefaultSoundName", nil)])
                            [SettingsArchiver setSoundNotification:@"DefaultSoundName"];
                        else
                            [SettingsArchiver setSoundNotification:sender.title];
                        
                        [self redrawRow];
                        
                    }];
                    
                    
                    
                    [menu addItem:item];
                    if(i == 0) {
                        [menu addItem:[NSMenuItem separatorItem]];
                    }
                }
                
                [menu popUpForView:self.subdescField];
                
            }
            
        } forControlEvents:BTRControlEventClick];
        

        
        self.nextImage = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_ArrowGrey().size.width, image_ArrowGrey().size.height)];
        
        self.nextImage.image = image_ArrowGrey();
        
        [self addSubview:self.nextImage];
        [self addSubview:self.descriptionField];
        [self addSubview:self.subdescField];
        [self addSubview:self.switchControl];
    }
    
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
    GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    if(item.type == SettingsRowItemTypeNext) {
        item.callback(item);
    }
}


-(void)redrawRow {
    
    GeneralSettingsRowItem *item = (GeneralSettingsRowItem *) [self rowItem];
    
    [self.descriptionField setStringValue:item.description];
    
    [self.switchControl setDidChangeHandler:^(BOOL isOn) {
        item.callback(item);
    }];
    
   switch (item.type) {
        case SettingsRowItemTypeSwitch:
            [self.subdescField setHidden:YES];
            [self.switchControl setHidden:NO];
            [self.nextImage setHidden:YES];
            [self.switchControl setOn:[item.stateback(item) boolValue]];
            
            break;
        case SettingsRowItemTypeChoice:
            [self.subdescField setHidden:NO];
            [self.switchControl setHidden:YES];
            [self.nextImage setHidden:YES];
            [self.subdescField setTitle:item.stateback(item) forControlState:BTRControlStateNormal];
           
            break;
        case SettingsRowItemTypeNext:
            [self.subdescField setHidden:YES];
            [self.switchControl setHidden:YES];
            [self.nextImage setHidden:NO];
            
            break;
        default:
            break;
    }
    
    [self.descriptionField sizeToFit];
    [self.subdescField.titleLabel sizeToFit];
    [self.subdescField setFrameSize:self.subdescField.titleLabel.frame.size];

}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.subdescField setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.subdescField.frame), 10)];
    
    [self.switchControl setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - NSWidth(self.switchControl.frame), 10)];
    
    [self.nextImage setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 100 - image_ArrowGrey().size.width, 14)];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(100, 0, NSWidth(self.frame) - 200, 1));
}

@end
