//
//  TMView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef BOOL (^passlockCallback)(BOOL result,NSString * md5Hash);

enum {
    TMViewBorderTop = (1 << 0),
    TMViewBorderBottom = (1 << 1),
    TMViewBorderLeft = (1 << 2),
    TMViewBorderRight = (1 << 3)
};

typedef NSUInteger TMViewBorder;

@interface TMView : NSView
@property (nonatomic, copy) dispatch_block_t drawBlock;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic) BOOL isDrawn;

@property (nonatomic,assign) NSSize minSize;

@property (nonatomic,copy) dispatch_block_t callback;

@property (nonatomic,assign,getter=flipper) BOOL isFlipped;

@property (nonatomic,assign) BOOL movableWindow;

@property (nonatomic,assign) BOOL dragInSuperView;


- (void)sizeToFit;

-(void)removeAllSubviews;
@end
