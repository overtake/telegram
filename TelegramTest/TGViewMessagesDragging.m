//
//  TGViewMessagesDragging.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGViewMessagesDragging.h"
#import "DraggingControllerView.h"
@interface TGViewMessagesDragging ()

@end

@implementation TGViewMessagesDragging

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    if(self.navigationViewController.messagesViewController.conversation && self.navigationViewController.currentController == self.navigationViewController.messagesViewController) {
        NSPasteboard *pst = [sender draggingPasteboard];
        
        if(![pst.name isEqualToString:TGImagePType] && ( [[pst types] containsObject:NSFilenamesPboardType] || [[pst types] containsObject:NSTIFFPboardType])) {
            
            if([[pst types] containsObject:NSFilenamesPboardType]) {
                NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
                
                
                
                if(files.count == 1 && ![mediaTypes() containsObject:[[files[0] pathExtension] lowercaseString]]) {
                    [DraggingControllerView setType:DraggingTypeSingleChoose];
                } else {
                    [DraggingControllerView setType:DraggingTypeMultiChoose];
                }
            }
            
            
            [self addSubview:[DraggingControllerView view:self.frame.size]];
            
        }
        
    }
    
    
    return NSDragOperationNone;
}




-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    [MessageSender sendDraggedFiles:sender dialog:self.navigationViewController.messagesViewController.conversation asDocument:NO];
    
    return YES;
}

@end
