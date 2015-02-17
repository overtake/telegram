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
@interface MessageTableCellServiceMessage()

@property (nonatomic, strong) TMHyperlinkTextField *textField;
@property (nonatomic, strong) TGImageView *photoImageView;
@end

@implementation MessageTableCellServiceMessage

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(0, 10, 0, 0)];
        [self.textField setEditable:NO];
        [self.textField setSelectable:NO];
        [self.textField setBordered:NO];
        [self.textField setBezeled:NO];
        [self.textField setAutoresizesSubviews:YES];
        [self.textField setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        [self addSubview:self.textField];
        
        self.photoImageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
        [self.photoImageView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        [self.photoImageView setRoundSize:4];
        [self addSubview:self.photoImageView];
        
        weak();
        
        [self.photoImageView setTapBlock:^ {
            PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:weakSelf.item.message.n_id media:[weakSelf.item.message.action.photo.sizes lastObject] peer_id:weakSelf.item.message.peer_id];
            
            preview.reservedObject = weakSelf.photoImageView.image;
            
            [[TGPhotoViewer viewer] show:preview];
        }];
        
    }
    return self;
}


- (void) setItem:(MessageTableItemServiceMessage *)item {
    [super setItem:item];

    if(item.type == MessageTableItemServiceMessageAction) {
        [self.textField setAttributedStringValue:item.messageAttributedString];
        [self.textField setAlignment:NSCenterTextAlignment];
        [self.textField setFrameSize:item.blockSize];
        [self.textField setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - item.blockSize.width) / 2), 8 + (item.photoSize.height ? (item.photoSize.height + 5) : 0))];
        
        
        if(item.photo) {
            [self.photoImageView setHidden:NO];
            [self.photoImageView setFrameOrigin:NSMakePoint(roundf((self.bounds.size.width - item.photoSize.width) / 2), 5)];
            [self.photoImageView setFrameSize:item.photoSize];
            
            
            self.photoImageView.object = item.imageObject;
            
        } else {
            [self.photoImageView setHidden:YES];
        }
    } else {
        [self.photoImageView setHidden:YES];
        [self.textField setAttributedStringValue:item.messageAttributedString];
        [self.textField setFrameSize:item.blockSize];
        [self.textField setFrameOrigin:NSMakePoint(74, 8)];

    }
    
    
}

@end
