//
//  MediaCollectionItemView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 08.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MediaCollectionItemView.h"
#import "MediaCollectionItem.h"
#import "TMPreviewPhotoItem.h"
#import "TMMediaController.h"
#import "HackUtils.h"
#import "TMMediaUserPictureController.h"
#import "TMPreviewCollectionPhotoItem.h"
#import "TMCollectionPageController.h"
@implementation MediaCollectionItemView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
      
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    //
    
    //if(images.count > 0) {
       // [images[0] setFrameSize:newSize];
   // }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL isInside = [self mouse:mouseLoc inRect:[self bounds]];
    
    if(isInside) {        
        TMPreviewCollectionPhotoItem *previewItem = [[TMPreviewCollectionPhotoItem alloc] initWithItem:_item.previewObject];
        
        NSArray *images = [HackUtils findElementsByClass:@"MediaImageView" inView:self];
        
        _item.previewObject.reservedObject = images[0];
        
        
        [[TMMediaController controller] show:previewItem];
       
    }
}


@end
