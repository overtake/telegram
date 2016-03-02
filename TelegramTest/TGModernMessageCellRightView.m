//
//  TGModernMessageCellRightView.m
//  Telegram
//
//  Created by keepcoder on 24/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessageCellRightView.h"
#import "TGTextLabel.h"
#import "MessageStateLayer.h"
#import "POPLayerExtras.h"
@interface TGModernMessageCellRightView ()
@property (nonatomic,strong) TGTextLabel *dateLabel;
@property (nonatomic,strong) MessageStateLayer *stateLayer;
@property (nonatomic,strong) NSImageView *selectCheckView;

@property (nonatomic,strong) TMView *containerView;
@end

@implementation TGModernMessageCellRightView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _containerView = [[TMView alloc] initWithFrame:NSZeroRect];
        _containerView.wantsLayer = YES;
        [self addSubview:_containerView];
        
        _dateLabel = [[TGTextLabel alloc] init];
        
        
        [_containerView addSubview:_dateLabel];
        
        
    }
    
    return self;
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    if(self.item.messageSender)
        return;
    
    NSPoint pos = [_containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(NSPointInRect(pos, _dateLabel.frame)) {
        [super mouseDown:nil];
    } else {
        [super mouseDown:theEvent];
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_containerView setFrameSize:newSize];
    
}

-(void)setItem:(MessageTableItem *)item container:(TGModernMessageCellContainerView *)container {
    _item = item;
    _container = container;
    
    if(item.message.n_out || self.item.message.isPost) {
        
        if(!_stateLayer) {
            _stateLayer = [[MessageStateLayer alloc] initWithFrame:NSZeroRect];
            [_containerView addSubview:_stateLayer];
        }
        [_stateLayer setFrameSize:NSMakeSize(NSWidth(self.frame) - item.dateSize.width - item.defaultContentOffset, MAX(item.rightSize.height,item.viewsCountAndSignSize.height))];
        [_stateLayer setContainer:_container];
        [_stateLayer setState:container.actionState];
        
    } else {
        [_stateLayer removeFromSuperview];
        _stateLayer = nil;
    }
    
    [_dateLabel setFrame:NSMakeRect(NSWidth(self.frame) - item.dateSize.width, 0, item.dateSize.width, item.dateSize.height)];
    
    [_dateLabel setText:item.dateAttributedString maxWidth:item.dateSize.width height:item.dateSize.height];
    
    [self setEditable:_container.isEditable animated:NO];
    [self setSelected:item.isSelected animated:NO];
    
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    [self checkAndMakeEditable:editable animated:animated];
    
    
    static float duration = 0.2;
    
    if((!self.visibleRect.size.width && !self.visibleRect.size.height) || !animated) {
        [_containerView setFrame:NSMakeRect(editable ? -(NSWidth(_selectCheckView.frame) + self.item.defaultOffset) : 0, 0, NSWidth(self.frame), _item.dateSize.height)];
        
        [_containerView setCenteredYByView:self];
        [_selectCheckView setFrameOrigin:NSMakePoint( NSWidth(self.frame) - NSWidth(_selectCheckView.frame), 0)];
        
        return;
    }
    
    
    float from = _containerView.layer.frame.origin.x;
    float to =  (editable ? -(NSWidth(_selectCheckView.frame) + self.item.defaultOffset) : 0);
    
    
    POPBasicAnimation *position = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    position.fromValue = @(from);
    position.toValue = @(to);
    position.duration = duration;
    position.removedOnCompletion = YES;
    weak();
    
    [position setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        if(result) {
            [weakSelf setEditable:editable animated:NO];
        }
    }];
    [_containerView.layer pop_addAnimation:position forKey:@"slide"];
    
    
    
    POPBasicAnimation *opacityAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacityAnim.fromValue = @(editable ? 0 : 1);
    opacityAnim.toValue = @(editable ? 1 : 0);
    opacityAnim.duration = duration;
    opacityAnim.removedOnCompletion = YES;
    [opacityAnim setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        
    }];
    [_selectCheckView.layer pop_addAnimation:opacityAnim forKey:@"opacity"];
    
    
    from = NSWidth(self.frame) + NSWidth(_selectCheckView.frame);
    to = NSWidth(self.frame) - NSWidth(_selectCheckView.frame);
    
    
    POPBasicAnimation *slideAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    slideAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    slideAnim.fromValue = @(from);
    slideAnim.toValue = @(to);
    slideAnim.duration = duration;
    slideAnim.removedOnCompletion = YES;
    [slideAnim setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        
    }];
    [_selectCheckView.layer pop_addAnimation:slideAnim forKey:@"slide"];

}

- (void)setSelected:(BOOL)isSelected animated:(BOOL)animated {
    
        
    self.item.isSelected = isSelected;
    
    _selectCheckView.image = isSelected ? image_checked() : image_ComposeCheck();
    
   if(animated) {
        
        if(_selectCheckView.layer.anchorPoint.x != 0.5) {
            CGPoint point = _selectCheckView.layer.position;
            
            point.x += roundf(image_checked().size.width / 2);
            point.y += roundf(image_checked().size.height / 2);
            
            _selectCheckView.layer.position = point;
            
            _selectCheckView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        }
        
        float duration = 0.2;
        float to = 0.8;
        
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
        scaleAnimation.duration = duration / 2;
        scaleAnimation.removedOnCompletion = YES;
        weak();
        
        [scaleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL result) {
            if(result) {
                POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
                scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
                scaleAnimation.duration = duration / 2;
                [weakSelf.selectCheckView.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
            }
        }];
        
        [_selectCheckView.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
       
        
    }
}



-(void)setState:(MessageTableCellState)actionState animated:(BOOL)animated {
    [_stateLayer setState:actionState animated:animated];
}

-(void)checkAndMakeEditable:(BOOL)editable animated:(BOOL)animated {
    if(editable) {
        if(!_selectCheckView) {
            _selectCheckView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_checked().size.width, image_checked().size.height)];
            _selectCheckView.wantsLayer = YES;
            _selectCheckView.image = image_ComposeCheck();
            [self addSubview:_selectCheckView];
        }
    } else {
        [_selectCheckView removeFromSuperview];
        _selectCheckView = nil;
    }
    
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    if(!anim)
        _dateLabel.backgroundColor = color;
     else
         [_dateLabel pop_addAnimation:anim forKey:@"background"];
        
}

@end
