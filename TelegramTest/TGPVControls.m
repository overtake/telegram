//
//  TGPVControls.m
//  Telegram
//
//  Created by keepcoder on 11.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVControls.h"
#import "TGPhotoViewer.h"
#import "MessageTableItem.h"
#import "TGPVUserBehavior.h"
#import "TGPVMediaBehavior.h"
@interface TGPVControls ()

@property (nonatomic,strong) BTRTextField *countTextField;
@property (nonatomic,strong) BTRButton *leftButton;
@property (nonatomic,strong) BTRButton *rightButton;
@property (nonatomic,strong) BTRButton *moreButton;
@property (nonatomic,strong) BTRButton *closeButton;
@property (nonatomic, strong) TMMenuPopover *menuPopover;
@end


@implementation TGPVControls



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)update {
     self.countTextField.alphaValue = 0.7;
    [self.leftButton setAlphaValue:0.7];
    [self.rightButton setAlphaValue:0.7];
    [self.closeButton setAlphaValue:0.7];
    [self.moreButton setAlphaValue:0.7];
}

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.countTextField = [[BTRTextField alloc] initWithFrame:NSZeroRect];
        
        weak();
        
        [self.countTextField addBlock:^(BTRControlEvents events) {
            if([[TGPhotoViewer behavior] class] == [TGPVMediaBehavior class])
                weakSelf.countTextField.alphaValue = 1.0;
            
        } forControlEvents:BTRControlEventMouseEntered];
        
        [self.countTextField addBlock:^(BTRControlEvents events) {
            if([[TGPhotoViewer behavior] class] == [TGPVMediaBehavior class])
                weakSelf.countTextField.alphaValue = 0.7;
            
        } forControlEvents:BTRControlEventMouseExited];
        
        [self.countTextField addBlock:^(BTRControlEvents events) {
            
            if([[TGPhotoViewer behavior] class] == [TGPVMediaBehavior class]) {
                [[TGPhotoViewer viewer] hide];
                
                [[Telegram rightViewController] showCollectionPage:weakSelf.convertsation];
            }
            
           
            
        } forControlEvents:BTRControlEventClick];
        
        [self.countTextField setBordered:NO];
        [self.countTextField setDrawsBackground:NO];
        [self.countTextField setSelectable:NO];
        [self.countTextField setEditable:NO];
        
        
        self.countTextField.alphaValue = 0.7;
        
        self.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6);
        
        [self.countTextField setFont:[NSFont fontWithName:@"HelveticaNeue-Bold" size:18]];
        
        [self.countTextField sizeToFit];
        
        [self.countTextField setTextColor:[NSColor whiteColor]];
        
        
        [self addSubview:self.countTextField];
        
        self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        self.wantsLayer = YES;
        self.layer.cornerRadius = 8;
        
        
        
        
        self.leftButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [self.leftButton setImage:image_PhotoViewerLeft() forControlState:BTRControlStateNormal];
        [self.leftButton setCenterByView:self];
        [self.leftButton setFrameOrigin:NSMakePoint(10, NSMinY(self.leftButton.frame))];
        
        
        self.rightButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [self.rightButton setImage:image_PhotoViewerRight() forControlState:BTRControlStateNormal];
        [self.rightButton setCenterByView:self];
        [self.rightButton setFrameOrigin:NSMakePoint(60+16, NSMinY(self.rightButton.frame))];
        
        
        self.moreButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [self.moreButton setImage:image_PhotoViewerMore() forControlState:BTRControlStateNormal];
        [self.moreButton setCenterByView:self];
        [self.moreButton setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 130, NSMinY(self.moreButton.frame))];
        
        self.closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [self.closeButton setImage:image_PhotoViewerClose() forControlState:BTRControlStateNormal];
        [self.closeButton setCenterByView:self];
        [self.closeButton setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 60, NSMinY(self.closeButton.frame))];
        
        
        [self.leftButton addBlock:^(BTRControlEvents events) {
            weakSelf.leftButton.alphaValue = 1;
        } forControlEvents:BTRControlEventMouseEntered];
        
        [self.leftButton addBlock:^(BTRControlEvents events) {
            weakSelf.leftButton.alphaValue = 0.7;
        } forControlEvents:BTRControlEventMouseExited];

        
        [self.rightButton addBlock:^(BTRControlEvents events) {
            weakSelf.rightButton.alphaValue = 1;
        } forControlEvents:BTRControlEventMouseEntered];
        [self.rightButton addBlock:^(BTRControlEvents events) {
            weakSelf.rightButton.alphaValue = 0.7;
        } forControlEvents:BTRControlEventMouseExited];
        
        [self.closeButton addBlock:^(BTRControlEvents events) {
            weakSelf.closeButton.alphaValue = 1;
        } forControlEvents:BTRControlEventMouseEntered];
        [self.closeButton addBlock:^(BTRControlEvents events) {
            weakSelf.closeButton.alphaValue = 0.7;
        } forControlEvents:BTRControlEventMouseExited];
        
        [self.moreButton addBlock:^(BTRControlEvents events) {
            
            if([[TGPhotoViewer behavior] class] == [TGPVMediaBehavior class])
                weakSelf.moreButton.alphaValue = 1;
            
            
        } forControlEvents:BTRControlEventMouseEntered];
        [self.moreButton addBlock:^(BTRControlEvents events) {
            
        if([[TGPhotoViewer behavior] class] == [TGPVMediaBehavior class])
            weakSelf.moreButton.alphaValue = 0.7;
            
            
        } forControlEvents:BTRControlEventMouseExited];
        
        
        [self.leftButton addBlock:^(BTRControlEvents events) {
            [TGPhotoViewer prevItem];
        } forControlEvents:BTRControlEventClick];
        
        [self.rightButton addBlock:^(BTRControlEvents events) {
            [TGPhotoViewer nextItem];
        } forControlEvents:BTRControlEventClick];
        
        [self.moreButton addBlock:^(BTRControlEvents events) {
            if([[TGPhotoViewer behavior] class] == [TGPVMediaBehavior class])
                [weakSelf contextMenu];
            
        } forControlEvents:BTRControlEventClick];
        
        [self.closeButton addBlock:^(BTRControlEvents events) {
           
             [[TGPhotoViewer viewer] close];
            
        } forControlEvents:BTRControlEventClick];
        
        
        [self.leftButton setAlphaValue:0.7];
        [self.rightButton setAlphaValue:0.7];
        [self.closeButton setAlphaValue:0.7];
        [self.moreButton setAlphaValue:0.7];
        
        
        [self addSubview:self.leftButton];
        [self addSubview:self.rightButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.closeButton];
        
    }
    
    return self;
}


- (void) contextMenu {
    
    [self.moreButton setSelected:YES];
    
    if(!self.menuPopover) {
        self.menuPopover = [[TMMenuPopover alloc] initWithMenu:self.menu];
        [self.menuPopover setHoverView:self.moreButton];
    }
    
    if(!self.menuPopover.isShown) {
        NSRect rect = self.moreButton.bounds;
        weak();
        [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {
            [weakSelf.moreButton setSelected:NO];
        }];
        [self.menuPopover showRelativeToRect:rect ofView:self.moreButton preferredEdge:CGRectMaxYEdge];
    }
    
    //    [self.attachMenu popUpForView:self.attachButton];
}

-(NSMenu *)menu {
    NSMenu *theMenu = [[NSMenu alloc] init];
    
    
    
    NSMenuItem *photoDelete = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"PhotoViewer.Delete", nil) withBlock:^(id sender) {
        
        TL_localMessage *msg = [TGPhotoViewer currentItem].previewObject.media;
        
        [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:@[@(msg.n_id)]}];
        
        
    }];
   // [photoDelete setImage:image_AttachPhotoVideo()];
   // [photoDelete setHighlightedImage:image_AttachPhotoVideoHighlighted()];
    [theMenu addItem:photoDelete];
    
    
    NSMenuItem *photoForward = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"PhotoViewer.Forward", nil) withBlock:^(id sender) {
        
        TL_localMessage *msg = [TGPhotoViewer currentItem].previewObject.media;
        
        [[Telegram rightViewController] showByDialog:msg.dialog sender:[TGPhotoViewer viewer]];
        [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
        [[Telegram rightViewController].messagesViewController unSelectAll:NO];
        
        MessageTableItem *item  = [MessageTableItem messageItemFromObject:msg];
        
        [[Telegram rightViewController].messagesViewController setSelectedMessage:item selected:YES];
        
        
        [[Telegram rightViewController] showForwardMessagesModalView:_convertsation messagesCount:1];
        
        [[TGPhotoViewer viewer] hide];
        
        
    }];
    //[photoForward setImage:image_AttachTakePhoto()];
    //[photoForward setHighlightedImage:image_AttachTakePhotoHighlighted()];
    [theMenu addItem:photoForward];

    
    
    NSMenuItem *photoSave = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"PhotoViewer.SaveAs", nil) withBlock:^(id sender) {
        
        
        
        [[NSSavePanel savePanel] setNameFieldStringValue:@"image"];
        
        [[NSSavePanel savePanel] beginSheetModalForWindow:[TGPhotoViewer viewer] completionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *file = [[NSSavePanel savePanel] URL];
                
                NSString *itemUrl = mediaFilePath([[TGPhotoViewer currentItem].previewObject.media media]);
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:itemUrl] ) {
                    //                    DLog(@"file %@", file);
                    [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:itemUrl] toURL:file error:nil];
                }
                
            } else if(result == NSFileHandlingPanelCancelButton) {
                
            }
            
        }];
        
        
    }];
  //  [photoSave setImage:image_AttachFile()];
   // [photoSave setHighlightedImage:image_AttachFileHighlighted()];
    
    [theMenu addItem:photoSave];
    
    
    NSMenuItem *photoGoto = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"PhotoViewer.Goto", nil) withBlock:^(id sender) {
        
        [[Telegram rightViewController] showByDialog:_convertsation withJump:[TGPhotoViewer currentItem].previewObject.msg_id historyFilter:[HistoryFilter class] sender:[TGPhotoViewer viewer]];
        
        [[TGPhotoViewer viewer] hide];
        
    }];
    
    
    [theMenu addItem:photoGoto];
    
   // [photoSave setImage:image_AttachFile()];
   // [photoSave setHighlightedImage:image_AttachFileHighlighted()];
    
    
    
    
    return theMenu;
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}


-(void)setCurrentPosition:(NSUInteger)position ofCount:(NSUInteger)count {
    
    [self.countTextField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"PhotoViewer.posOfCount", nil),position,count]];
    
    [self.countTextField sizeToFit];
    
    [self.countTextField setCenterByView:self];
}

@end
