//
//  TGModalSetCaptionView.m
//  Telegram
//
//  Created by keepcoder on 23.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModalSetCaptionView.h"
#import "TGImageAttachment.h"

@interface TGAttachCaptionRowItem : TMRowItem
@property (nonatomic,strong) TGImageAttachment *attach;
@end

@interface TGAttachCaptionRowView : TMRowView

@end



@implementation TGAttachCaptionRowItem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _attach = object;
    }
    
    return self;
}

-(NSUInteger)hash {
    return _attach.item.unique_id;
}

@end


@implementation TGAttachCaptionRowView


-(void)redrawRow {
    
    TGAttachCaptionRowItem *item = (TGAttachCaptionRowItem *) [self rowItem];
    
    [self removeAllSubviews];
    
    [self addSubview:item.attach];
}

@end

@interface TGModalSetCaptionView ()<TMTableViewDelegate>
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMView *backgroundView;

@property (nonatomic,strong) BTRImageView *imageView;
@property (nonatomic,strong) TMTextView *textView;

@property (nonatomic,strong) TMView *textViewBorder;

@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,strong) TMTableView *tableView;

@end

@implementation TGModalSetCaptionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backgroundColor = [NSColor clearColor];
        
        _backgroundView = [[TMView alloc] initWithFrame:self.bounds];
        
        _backgroundView.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.8);
        
        [self addSubview:_backgroundView];
        
        
        _containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 350, 250)];
        
        _containerView.backgroundColor = [NSColor whiteColor];
        
        [_containerView setCenterByView:self];
        
        _containerView.wantsLayer = YES;
        _containerView.layer.cornerRadius = 4;
        
        [self addSubview:_containerView];
        
    
        
        _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(5, 5, NSWidth(_containerView.frame) - 10, NSHeight(_containerView.frame) - 10)];
        
        [_containerView addSubview:_tableView.containerView];
        
        _tableView.tm_delegate = self;
        
    }
    
    return self;
}


-(void)prepareWithAttachment:(TGAttachObject *)attachment {
    
    
    
}

-(void)prepareAttachmentViews:(NSArray *)attachments {
    
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:attachments.count];
    
    [attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [items addObject:[[TGAttachCaptionRowItem alloc] initWithObject:obj]];
        
    }];
    
    
    [self.tableView removeAllItems:YES];
    
    [self.tableView insert:items startIndex:0 tableRedraw:YES];
    
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return 70;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self.tableView cacheViewForClass:[TGAttachCaptionRowView class] identifier:@"TGAttachCaptionRowView" withSize:NSMakeSize(NSWidth(_tableView.frame), 70)];
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

@end
