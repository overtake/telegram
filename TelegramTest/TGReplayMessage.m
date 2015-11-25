//
//  TGReplayMessage.m
//  Telegram
//
//  Created by keepcoder on 05.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGReplayMessage.h"
#import "MessageTableItem.h"
#import "MessageTableItemText.h"

@interface TGReplayMessage ()
@property (nonatomic,strong) MessageTableItem *message;


@property (nonatomic,strong) TMHyperlinkTextField *nameTextField;
@property (nonatomic,strong) TMTextField *messageField;
@end

@implementation TGReplayMessage

-(id)initWithFrame:(NSRect)frameRect message:(TL_localMessage *)message {
    if(self = [super initWithFrame:frameRect]) {
        _message = [MessageTableItem messageItemFromObject:message];
        
        
        self.nameTextField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(15, NSHeight(frameRect) - 12, 200, 20)];
        [self.nameTextField setBordered:NO];
        [self.nameTextField setFont:TGSystemMediumFont(13)];
        [self.nameTextField setDrawsBackground:NO];
        
        [self addSubview:self.nameTextField];
        
        self.messageField = [TMTextField defaultTextField];
        
        [self.messageField setFrameOrigin:NSMakePoint(15, 0)];
        
        [self addSubview:self.messageField];
        
        
        [self update];
    }
    
    return self;
}

-(NSColor *)color {
    
    NSRange range = NSMakeRange(0, 1);
    
    return [self.message.headerName attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
}



-(void)update {
    
    
    
    [self.nameTextField setAttributedStringValue:[self.message headerName]];
    
    [self.nameTextField sizeToFit];
    
    
    
    
    if([self.message.message.media isKindOfClass:[TL_messageMediaEmpty class]] || self.message.message.media == nil) {
       
        [self.messageField setAttributedStringValue:((MessageTableItemText *)self.message).textAttributed];
        
        [self.messageField sizeToFit];
        
        [self.messageField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.messageField.frame), NSHeight(self.messageField.frame))];
        
    }
    
    if([self.message.message.media isKindOfClass:[TL_messageMediaVideo class]]) {
        
    }
    
    if([self.message.message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        
    }
    
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[self color] setFill];
    
    NSRectFill(NSMakeRect(0, 0, 3, NSHeight(self.frame)));
    
    // Drawing code here.
}

@end
