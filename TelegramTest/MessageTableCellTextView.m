
//
//  MessageTableCellTextView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellTextView.h"
#import "MessageTableItemText.h"
#import "TGTimerTarget.h"
#import "POPCGUtils.h"
#import "TGImageView.h"
#import "XCDYouTubeKit.h"
#import "TGWebpageContainer.h"

@interface TestTextView : NSTextView
@property (nonatomic, strong) NSString *rand;
@property (nonatomic) BOOL isSelecedRange;
@property (nonatomic) BOOL linkClicked;
@end


@interface MessageTableCellTextView() <TMHyperlinkTextFieldDelegate>



@property (nonatomic,strong) TGWebpageContainer *webpageContainerView;

@end

@implementation MessageTableCellTextView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _textView = [[TGMultipleSelectTextView alloc] initWithFrame:self.bounds];
        
        [self.containerView addSubview:self.textView];
        
        [self.containerView setIsFlipped:YES];
        
        
        [self.progressView removeFromSuperview];

        
        _textView.wantsLayer = YES;
        
        
    }
    return self;
}




- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}

-(void)selectSearchTextInRange:(NSRange)range {
    
    [self.textView setSelectionRange:range];
    
}


- (void)setEditable:(BOOL)editable animation:(BOOL)animation {
    [super setEditable:editable animation:animation];
    [self.textView setEditable:!editable];
}


- (void)updateCellState {
    
    
    MessageTableItem *item =(MessageTableItem *)self.item;
    
    if(item.downloadItem && (item.downloadItem.downloadState != DownloadStateWaitingStart && item.downloadItem.downloadState != DownloadStateCompleted)) {
        self.cellState = item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading;
    } else if(item.messageSender && item.messageSender.state != MessageSendingStateSent ) {
        self.cellState = item.messageSender.state == MessageSendingStateCancelled ? CellStateCancelled : CellStateSending;
    } else {
        self.cellState = CellStateNormal;
    }
    
}


-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    
}

- (void) setItem:(MessageTableItemText *)item {
    
 
    [super setItem:item];
       
    
    if([item isWebPage]) {
        
        if(!_webpageContainerView || _webpageContainerView.class != item.webpage.webpageContainer) {
            [_webpageContainerView removeFromSuperview];
            
            _webpageContainerView = [[item.webpage.webpageContainer alloc] initWithFrame:NSZeroRect];
            
            [self.containerView addSubview:_webpageContainerView];
        }
        
        [_webpageContainerView setFrame:NSMakeRect(0, item.textSize.height + 5, item.webpage.size.width, item.webpage.blockHeight)];
        
        [_webpageContainerView setWebpage:item.webpage];
        
        [_webpageContainerView setItem:item];
        
        
    } else {
        [_webpageContainerView removeFromSuperview];
        _webpageContainerView = nil;
    }
    
    [self updateCellState];
    
    [self.textView setFrameSize:NSMakeSize(item.textSize.width , item.textSize.height)];
    
    
    [self.textView setAttributedString:item.textAttributed];
    
    [self.textView setOwner:item];
    
    [self.textView setSelectionRange:[SelectTextManager rangeForItem:item]];
    
    [self.textView addMarks:item.mark.marks];
    
}


-(void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    MessageTableItemText *item = (MessageTableItemText *)[self item];
    
    [self.webpageContainerView updateState:cellState];
    
}

- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Text menu"];
   
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}

-(void)clearSelection {
    [super clearSelection];
    [_textView setSelectionRange:NSMakeRange(NSNotFound, 0)];
}

-(BOOL)mouseInText:(NSEvent *)theEvent {
    return [_textView mouseInText:theEvent] || [super mouseInText:theEvent];
}


-(void)_mouseDragged:(NSEvent *)theEvent {
    [self.textView _parentMouseDragged:theEvent];
}

-(void)_setStartSelectPosition:(NSPoint)position {
     self.textView->startSelectPosition = position;
    [self.textView setNeedsDisplay:YES];
}
-(void)_setCurrentSelectPosition:(NSPoint)position {
     self.textView->currentSelectPosition = position;
     [self.textView setNeedsDisplay:YES];
}


-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
     [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim) {
        self.textView.backgroundColor = color;
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
    animation.removedOnCompletion = YES;
    [self.textView pop_addAnimation:animation forKey:@"background"];
    
    [self.webpageContainerView.descriptionField pop_addAnimation:animation forKey:@"background"];
    
}



-(void)_colorAnimationEvent {
    
    CALayer *currentLayer = (CALayer *)[self.textView.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    self.textView.layer.backgroundColor = (__bridge CGColorRef)(value);
    [self.textView setNeedsDisplay:YES];
    
}


-(void)setSelected:(BOOL)selected animation:(BOOL)animation {
    
    if(selected == self.isSelected)
        return;
    
    [super setSelected:selected animation:animation];
    
    if(!animation) {
        [self.textView setBackgroundColor:selected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff)];
    }
}

@end
