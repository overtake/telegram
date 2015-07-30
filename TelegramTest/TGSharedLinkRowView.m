//
//  TGSharedLinkRowView.m
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSharedLinkRowView.h"
#import "MessageTableItemText.h"
#import "TGWebpageContainer.h"
#import "POPCGUtils.h"
#import "TGEmbedModalView.h"
@interface TGSharedLinkRowView ()
@property (nonatomic,strong) TGCTextView *textField;
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMTextField *linkField;
@property (nonatomic,strong) TGImageView *imageView;
@end

@implementation TGSharedLinkRowView


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(12, 0, NSWidth(dirtyRect) - 24, 1));
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _containerView = [[TMView alloc] initWithFrame:NSMakeRect(12, 0, NSWidth(frameRect) - 24, NSHeight(frameRect))];
        
        [self addSubview:_containerView];
        
        
        _textField = [[TGCTextView alloc] initWithFrame:self.bounds];
        
        [_textField setEditable:YES];
        [_containerView addSubview:_textField];
        
                
        _linkField = [TMTextField defaultTextField];
        
        [_linkField setFont:TGSystemFont(13)];
        [_linkField setTextColor:LINK_COLOR];
        
        [_linkField setFrameSize:NSMakeSize(0, 20)];
        dispatch_block_t block = ^{
            open_link(_linkField.stringValue);
        };
        
        [_linkField setClickBlock:^{
           
            block();
            
        }];
        
        [_containerView addSubview:_linkField];
        
        
        
        _imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        
        _imageView.cornerRadius = 4;
        
        
        dispatch_block_t embed = ^{
           
            
            MessageTableItemText *item = ((MessageTableItemText *)self.item);
            
            if(item.webpage.webpage.embed_url.length > 0)
            {
                TGEmbedModalView *embed =  [[TGEmbedModalView alloc] init];
                
                [embed setWebpage:item.webpage.webpage];
                
                [embed show:self.window animated:YES];
                
                
            }
            
        };
        
        [_imageView setTapBlock:^{
            embed();
        }];
        
        [self.containerView addSubview:_imageView];
        
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_containerView setFrame:NSMakeRect(12, 0, newSize.width - 24, newSize.height)];
}

-(void)setItem:(MessageTableItemText *)item {
    
    [super setItem:item];
    
    
    [_textField setHidden:item.webpage == nil];
    [_imageView setHidden:item.webpage.imageObject == nil];
    [_linkField setHidden:item.webpage == nil];
    
    if(item.webpage) {
        [_textField setAttributedString:item.webpage.desc];
        
        [_textField setFrameSize:item.webpage.descSize];
        
        [_textField setFrameOrigin:NSMakePoint(2, NSHeight(self.frame) - NSHeight(_textField.frame) - 5 )];
        
        
        
        [_linkField setStringValue:item.webpage.webpage.url];
        
        
        [_linkField setFrameOrigin:NSMakePoint(0, NSMinY(_textField.frame) - NSHeight(_linkField.frame))];
        [_linkField setFrameSize:NSMakeSize(NSWidth(_containerView.frame), 20)];
        
        [_imageView setObject:item.webpage.imageObject];
        
        [_imageView setFrame:NSMakeRect(NSWidth(self.containerView.frame) - 50, NSHeight(self.containerView.frame) - 50 - 5, 50, 50)];
    }
    
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim) {
        self.textField.backgroundColor = color;
        return;
    }
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    
    animation.property = [POPAnimatableProperty propertyWithName:@"background" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TGCTextView *textView, CGFloat values[]) {
            POPCGColorGetRGBAComponents(textView.backgroundColor.CGColor, values);
        }];
        
        [prop setWriteBlock:^(TGCTextView *textView, const CGFloat values[]) {
            CGColorRef color = POPCGColorRGBACreate(values);
            textView.backgroundColor = [NSColor colorWithCGColor:color];
        }];
        
    }];
    
    animation.toValue = anim.toValue;
    animation.fromValue = anim.fromValue;
    animation.duration = anim.duration;
    [self.textField pop_addAnimation:animation forKey:@"background"];
    
}



-(void)_colorAnimationEvent {
    
    CALayer *currentLayer = (CALayer *)[self.textField.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    self.textField.layer.backgroundColor = (__bridge CGColorRef)(value);
    [self.textField setNeedsDisplay:YES];
    
}

@end
