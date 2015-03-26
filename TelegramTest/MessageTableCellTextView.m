
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
@interface TestTextView : NSTextView
@property (nonatomic, strong) NSString *rand;
@property (nonatomic) BOOL isSelecedRange;
@property (nonatomic) BOOL linkClicked;
@end


@interface MessageTableCellTextView() <TMHyperlinkTextFieldDelegate>


// webpage container view;
@property (nonatomic,strong) TMView *webPageContainerView;
@property (nonatomic,strong) TGImageView *webPageImageView;
@property (nonatomic,strong) TMTextField *webPageTitleView;
@property (nonatomic,strong) TMTextField *webPageDescView;
@property (nonatomic,strong) TMView *webPageMarkView;


@end

@implementation MessageTableCellTextView



- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _textView = [[TGMultipleSelectTextView alloc] initWithFrame:self.bounds];
        
        [self.containerView addSubview:self.textView];
        
        [self.containerView setIsFlipped:YES];
        
        
        _textView.wantsLayer = YES;
        
        
    }
    return self;
}


-(void)initWebPageContainerView {
    
    
    if(_webPageContainerView == nil) {
        MessageTableItemText *item = (MessageTableItemText *)[self item];
        
        _webPageContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, item.textSize.height + 5, item.webBlockSize.width, item.webBlockSize.height)];
        
        _webPageContainerView.wantsLayer = YES;
        
        _webPageContainerView.layer.cornerRadius = 4;
        
        
        {
            _webPageImageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
            
            
            [_webPageContainerView addSubview:_webPageImageView];
            
            
            
            _webPageTitleView = [TMTextField defaultTextField];
            _webPageDescView = [TMTextField defaultTextField];
            
            
            _webPageMarkView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_webPageContainerView.frame), 40)];
            
            _webPageMarkView.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6);
            
            
            
            [_webPageContainerView addSubview:_webPageMarkView];
            
            [_webPageContainerView addSubview:_webPageTitleView];
            [_webPageContainerView addSubview:_webPageDescView];
            
            [_webPageTitleView setFrameOrigin:NSMakePoint(5, 20)];
            [_webPageDescView setFrameOrigin:NSMakePoint(5, 0)];
            
            
            [self setProgressToView:_webPageContainerView];
            
            [self.progressView setStyle:TMCircularProgressDarkStyle];
            
        }
        
        
        
        
        [_webPageContainerView setBackgroundColor:[NSColor grayColor]];
        
        
        [self.containerView addSubview:_webPageContainerView];
    }
    
}


-(void)deallocWebPageContainerView {
    
    [_webPageContainerView removeFromSuperview];
    
    _webPageContainerView = nil;
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
    } else if(![self.item isset]) {
        self.cellState = CellStateNeedDownload;
    } else {
        self.cellState = CellStateNormal;
    }
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    MessageTableItemText *item = (MessageTableItemText *)[self item];
    
    
    
    if([item isWebPage] && [self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_webPageContainerView.frame]) {
        open_link(item.message.media.webpage.display_url);
    }
}

- (void) setItem:(MessageTableItemText *)item {
    
 
    [super setItem:item];
    
    
    if([item isWebPage]) {
        [self initWebPageContainerView];
        
        [_webPageContainerView setFrame:NSMakeRect(0, item.textSize.height + 5, item.webBlockSize.width, item.webBlockSize.height)];
        
        [_webPageImageView setFrameSize:item.webBlockSize];
        
        [_webPageMarkView setFrameSize:NSMakeSize(NSWidth(_webPageContainerView.frame), 40)];
        
        [_webPageImageView setObject:item.webPageImageObject];
        
        [_webPageTitleView setFrameSize:NSMakeSize(NSWidth(_webPageContainerView.frame) - 5, 20)];
        [_webPageTitleView setAttributedStringValue:item.webPageTitle];
        
        [_webPageDescView setFrameSize:NSMakeSize(NSWidth(_webPageContainerView.frame) - 5, 20)];
        [_webPageDescView setAttributedStringValue:item.webPageDesc];
        
        
        [_webPageTitleView setToolTip:item.webPageToolTip];
        [_webPageMarkView setToolTip:item.webPageToolTip];
        [_webPageDescView setToolTip:item.webPageToolTip];
        [_webPageContainerView setToolTip:item.webPageToolTip];
        [_webPageImageView setToolTip:item.webPageToolTip];
        
        [item.webPageImageObject.supportDownloadListener setProgressHandler:^(DownloadItem *item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [self.progressView setProgress:50 + (item.progress/2) animated:YES];
                
            }];
            
        }];
        
        [item.webPageImageObject.supportDownloadListener setCompleteHandler:^(DownloadItem *item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [self updateCellState];
                
            }];
            
        }];
        
        
    } else {
        [self deallocWebPageContainerView];
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
    
    [self.progressView setHidden:self.item.isset];
    
    [self.progressView setState:cellState];
    
    [self.progressView setProgress:50 + (item.webPageImageObject.downloadItem.progress/2) animated:NO];
    
    [self.progressView setProgress:self.progressView.currentProgress animated:YES];
    
    [self.progressView setCenterByView:_webPageContainerView];
}

- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Text menu"];
   
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
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
    [self.textView pop_addAnimation:animation forKey:@"background"];
    
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
