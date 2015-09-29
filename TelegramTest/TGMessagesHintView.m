//
//  TGMessagesHintView.m
//  Telegram
//
//  Created by keepcoder on 29.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMessagesHintView.h"


@interface TGMessagesHintRowItem : TMRowItem

@end

@interface TGMessagesHintRowView : TMRowView

@end



@implementation TGMessagesHintRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
    }
    
    return self;
}

@end


@implementation TGMessagesHintRowView



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

@end



@interface TGMessagesHintView () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGMessagesHintView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return 40;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [_tableView cacheViewForClass:[TGMessagesHintRowView class] identifier:NSStringFromClass([TGMessagesHintRowView class]) withSize:NSMakeSize(NSWidth(self.frame), 40)];
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _tableView = [[TMTableView alloc] initWithFrame:self.bounds];
        
        _tableView.tm_delegate = self;
        
        [self addSubview:_tableView.containerView];
        
    }
    
    return self;
}




-(void)showCommandsHintsWithChat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler  {
    
}

-(void)showHashtagHitsWithQuery:(NSString *)query choiceHandler:(void (^)(NSString *result))choiceHandler {
    
}
-(void)showMentionPopupWithChat:(TLChat *)chat choiceHandler:(void (^)(NSString *result))choiceHandler {
    
}

+(void)selectNext {
    
}
+(void)selectPrev {
    
}

@end
