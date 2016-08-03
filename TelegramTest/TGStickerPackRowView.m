//
//  TGStickerPackRowView.m
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGStickerPackRowView.h"
#import "TGImageView.h"
#import "TGStickerPackRowItem.h"
#import "TGMovableTableView.h"
@implementation TGStickerPackRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        
        
        _titleField = [TMTextField defaultTextField];
        
        [[_titleField cell] setTruncatesLastVisibleLine:YES];
        
        [self addSubview:_titleField];
        
        _imageContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        
        [self addSubview:_imageContainerView];
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        
        [_imageContainerView addSubview:_imageView];
        
        weak();
        
        _deletePack = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ModernMenuDeleteIcon().size.width, image_ModernMenuDeleteIcon().size.height)];
        [_deletePack setImage:image_ModernMenuDeleteIcon() forControlState:BTRControlStateNormal];
        
        [_deletePack addBlock:^(BTRControlEvents events) {
            [weakSelf.controller removeStickerPack:(TGStickerPackRowItem *)[weakSelf rowItem]];
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:_deletePack];
        
        _reorderPack = imageViewWithImage(image_AudioPlayerList());
        
        [self addSubview:_reorderPack];
        
        
        _separator = [[TMView alloc] initWithFrame:NSMakeRect(30, 0, NSWidth(frameRect) - 60, DIALOG_BORDER_WIDTH)];
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        [self addSubview:_separator];
        
    }
    
    return self;
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    TGMovableTableView *tableView = ((TGMovableTableView *)[self rowItem].table);
    
    if([self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:NSMakeRect(NSMinX(_separator.frame), 0, NSWidth(self.frame) - NSMinX(_separator.frame), NSHeight(self.frame))] && [[self rowItem] isEditable]) {
        [tableView startMoveItemAtIndex:[tableView indexOfObject:[self rowItem]]];
    } else {
        if(![[self rowItem] isEditable] && [tableView isKindOfClass:[TGMovableTableView class]]) {
            [tableView.mdelegate selectionDidChange:[tableView indexOfObject:[self rowItem]] item:[self rowItem]];
        }
    }
}

-(void)redrawRow {
    [super redrawRow];
    
    TGStickerPackRowItem *item = (TGStickerPackRowItem *) [self rowItem];
    
    [_titleField setAttributedStringValue:item.title];
    
    [_titleField sizeToFit];
    
    [_titleField setCenterByView:self];
    
    [_imageView setFrameSize:item.imageObject.imageSize];
    _imageView.object = item.imageObject;
    
    
    //(item.set.flags & (1 << 2)) == (1 << 2)
    [_deletePack setHidden:NO];
    
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_titleField setFrameOrigin:NSMakePoint(80, 8)];
    [_titleField setFrameSize:NSMakeSize(newSize.width - 140, NSHeight(_titleField.frame))];
    [_deletePack setCenteredYByView:_deletePack.superview];
    [_reorderPack setCenteredYByView:_deletePack.superview];
    [_imageContainerView setCenteredYByView:_imageContainerView.superview];
    [self updatePositionAnimated:NO];
    
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
    self.rowItem.editable = editable;
    
    [self updatePositionAnimated:animated];
}


-(void)updatePositionAnimated:(BOOL)animated {
    
    TMRowItem *item = [self rowItem];
    
    id deleteView = animated ? [_deletePack animator] : _deletePack;
    id titleView = animated ?[_titleField animator] : _titleField;
    id imageView = animated ? [_imageContainerView animator] : _imageContainerView;
    id separatorView = animated ? [_separator animator] : _separator;
    id reoderView = animated ? [_reorderPack animator] : _reorderPack;
    
    int defImageX = roundf((30 -NSWidth(_imageContainerView.frame))/2) + 30;
    
    
    int defTitleX = item.isEditable ? 80  + NSWidth(_deletePack.frame) - 2: 80-2;
    
    [deleteView setFrameOrigin:NSMakePoint(item.isEditable ? 10 : - NSWidth(_deletePack.frame), NSMinY(_deletePack.frame))];
    [titleView setFrameOrigin:NSMakePoint(defTitleX , NSMinY(_titleField.frame))];
    [imageView setFrameOrigin:NSMakePoint(item.isEditable ? defImageX + NSWidth(_deletePack.frame)  : defImageX, NSMinY(_imageContainerView.frame))];
    
    [_reorderPack setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 30 - NSWidth(_reorderPack.frame), roundf((NSHeight(self.frame) - NSHeight(_reorderPack.frame))/2))];
    
    [reoderView setAlphaValue:item.isEditable ? 1 : 0];
    [deleteView setAlphaValue:item.isEditable ? 1 : 0];
    
    [separatorView setFrame:NSMakeRect(defTitleX, 0, NSWidth(self.frame) - defTitleX - 30, DIALOG_BORDER_WIDTH)];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    [_separator setHidden:self.dragInSuperView];
    
}

@end

