//
//  TGImageAttachmentsController.m
//  Telegram
//
//  Created by keepcoder on 20.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGImageAttachmentsController.h"
#import "TGAnimationBlockDelegate.h"
#import "TGTransformScrollView.h"



@interface TGImageAttachmentsController ()
@property (nonatomic,strong) TGTransformScrollView *scrollView;
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TL_conversation *conversation;
@end

@implementation TGImageAttachmentsController

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backgroundColor = [NSColor redColor];
        
        _scrollView = [[TGTransformScrollView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), NSHeight(self.bounds) )];
        
        _containerView = [[TMView alloc] initWithFrame:self.scrollView.bounds];
        
        _scrollView.documentView = self.containerView;
        
        _scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
        _scrollView.verticalScrollElasticity = NSScrollElasticityNone;
        [self.scrollView setAutoresizesSubviews:YES];
        [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        
        [super addSubview:self.scrollView];
        
        self.autoresizingMask = NSViewWidthSizable;
        
        _scrollView.autoresizingMask = NSViewWidthSizable;
        
        _containerView.backgroundColor = NSColorFromRGB(0xfafafa);
        
        
    }
    
    return self;
}

-(void)show:(TL_conversation *)conversation animated:(BOOL)animated {
    
    
    if(_conversation == conversation) {
        _isShown = _containerView.subviews.count > 0;
        [self setHidden:!_isShown];
        return;
    }
    
    
    _conversation = conversation;
    
    [_containerView removeAllSubviews];
    [self updateContainer];
    
    
    if(conversation)
    {
        
        __block NSMutableArray *attachments;
        
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                        
            attachments = [transaction objectForKey:conversation.cacheKey inCollection:ATTACHMENTS];
            
        }];
        
        _isShown = attachments.count > 0;
        
        [self setHidden:!_isShown];
                
        NSMutableArray *viewItems = [[NSMutableArray alloc] initWithCapacity:attachments.count];
        
        [attachments enumerateObjectsUsingBlock:^(TGAttachObject *obj, NSUInteger idx, BOOL *stop) {
            
            [viewItems addObject:[[TGImageAttachment alloc] initWithItem:obj]];
            
        }];
        
        assert([NSThread isMainThread]);
        
        [self addItems:viewItems animated:NO];
    }
   
    
}



-(void)hide:(BOOL)animated deleteItems:(BOOL)deleteItems {
    
    _isShown = NO;
    
    if(animated)
    {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [[self animator] setAlphaValue:0];
            
        } completionHandler:^{
            if(!_isShown) {
                [_containerView removeAllSubviews];
                [self setHidden:YES];
                
            }
            [self setAlphaValue:1];
        }];
    } else {
        [_containerView removeAllSubviews];
        [self setHidden:YES];
    }
    
    if(deleteItems) {
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            NSMutableArray *attachments = [transaction objectForKey:_conversation.cacheKey inCollection:ATTACHMENTS];
            
            [attachments removeAllObjects];
            
            [transaction setObject:attachments forKey:_conversation.cacheKey inCollection:ATTACHMENTS];
            
        }];
    }

}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if([TMViewController isModalActive])
        return;
    
    [self.delegate didChangeAttachmentsCount:0];
    
    _isShown = NO;
    
    NSArray *items = [self.containerView.subviews copy];
    
    
    [TMViewController showAttachmentCaption:items onClose:^{
        
        [items enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
            
            [obj setDeleteAccept:YES];
            [self addSubview:obj];
        }];
        
        [self updateItemsOrigin];
        
        [self.delegate didChangeAttachmentsCount:(int)items.count];
        
        
    }];
}

-(void)removeItem:(TGImageAttachment *)attachment animated:(BOOL)animated {
    
    
    __block NSMutableArray *attachments;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        attachments = [transaction objectForKey:_conversation.cacheKey inCollection:ATTACHMENTS];
        
        [attachments removeObject:attachment.item];
        
        [transaction setObject:attachments forKey:_conversation.cacheKey inCollection:ATTACHMENTS];
        
    }];
    
    [self.delegate didChangeAttachmentsCount:(int)self.attachments.count - 1];

    
    if(animated) {
        
        NSUInteger idx = [_containerView.subviews indexOfObject:attachment];
        
        if(idx == NSNotFound)
            return;
        
        
        [CATransaction begin];
        
        [self fadeAnimation:@[attachment] from:1 to:0 complete:^(BOOL finished) {
            [attachment removeFromSuperview];
            
            
            [self updateItemsOrigin];
            [self updateContainer];
            
        }];
        
        
        //&&
        
        if(idx == _containerView.subviews.count - 1) {
            
            if(NSWidth(_containerView.frame) > NSWidth(_scrollView.frame)) {
                
                NSRange range = NSMakeRange(0, _containerView.subviews.count - 1);
                
                NSSize nextSize = [self containerSizeWithItems:[_containerView.subviews subarrayWithRange:range]];
                
                int nextX = NSWidth(attachment.frame) + 10;
                
                if(nextSize.width < NSWidth(_scrollView.frame)) {
                    nextX-= ((NSWidth(_scrollView.frame) - nextSize.width) - 10) ;
                }
                
                
                
                [_containerView.subviews enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
                    
                    [self moveAnimation:obj from:obj.frame.origin to:NSMakePoint(obj.frame.origin.x + nextX, NSMinY(obj.frame)) complete:nil];
                    
                }];
                
            }
            
            
        } else {
            
            NSRange range = NSMakeRange(idx, _containerView.subviews.count - idx );
            
            
            if( NSMaxX(_scrollView.clipView.documentVisibleRect) + NSWidth(attachment.frame) > NSWidth(_containerView.frame) && NSWidth(_containerView.frame) > NSWidth(_scrollView.frame)) {
                
                int dif = (NSMaxX(_scrollView.clipView.documentVisibleRect) + NSWidth(attachment.frame)) - NSWidth(_containerView.frame);
                
                
                [self moveAnimation:_containerView from:_containerView.frame.origin to:NSMakePoint(NSMinX(_containerView.frame) + dif, NSMinY(_containerView.frame)) complete:nil];
                
                
            }
            
            [_containerView.subviews enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
                
                [self moveAnimation:obj from:obj.frame.origin to:NSMakePoint(obj.frame.origin.x - NSWidth(attachment.frame) -10, NSMinY(obj.frame)) complete:nil];
                
            }];
            
            
            
        }
        
        [CATransaction commit];
        
    } else {
        [attachment removeFromSuperview];
        [self updateContainer];
    }
    
}

-(NSSize)containerSizeWithItems:(NSArray *)items {
    __block int width = 0;
    
    [items enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
        width+= NSWidth(obj.frame)+10;
    }];
    
    return NSMakeSize(width, NSHeight(_containerView.frame));
}

-(void)updateContainer {
    
     TGImageAttachment *lastAttach = [_containerView.subviews lastObject];
    
     [_containerView setFrameSize:NSMakeSize(MAX(NSMaxX(lastAttach.frame) + 10, NSWidth(_scrollView.frame)), NSHeight(_containerView.frame))];
}

-(void)updateItemsOrigin {
    
    [_containerView.subviews enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
        
        TGImageAttachment *prev;
        
        if(idx != 0) {
            prev = _containerView.subviews[idx -1];
        }
        
        [obj setFrameOrigin:NSMakePoint(NSMaxX(prev.frame) + 10, 1)];
        
    }];
    
}

-(void)addSubview:(NSView *)aView {
    
    if([aView isKindOfClass:[TGImageAttachment class]])
        [_containerView addSubview:aView];
}

-(NSArray *)attachments {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    
    [_containerView.subviews enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
        
        [a insertObject:obj.item atIndex:0];
        
    }];
    
    return a;
}


-(void)addItems:(NSArray *)items animated:(BOOL)animated {
    
    int futureCount = (int)self.attachments.count + (int)items.count;
    
    if(!_isShown && futureCount > 0) {
        [self setHidden:NO];
        _isShown = YES;
    }
    
    [self.delegate didChangeAttachmentsCount:futureCount];
    
    
    
    
    [items enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
        
        
        [obj setController:self];
        [obj loadImage];
        
        TGImageAttachment *lastAttach = [_containerView.subviews lastObject];
        
        
        [obj setFrameOrigin:NSMakePoint(NSMaxX(lastAttach.frame) + 10, 1)];
        
        [obj setDeleteAccept:YES];
        
        [_containerView addSubview:obj];
        
        [self updateContainer];
        
        
        [_scrollView.clipView scrollRectToVisible:NSMakeRect(NSWidth(_containerView.frame), 0, 0, 0) animated:animated completion:^(BOOL scrolled) {
        }];
        
    }];
    
    
    
    
    
    if(animated)
        [self fadeAnimation:items from:0 to:1 complete:nil];
}

-(void)fadeAnimation:(NSArray *)items from:(float)from to:(float)to complete:(void (^)(BOOL finished))completion {
    [CATransaction begin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = @(to);
    animation.fromValue = @(from);
    animation.duration = 0.2;
    
    
    [items enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
        
        if(idx == items.count - 1) {
            TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:obj.layer];
            
            [delegate setCompletion:^(BOOL success) {
                
                if(completion != nil)
                {
                    completion(success);
                }
                
            }];
            
            animation.delegate = delegate;
        }
        
        
        [obj.layer addAnimation:animation forKey:@"opacity"];
        
        obj.layer.opacity = to;
        
        
    }];
    
    [CATransaction commit];
}

-(void)moveAnimation:(TMView *)attachment from:(NSPoint)from to:(NSPoint)to complete:(void (^)(BOOL finished))completion {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    NSValue *fromValue = [NSValue value:&from withObjCType:@encode(CGPoint)];
    NSValue *toValue = [NSValue value:&to withObjCType:@encode(CGPoint)];
    
    animation.toValue = toValue;
    animation.fromValue = fromValue;
    animation.duration = 0.2;
    
    TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:attachment.layer];
        
    [delegate setCompletion:^(BOOL success) {
        
        if(completion != nil)
        {
            completion(success);
        }
            
    }];
    
    [attachment setFrameOrigin:to];
    
    animation.delegate = delegate;
    
    [attachment.layer setFrameOrigin:to];
    
    [attachment.layer addAnimation:animation forKey:@"position"];
}





@end
