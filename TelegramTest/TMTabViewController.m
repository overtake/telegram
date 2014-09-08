//
//  TMLeftTabViewController.m
//  Telegram
//
//  Created by keepcoder on 25.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTabViewController.h"

@interface TMTabViewController ()
@property (nonatomic,assign) NSSize tabViewSize;
@property (nonatomic,strong) NSMutableArray *tabs;
@property (nonatomic,assign) NSSize lastAcceptedSize;

@end

@implementation TMTabViewController


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    
    return self;
}


-(void)initialize {
    self.borderWidth = 1;
    self.tabs = [[NSMutableArray alloc] init];
    self.selectedIndex = 0;
}


-(void)drawRect:(NSRect)dirtyRect {
   
    
    if(self.backgroundColor) {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
    
    if(self.topBorderColor) {
        [self.topBorderColor setFill];
        NSRectFill(NSMakeRect(0, NSHeight(self.frame) - self.borderWidth, NSWidth(self.frame), self.borderWidth));
    }
}


-(void)setBorderWidth:(NSUInteger)borderWidth {
    self->_borderWidth = borderWidth;
    
    [self setNeedsDisplay:YES];
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [self setNeedsDisplay:YES];
}

-(void)setTopBorderColor:(NSColor *)topBorderColor {
    self->_topBorderColor = topBorderColor;

    [self setNeedsDisplay:YES];
}

-(void)setNeedsTabView:(NSSize)size {
    self->_tabViewSize = size;
}


-(void)addTab:(TMTabItem *)tab {
    [self.tabs addObject:tab];
    
    [self redraw];
}

-(void)insertTab:(TMTabItem *)tab atIndex:(NSUInteger)index {
    [self.tabs insertObject:tab atIndex:index];
    
    [self redraw];
}

-(void)removeTab:(TMTabItem *)tab {
    [self.tabs removeObject:tab];
    
    [self redraw];
}

-(void)removeTabAtIndex:(NSUInteger)index {
    [self.tabs removeObjectAtIndex:index];
    
    [self redraw];
}


-(void)redraw {
    int width = NSWidth(self.bounds);
    
    int height = NSHeight(self.bounds);
    
    int defWidth = width/self.tabs.count;
    
//    NSMutableArray *itemsWidth = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < self.tabs.count; i++) {
//        
//        int w = defWidth;
//        
//        if(self.tabs.count >= 3) {
//            
//            if(i == 0 || i == self.tabs.count -1) {
//                w = defWidth+defWidth/3;
//            } else {
//                w = defWidth/2;
//            }
//        }
//        
//        [itemsWidth addObject:@(w)];
//    }

    
    
    NSArray *copyViews = [self.subviews copy];
    
    [copyViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    
    
    
    __block int xOffset = 0;
    
    static const int minY = 5;
    
    
    [self.tabs enumerateObjectsUsingBlock:^(TMTabItem *obj, NSUInteger idx, BOOL *stop) {
        
        int itemWidth = defWidth;
        
        NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(xOffset, 0, itemWidth, height)];
        view.wantsLayer = YES;
        
        
    //    [view.layer setBackgroundColor:NSColorFromRGB(arc4random() % 16777216).CGColor];
        
        NSView *container = [[NSView alloc] initWithFrame:view.bounds];
        [container setWantsLayer:YES];
        
     //   [container.layer setBackgroundColor:NSColorFromRGB(arc4random() % 16777216).CGColor];
        
        [view setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable];
        [view setAutoresizesSubviews:YES];
        
        
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, obj.image.size.width, obj.image.size.height)];
        
        TMTextField *field = [TMTextField defaultTextField];
        
        [field setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        
        [field setAlignment:NSCenterTextAlignment];
        [field setStringValue:obj.title];
        
        [field sizeToFit];
        
        
        
        
        [container addSubview:field];
        
        
        
        imageView.image = obj.image;
        
        
        [container addSubview:imageView];
        
      //  if(idx == 0)
        //    container.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
        
        [container setFrameSize:NSMakeSize(MAX(NSWidth(imageView.frame),NSWidth(field.frame)), NSHeight(container.frame))];
        
        [imageView setCenterByView:container];
        
        [imageView setFrameOrigin:NSMakePoint(imageView.frame.origin.x, imageView.frame.origin.y+minY)];
        
        [field setCenterByView:container];
        
        [field setFrameOrigin:NSMakePoint(field.frame.origin.x, minY)];
        
        [container setCenterByView:view];
        
        
//        if(idx == 0) {
//            [container setFrameOrigin:NSMakePoint(NSMaxX(view.frame) - NSWidth(container.frame), NSMinY(container.frame))];
//        }
//        
//        if(idx == self.tabs.count-1) {
//            [container setFrameOrigin:NSMakePoint(0, NSMinY(container.frame))];
//        }
//        
        
        [view addSubview:container];
        
        [self addSubview:view];
        
        
        xOffset+=itemWidth;
        
    }];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.subviews enumerateObjectsUsingBlock:^(NSView *obj, NSUInteger idx, BOOL *stop) {
        
        NSView *child = obj.subviews[0];
        
        [child setCenterByView:obj];
        
    }];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex {
    
    if(selectedIndex >= self.tabs.count)
        return;
    
    
    TMTabItem *deselectItem = self.tabs[self.selectedIndex];
    
    NSView *deselectView = self.subviews[self.selectedIndex];
    
    
    TMTextField *field = [deselectView.subviews[0] subviews][0];
    
    NSImageView *image = [deselectView.subviews[0] subviews][1];
    
    [image setImage:deselectItem.image];
    
    [field setTextColor:deselectItem.textColor];
    
    self->_selectedIndex = selectedIndex;
    
    
    
    TMTabItem *selectItem = self.tabs[self.selectedIndex];
    
    NSView *selectView = self.subviews[self.selectedIndex];

    
    
    
    field = [selectView.subviews[0] subviews][0];
    image = [selectView.subviews[0] subviews][1];
    
    [image setImage:selectItem.selectedImage];
    
    [field setTextColor:selectItem.selectedTextColor];
    
    [self.delegate tabItemDidChanged:selectItem index:selectedIndex];
}




-(void)mouseDown:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
     [self.subviews enumerateObjectsUsingBlock:^(NSView *obj, NSUInteger idx, BOOL *stop) {
        if([obj hitTest:point]) {
            
            self.selectedIndex = idx;
            
            *stop = YES;
        }
    }];
}

@end
