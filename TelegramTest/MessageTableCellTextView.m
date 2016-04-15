
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
#import "TMMediaController.h"
#import "TMPreviewPhotoItem.h"
#import "TMPreviewDocumentItem.h"
#import "TGUserPopup.h"
#import "TMMenuPopover.h"
@interface TestTextView : NSTextView
@property (nonatomic, strong) NSString *rand;
@property (nonatomic) BOOL isSelecedRange;
@property (nonatomic) BOOL linkClicked;
@end


@interface MessageTableCellTextView() <TMHyperlinkTextFieldDelegate>



@property (nonatomic,strong) TGWebpageContainer *webpageContainerView;

@end

@implementation MessageTableCellTextView


static TGUserPopup *short_info_controller;
static RBLPopover *popover;
static NSString *last_link;
static RPCRequest *resolveRequest;
static NSMutableDictionary *ignoreName;
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            short_info_controller = [[TGUserPopup alloc] initWithFrame:NSMakeRect(0, 0, 200, 60)];
            popover = [[RBLPopover alloc] initWithContentViewController:(NSViewController *)short_info_controller];
            ignoreName = [NSMutableDictionary dictionary];
        });
        
        _textView = [[TGMultipleSelectTextView alloc] initWithFrame:self.bounds];
        
        weak();
        
        [_textView setLinkCallback:^(NSString *link) {
            last_link = nil;
            [resolveRequest cancelRequest];
            [popover close];
            
            open_link_with_controller(link, weakSelf.messagesViewController.navigationViewController);
        }];
        
        [_textView setLinkOver:^(NSString *link, BOOL over, NSRect rect) {
            
            popover.animates = NO;
            
            BOOL accept = [link hasPrefix:@"@"];
            
            if([link rangeOfString:@"telegram.me"].location != NSNotFound || [link hasPrefix:@"tg://resolve"]) {
                link = tg_domain_from_link(link);
                accept = link.length > 0;
            }
            
            __block id obj = [Telegram findObjectWithName:link];
            

            
            if(!over || ![link isEqualToString:last_link] || !accept || (ignoreName[link] && !obj)) {
                last_link = nil;
                [resolveRequest cancelRequest];
                [popover close];
                
                if( !over || ignoreName[link] || !accept)
                    return;
                
            }
            

            
            if(![link isEqualToString:last_link] || !popover.isShown) {
                last_link = link;
                
                dispatch_block_t show_block = ^{
                    [short_info_controller setObject:obj];
                    
                    //  [popover setHoverView:weakSelf.textView];
                    
                    
                    if(!popover.isShown) {
                        [popover setDidCloseBlock:^(RBLPopover *popover) {
                            popover = nil;
                        }];
                        
     
                        [popover showRelativeToRect:NSOffsetRect(rect, 3, -3) ofView:weakSelf.textView preferredEdge:CGRectMaxYEdge];
                    }
                };
                
                if(over) {
                    
                    if(obj) {
                        show_block();
                    } else {
                        [resolveRequest cancelRequest];
                        resolveRequest = [RPCRequest sendRequest:[TLAPI_contacts_resolveUsername createWithUsername:link] successHandler:^(RPCRequest *request, TL_contacts_resolvedPeer *response) {
                            
                            [SharedManager proccessGlobalResponse:response];
                            
                            if([response.peer isKindOfClass:[TL_peerChannel class]]) {
                                obj = [response.chats firstObject];
                            } else if([response.peer isKindOfClass:[TL_peerUser class]]) {
                                obj = [response.users firstObject];
                            }
                            
                            if(obj) {
                                show_block();
                            }
                            
                            
                        } errorHandler:^(RPCRequest *request, RpcError *error) {
                            
                            ignoreName[link] = @(1);
                            
                        } timeout:4];
                    }
                    
                }
            }
            

        }];
        
        [self.containerView addSubview:self.textView];
    
    }
    return self;
}




- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}

-(void)selectSearchTextInRange:(NSRange)range {
    
    [self.textView setSelectionRange:range];
    
}


- (void)setEditable:(BOOL)editable animated:(BOOL)animated {
    [super setEditable:editable animated:animated];
    [self.textView setEditable:!editable];
}


- (void)updateCellState:(BOOL)animated {
    
    
    MessageTableItem *item =(MessageTableItem *)self.item;
    
    if(item.downloadItem && (item.downloadItem.downloadState != DownloadStateWaitingStart && item.downloadItem.downloadState != DownloadStateCompleted)) {
        [self setCellState:item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading animated:animated];
    } else if(item.messageSender && item.messageSender.state != MessageSendingStateSent ) {
        [self setCellState:item.messageSender.state == MessageSendingStateCancelled ? CellStateCancelled : CellStateSending animated:animated];
    } else {
        [self setCellState:CellStateNormal animated:animated];
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
        
        [_webpageContainerView setFrame:NSMakeRect(0, item.textSize.height + item.defaultContentOffset, item.webpage.size.width + item.defaultOffset, item.webpage.blockHeight)];
        
        [_webpageContainerView setItem:item];
        
        [_webpageContainerView setWebpage:item.webpage];
        
    } else {
        [_webpageContainerView removeFromSuperview];
        _webpageContainerView = nil;
    }
    
    [self updateCellState:NO];
    
    [self.textView setFrameSize:NSMakeSize(item.textSize.width , item.textSize.height)];
    
    
    [self.textView setAttributedString:item.textAttributed];
    
    [self.textView setOwner:item];
    
    [self.textView setSelectionRange:[SelectTextManager rangeForItem:item]];
    
    [self.textView addMarks:item.mark.marks];
    
}


-(void)setCellState:(CellState)cellState animated:(BOOL)animated {
    [super setCellState:cellState animated:animated];
    
    
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
    
    [_webpageContainerView _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim) {
        self.textView.backgroundColor = color;
        self.webpageContainerView.descriptionField.backgroundColor = color;
    } else {
        [self.textView pop_addAnimation:anim forKey:@"background"];
        [self.webpageContainerView.descriptionField pop_addAnimation:anim forKey:@"background"];
    }
}



-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    if(!animated) {
        [self.textView setBackgroundColor:selected ? NSColorFromRGB(0xf7f7f7) : NSColorFromRGB(0xffffff)];
    }
}




@end
