//
//  PhotoTableItemView.m
//  Telegram
//
//  Created by keepcoder on 04.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoTableItemView.h"
#import "TGImageView.h"
#import "TMMediaController.h"
@interface PhotoTableItemView ()
@property (nonatomic,strong) NSMutableArray *images;
@end


@implementation PhotoTableItemView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    self.images = [[NSMutableArray alloc] init];
}

-(void)redrawRow {
    
    
    PhotoTableItem *item = (PhotoTableItem *) [self rowItem];
    
    __block int xOffset = 3;
    
    
    if(self.images.count > item.previewObjects.count) {
        
        NSRange range =  NSMakeRange(item.previewObjects.count, self.images.count-item.previewObjects.count);
        
        [self.images enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(NSImageView *obj, NSUInteger idx, BOOL *stop) {
            
            [obj removeFromSuperview];
            
        }];
        
        
        [self.images removeObjectsInRange:range];
    }
    
    
    [item.previewObjects enumerateObjectsUsingBlock:^(PhotoCollectionImageObject *obj, NSUInteger idx, BOOL *stop) {
        
        PhotoCollectionImageView *imageView;
        
        if(self.images.count > idx) {
            imageView = self.images[idx];
            
        } else {
            imageView = [[PhotoCollectionImageView alloc] initWithFrame:NSZeroRect];
            imageView.controller = (TMCollectionPageController *) self.rowItem.table.viewController;
            [self.images addObject:imageView];
            [self addSubview:imageView];
        }
        
        
        [imageView setFrame:NSMakeRect(xOffset, 2, item.size.width-6, item.size.height-4)];
        
        imageView.object = obj;
        
        
        xOffset+=item.size.width;
        
    }];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
  
}

-(void)dealloc {
    
}


@end
