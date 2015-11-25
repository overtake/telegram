//
//  MessageTableCellServiceMessage.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/1/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellServiceMessage.h"
#import "NS(Attributed)String+Geometrics.h"
#import "TMMediaController.h"
#import "TGImageView.h"
#import "TGPhotoViewer.h"
#import "TGCTextView.h"
@interface MessageTableCellServiceMessage()

@property (nonatomic, strong) TGCTextView *textField;
@property (nonatomic, strong) TGImageView *photoImageView;
@end

@implementation MessageTableCellServiceMessage

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[TGCTextView alloc] initWithFrame:NSMakeRect(0, 10, 0, 0)];
        
      //  [self.textField setEditable:YES];
        
        [self addSubview:self.textField];
        
        self.photoImageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 60, 60)];
        
        self.photoImageView.layer.cornerRadius = 30;
        self.photoImageView.wantsLayer = YES;
        [self addSubview:self.photoImageView];
        
        self.wantsLayer = YES;
                
        weak();
        
        [self.photoImageView setTapBlock:^ {
            PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:weakSelf.item.message.n_id media:[weakSelf.item.message.action.photo.sizes lastObject] peer_id:weakSelf.item.message.peer_id];
            
            preview.reservedObject = weakSelf.photoImageView.image;
            
            [[TGPhotoViewer viewer] show:preview];
        }];
        
    }
    return self;
}

-(NSArray *)defaultMenuItems {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if(self.item.message.to_id.class == [TL_peerChat class] || self.item.message.to_id.class == [TL_peerUser class])  {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Reply", nil) withBlock:^(id sender) {
            
            [self.messagesViewController addReplayMessage:self.item.message animated:YES];
            
        }]];
    }
    
    [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Delete", nil) withBlock:^(id sender) {
        
        [self.messagesViewController setState:MessagesViewControllerStateNone];
        [self.messagesViewController unSelectAll:NO];
        
        [self.messagesViewController setSelectedMessage:self.item selected:YES];
        
        [self.messagesViewController deleteSelectedMessages];
        
        
    }]];
    
    return items;
    
}

- (void) setItem:(MessageTableItemServiceMessage *)item {
    [super setItem:item];
    
    [self setHidden:item.viewSize.height == 1];

    if(item.type == MessageTableItemServiceMessageAction) {
        [self.textField setAttributedString:item.messageAttributedString];
        [self.textField setFrameSize:item.textSize];
        
    
        [self.textField setFrameOrigin:NSMakePoint(roundf((NSWidth(self.messagesViewController.view.frame) - item.textSize.width) / 2),   (item.photoSize.height ? (item.photoSize.height + 5) : roundf((item.viewSize.height - NSHeight(_textField.frame))/2)))];
                
        if(item.photo) {
            
            [self.photoImageView setFrameSize:item.photoSize];
            self.photoImageView.object = item.imageObject;
            
            [self.photoImageView setHidden:NO];
            [self.photoImageView setFrameOrigin:NSMakePoint(roundf((NSWidth(self.messagesViewController.view.frame) - _photoImageView.frame.size.width) / 2), 0)];
            
        } else {
            [self.photoImageView setHidden:YES];
        }
    } else if(item.type == MessagetableitemServiceMessageDescription) {
        [self.photoImageView setHidden:YES];
        [self.textField setFrameSize:item.textSize];
        [self.textField setAttributedString:item.messageAttributedString];
       
        [self.textField setFrameOrigin:NSMakePoint(78, 0)];
        [_textField setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), roundf((item.viewSize.height - NSHeight(_textField.frame))/2))];
        
    } else  {
        [self.photoImageView setHidden:YES];
        [self.textField setAttributedString:item.messageAttributedString];
        [self.textField setFrameSize:item.textSize];
        [_textField setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), roundf((item.viewSize.height - NSHeight(_textField.frame))/2))];
    }
    
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(NSMenu *)contextMenu {
    return nil;
}

@end
