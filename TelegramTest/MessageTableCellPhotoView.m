//
//  MessageTableCellPhotoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellPhotoView.h"
#import "TMMediaController.h"
#import "AppDelegate.h"
#import "TMCircularProgress.h"
#import "ImageUtils.h"
@interface MessageTableCellPhotoView()
@end

@implementation MessageTableCellPhotoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        self.imageView = [[BluredPhotoImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [self.imageView setWantsLayer:YES];
        [self.imageView setRoundSize:4];
        [self.imageView setBorderColor:NSColorFromRGB(0xf3f3f3)];
        [self.imageView setBorderWidth:1];

        [self.imageView setTapBlock:^{
            PreviewObject *object = [[PreviewObject alloc] initWithMsdId:weakSelf.item.message.n_id media:weakSelf.item.message peer_id:weakSelf.item.message.peer_id];
            TMPreviewPhotoItem *item = [[TMPreviewPhotoItem alloc] initWithItem:object];
            if(item) {
                [[TMMediaController controller] show:item];
            }
        }];
        
        
        //Progress
        [self setProgressFrameSize:image_CancelDownload().size];
        [self setProgressToView:self.imageView];

        [self setProgressStyle:TMCircularProgressDarkStyle];
        [self.containerView addSubview:self.imageView];
    }
    return self;
}

-(void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    if(cellState == CellStateSending) {
         [self.imageView setIsAlwaysBlur:YES];
    }
    
    if(cellState == CellStateNormal) {
         [self.imageView setIsAlwaysBlur:NO];
    }
}

- (void) setItem:(MessageTableItemPhoto *)item {
    [super setItem:item];
//    
    [self.imageView setFrameSize:item.blockSize];
    
    
    self.imageView.object = item.imageObject;
    
    
    NSSize progressSize = self.progressView.cancelImage.size;
    
    if(item.blockSize.height < 50) {
        progressSize = NSMakeSize(item.blockSize.height-12, item.blockSize.height-12);
    }
    
    
    [self updateCellState];
    
    [self setProgressFrameSize:progressSize];
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    const int borderOffset = self.imageView.borderWidth;
    const int borderSize = borderOffset*2;
    
    NSRect rect = NSMakeRect(self.containerView.frame.origin.x-borderOffset, self.containerView.frame.origin.y-borderOffset, NSWidth(self.imageView.frame)+borderSize, NSHeight(self.containerView.frame)+borderSize);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.imageView.roundSize yRadius:self.imageView.roundSize];
    [path addClip];
    
    
    [self.imageView.borderColor set];
    NSRectFill(rect);
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    
    NSPoint eventLocation = [self.imageView convertPoint: [theEvent locationInWindow] fromView: nil];
   
    if([self.imageView hitTest:eventLocation]) {
        NSPoint dragPosition = NSMakePoint(80, 8);
        
        NSString *path = locationFilePath(((MessageTableItemPhoto *)self.item).photoLocation,@"tiff");
        
        
        NSPasteboard *pasteBrd=[NSPasteboard pasteboardWithName:TGImagePType];
        
        
        [pasteBrd declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,nil] owner:self];
        
        
        NSImage *dragImage = [self.imageView.image copy];
        
        dragImage = [ImageUtils imageResize:dragImage newSize:self.imageView.frame.size];
        
        
        [pasteBrd setData:[self.imageView.image TIFFRepresentation] forType:NSTIFFPboardType];
        
        [pasteBrd setPropertyList:@[path] forType:NSFilenamesPboardType];
        
        [pasteBrd setString:path forType:NSStringPboardType];
        
        [self dragImage:dragImage at:dragPosition offset:NSZeroSize event:theEvent pasteboard:pasteBrd source:self slideBack:NO];
    }
    
}

@end
