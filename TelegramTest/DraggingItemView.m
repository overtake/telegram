//
//  DraggingItemView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 05.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DraggingItemView.h"
#import "DraggingControllerView.h"

@interface DraggingItemView ()
@property (nonatomic,strong) TMTextField *field;

@end

@implementation DraggingItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        
        self.backgroundColor = NSColorFromRGB(0xffffff);
        
        self.dragEntered = NO;
        
        
      
        
        _field = [TMTextField defaultTextField];
        
        _field.frame = NSMakeRect(0, roundf(frame.size.width / 2) - 25, frame.size.width, 50);
        
        _field.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin;
        
        _field.textColor = NSColorFromRGB(0xA1A1A1);
        
        
        
        [self addSubview:_field];
        
        
        
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,NSTIFFPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    [self becomeFirstResponder];
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( ![pboard.name isEqualToString:TGImagePType] ) {
        if (sourceDragMask) {
            self.dragEntered = YES;
            return NSDragOperationLink;
        }
    }
    
    return NSDragOperationNone;
}

-(void)draggingExited:(id<NSDraggingInfo>)sender {
    self.dragEntered = NO;
}

-(void)draggingEnded:(id<NSDraggingInfo>)sender {
    [[DraggingControllerView view] removeFromSuperview];
    
    
   // POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
  
 //   anim.toValue = [NSValue valueWithCGRect:CGRectMake(self.frame.origin.x+self.frame.size.width/2, self.frame.origin.y+self.frame.size.width/2, 0, 0)];
    
  //  anim.delegate = self;
    
    
 //  [self.layer pop_addAnimation:anim forKey:@"size"];
    
    //[[DraggingControllerView view] removeFromSuperview];
}

-(void)setDragEntered:(BOOL)dragEntered {
    self->_dragEntered = dragEntered;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
  
    TL_conversation *dialog = [Telegram rightViewController].messagesViewController.conversation;
  
    return [MessageSender sendDraggedFiles:sender dialog:dialog asDocument:_type == DraggingTypeDocument];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    self.layer.borderWidth = self.dragEntered ? 2.0f : 2.0f;
    self.layer.borderColor = self.dragEntered ? NSColorFromRGB(0x48B8ED).CGColor : NSColorFromRGBWithAlpha(0xDEDEDE, 1.0).CGColor;

//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = NSColorFromRGBWithAlpha(0x000000,0.4);
//    shadow.shadowOffset = NSMakeSize(0, 1);
//    shadow.shadowBlurRadius = 4.0f;
    
    self.layer.opacity = self.dragEntered ? 1.0f : 0.6f;
    
   // self.shadow = self.dragEntered ? nil : shadow;
    
   // [shadow set];
    
    self.layer.cornerRadius = 5.0f;
}

-(void)setTitle:(NSString *)title {
    self->_title = title;
    
    
    [self updateField];

}

-(void)updateField {
    
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    
    if(_title) {
        range = [str appendString:_title withColor:NSColorFromRGB(0xA1A1A1)];
        
        [str addAttributes:@{NSFontAttributeName:TGSystemFont(13)} range:range];
        
        [str setAlignment:NSCenterTextAlignment range:range];
    }
    
    if(_subtitle) {
        range = [str appendString:[@"\n" stringByAppendingString:_subtitle] withColor:NSColorFromRGB(0x333333)];
        
        [str addAttributes:@{NSFontAttributeName:TGSystemFont(22)} range:range];
        
        [str setAlignment:NSCenterTextAlignment range:range];
    }
    
   
    
    [_field setAttributedStringValue:str];
    
    
    
}

-(void)setSubtitle:(NSString *)subtitle {
    self->_subtitle = subtitle;
    
    [self updateField];
    
}

@end
