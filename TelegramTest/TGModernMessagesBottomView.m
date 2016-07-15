//
//  TGModernMessagesBottomView.m
//  Telegram
//
//  Created by keepcoder on 11/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessagesBottomView.h"
#import "TGModernGrowingTextView.h"
#import "TGModernSendControlView.h"
#import "TGModernBottomAttachView.h"
#import "TGBottomActionsView.h"
#import "TGBottomTextAttachment.h"


@interface TGModernMessagesBottomView () <TGModernGrowingDelegate> {
    TMView *_ts;
    
}

//requests
@property (nonatomic,strong) id<SDisposable> attachDispose;;

@property (nonatomic,weak) MessagesViewController *messagesController;

@property (nonatomic,strong) TGModernGrowingTextView *textView;
@property (nonatomic,strong) TGModernSendControlView *sendControlView;
@property (nonatomic,strong) TGModernBottomAttachView *attachView;
@property (nonatomic,strong) TGBottomActionsView *actionsView;

@property (nonatomic,strong) TGBottomTextAttachment *attachment;


@property (nonatomic,strong) TMView *attachmentsContainerView;
@property (nonatomic,strong) TMView *textContainerView;

@property (nonatomic,assign) int attachmentsHeight;



@end

@implementation TGModernMessagesBottomView

- (void)drawRect:(NSRect)dirtyRect {
}
const float defYOffset = 12;

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        
        _attachmentsHeight = -1;
        
        _animates = YES;
        self.wantsLayer = YES;
        
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        self.autoresizingMask = NSViewWidthSizable;
        
        _attachmentsContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect), NSWidth(frameRect), 50)];
        _attachmentsContainerView.wantsLayer = YES;
        //_attachmentsContainerView.layer.backgroundColor = [NSColor redColor].CGColor;
        [self addSubview:_attachmentsContainerView];
        
        _textContainerView = [[TMView alloc] initWithFrame:self.bounds];
        _textContainerView.wantsLayer = YES;
        [self addSubview:_textContainerView];
        
        _messagesController = messagesController;

        
        _ts = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - DIALOG_BORDER_WIDTH, NSWidth(frameRect), DIALOG_BORDER_WIDTH)];
        _ts.wantsLayer = YES;
        _ts.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self addSubview:_ts];
        
        _attachment = [[TGBottomTextAttachment alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_textContainerView.frame), 50)];
        [_attachmentsContainerView addSubview:_attachment];
       
        
        _sendControlView = [[TGModernSendControlView alloc] initWithFrame:NSMakeRect(NSWidth(_textContainerView.frame) - 60, 0, 60, NSHeight(_textContainerView.frame))];
        _sendControlView.wantsLayer = YES;
        
        
        _attachView = [[TGModernBottomAttachView alloc] initWithFrame:NSMakeRect(0, 0, 60, NSHeight(_textContainerView.frame)) messagesController:messagesController];
        _attachView.wantsLayer = YES;
        
        
        _actionsView = [[TGBottomActionsView alloc] initWithFrame:NSMakeRect(0, 0, 0, NSHeight(_textContainerView.frame)) messagesController:messagesController];
        _actionsView.wantsLayer = YES;
        
        
        _textView = [[TGModernGrowingTextView alloc] initWithFrame:NSMakeRect(NSWidth(_attachView.frame) , defYOffset, NSWidth(_textContainerView.frame)  - NSWidth(_attachView.frame) - NSWidth(_sendControlView.frame), NSHeight(_textContainerView.frame) - defYOffset*2)];
        _textView.delegate = self;
        
        [_textContainerView addSubview:_attachView];
        [_textContainerView addSubview:_textView];
        [_textContainerView addSubview:_actionsView];
        [_textContainerView addSubview:_sendControlView];
//        _sendControlView.backgroundColor = [NSColor greenColor];
//        _actionsView.backgroundColor = [NSColor yellowColor];
//        _attachView.backgroundColor = [NSColor orangeColor];
        
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textContainerView setFrameSize:NSMakeSize(newSize.width, NSHeight(_textContainerView.frame))];
    [_attachmentsContainerView setFrameSize:NSMakeSize(newSize.width - NSMaxX(_attachView.frame) - 20, NSHeight(_attachmentsContainerView.frame))];
    [_attachment setFrameSize:NSMakeSize(NSWidth(_attachmentsContainerView.frame), NSHeight(_attachment.frame))];
    [_ts setFrameSize:NSMakeSize(newSize.width, NSHeight(_ts.frame))];
}

-(void)performSendMessage {
    
    [_messagesController sendMessage:_textView.string];

    [_sendControlView performSendAnimation];
    
}


-(void)resignalActions {
    [[_actionsView resignal:_sendControlView.type] startWithNext:^(id next) {
        
        if([next boolValue]) {
            [self updateTextViewSize];
            
            
            if(_actionsView.animates) {
                
                
                CABasicAnimation *pAnim = [CABasicAnimation animationWithKeyPath:@"position"];
                pAnim.duration = 0.2;
                pAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                pAnim.removedOnCompletion = YES;
                [pAnim setValue:@(CALayerPositionAnimation) forKey:@"type"];
                
                
                float presentX = NSMaxX(self.textView.frame);
                
                CALayer *presentLayer = (CALayer *)[_actionsView.layer presentationLayer];
                
                if(presentLayer && [_actionsView.layer animationForKey:@"position"]) {
                    presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
                }
                
                pAnim.fromValue = [NSValue valueWithPoint:NSMakePoint(presentX, NSMinY(_actionsView.frame))];
                pAnim.toValue = [NSValue valueWithPoint:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width , NSMinY(_actionsView.frame))];
                
                
                CABasicAnimation *oAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                oAnim.duration = 0.2;
                oAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                oAnim.removedOnCompletion = YES;
                [oAnim setValue:@(CALayerOpacityAnimation) forKey:@"type"];
                
                
                oAnim.fromValue = @(0.0f);
                oAnim.toValue = @(1.0f);
                
                [_actionsView.layer removeAnimationForKey:@"position"];
                
                [_actionsView.layer addAnimation:pAnim forKey:@"position"];
                [_actionsView.layer addAnimation:oAnim forKey:@"opacity"];
                
                [_actionsView.layer setOpacity:1.0f];
                [_actionsView.layer setPosition:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, self.defTextViewHeight - NSHeight(_actionsView.frame))];
                
                [_actionsView.animator setFrameOrigin:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, NSMinY(_actionsView.frame))];
                
                
            }
            [_actionsView setFrameOrigin:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, NSMinY(_actionsView.frame))];

        }
        
    }];
}

-(int)defTextViewHeight {
    int height = _textView.height % 2 == 1 ? _textView.height + 1 : _textView.height;
    
    height += NSMinY(_textView.frame) * 2;
    
    return height;
}

-(NSSize)textViewSize {
    return NSMakeSize(NSWidth(_textContainerView.frame) - NSWidth(_attachView.frame) - NSWidth(_sendControlView.frame) - NSWidth(_actionsView.frame) , NSHeight(_textView.frame));
}

-(void)updateTextViewSize {
    [_textView.animates ? [_textView animator] : _textView setFrameSize:self.textViewSize];
}


- (void) textViewHeightChanged:(id)textView height:(int)height animated:(BOOL)animated {
    
    
    height = self.defTextViewHeight;
    
    
    
    NSSize layoutSize = NSMakeSize(NSWidth(self.frame), _attachmentsHeight > 0 ? height + _attachmentsHeight : height);
    
    [CATransaction begin];
    if(animated) {
        float presentHeight = NSHeight(self.frame);
        
        CALayer *presentLayer = (CALayer *)[self.layer presentationLayer];
        
        if(presentLayer && [self.layer animationForKey:@"bounds"]) {
            presentHeight = [[presentLayer valueForKeyPath:@"bounds.size.height"] floatValue];
        }
        
        CABasicAnimation *sAnim = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        sAnim.duration = 0.2;
        sAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        sAnim.removedOnCompletion = YES;
        
        sAnim.fromValue = @(presentHeight);
        sAnim.toValue = @(layoutSize.height);
        
        [self.layer removeAnimationForKey:@"bounds"];
        [self.layer addAnimation:sAnim forKey:@"bounds"];
        
        [self.layer setFrame:NSMakeRect(0, 0, NSWidth(self.frame), layoutSize.height)];
        
        
        presentHeight = NSHeight(_textContainerView.frame);
        
        presentLayer = (CALayer *)[_textContainerView.layer presentationLayer];
        
        if(presentLayer && [_textContainerView.layer animationForKey:@"bounds"]) {
            presentHeight = [[presentLayer valueForKeyPath:@"bounds.size.height"] floatValue];
        }
        
        sAnim = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        sAnim.duration = 0.2;
        sAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        sAnim.removedOnCompletion = YES;
        
        sAnim.fromValue = @(presentHeight);
        sAnim.toValue = @(height);
        
        [_textContainerView.layer removeAnimationForKey:@"bounds"];
        [_textContainerView.layer addAnimation:sAnim forKey:@"bounds"];
        
        [_textContainerView.layer setFrame:NSMakeRect(0, 0, NSWidth(self.frame), height)];
        
        
        
        float presentY = NSMinY(_ts.frame);
        
        presentLayer = (CALayer *)[_ts.layer presentationLayer];
        
        if(presentLayer && [_ts.layer animationForKey:@"position"]) {
            presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
        }
        
        CABasicAnimation *pAttachAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(NSMinX(_ts.frame), presentY) toValue:NSMakePoint(NSMinX(_ts.frame),layoutSize.height - NSHeight(_ts.frame))];
        
        [_ts.layer removeAnimationForKey:@"position"];
        [_ts.layer addAnimation:pAttachAnim forKey:@"position"];
        
        [_ts.layer setPosition:[pAttachAnim.toValue pointValue]];
        
        
        
        presentY = NSMinY(_attachmentsContainerView.frame);
        
        presentLayer = (CALayer *)[_attachmentsContainerView.layer presentationLayer];
        
        if(presentLayer && [_attachmentsContainerView.layer animationForKey:@"position"]) {
            presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
        }
        
        pAttachAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(NSMinX(_attachmentsContainerView.frame), presentY) toValue:NSMakePoint(NSMinX(_attachmentsContainerView.frame),layoutSize.height - NSHeight(_attachmentsContainerView.frame) -  defYOffset/2.0f)];
        
        [_attachmentsContainerView.layer removeAnimationForKey:@"position"];
        [_attachmentsContainerView.layer addAnimation:pAttachAnim forKey:@"position"];
        
        [_attachmentsContainerView.layer setPosition:[pAttachAnim.toValue pointValue]];
        
    }
    
    [CATransaction commit];
    
    [self animateControls:height animated:animated];
    
    [_textContainerView setFrame:NSMakeRect(0, 0, NSWidth(self.frame), height)];
    [self setFrame:NSMakeRect(0, 0, NSWidth(self.frame), layoutSize.height)];
    [_ts setFrameOrigin:NSMakePoint(NSMinX(_ts.frame),layoutSize.height - NSHeight(_ts.frame))];
    
    [_attachmentsContainerView setFrameOrigin:NSMakePoint(NSMaxX(_attachView.frame),layoutSize.height - NSHeight(_attachmentsContainerView.frame) - defYOffset/2.0f)];
    
    
    [_messagesController bottomViewChangeSize:layoutSize.height animated:animated];
    
    
}


-(void)animateControls:(int)height animated:(BOOL)animated {
    
    
    if(animated) {
        float presentY = NSMinY(_attachView.frame);
        
        CALayer *presentLayer = (CALayer *)[_attachView.layer presentationLayer];
        
        if(presentLayer && [_attachView.layer animationForKey:@"position"]) {
            presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
        }
        
        CABasicAnimation *pAttachAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(NSMinX(_attachView.frame), presentY) toValue:NSMakePoint(NSMinX(_attachView.frame),height - NSHeight(_attachView.frame))];
        
        [_attachView.layer removeAnimationForKey:@"position"];
        [_attachView.layer addAnimation:pAttachAnim forKey:@"position"];
        
        [_attachView.layer setPosition:[pAttachAnim.toValue pointValue]];
        
        
        presentY = NSMinY(_sendControlView.frame);
        
        presentLayer = (CALayer *)[_sendControlView.layer presentationLayer];
        
        if(presentLayer && [_sendControlView.layer animationForKey:@"position"]) {
            presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
        }
        
        CABasicAnimation *pSendAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(NSMinX(_sendControlView.frame), presentY) toValue:NSMakePoint(NSMinX(_sendControlView.frame),height - NSHeight(_sendControlView.frame))];
        
        
        [_sendControlView.layer removeAnimationForKey:@"position"];
        [_sendControlView.layer addAnimation:pSendAnim forKey:@"position"];
        
        [_sendControlView.layer setPosition:[pSendAnim.toValue pointValue]];
        
        
        
        presentY = NSMinY(_actionsView.frame);
        float presentX = NSMinX(_actionsView.frame);
        presentLayer = (CALayer *)[_actionsView.layer presentationLayer];
        
        if(presentLayer && [_actionsView.layer animationForKey:@"position"]) {
            presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
            presentX = [[presentLayer valueForKeyPath:@"frame.origin.x"] floatValue];
        }
        
        CABasicAnimation *pActionsAnim = [TMAnimations postionWithDuration:0.2 fromValue:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width, presentY) toValue:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width,height - NSHeight(_actionsView.frame))];
        
        [_actionsView.layer removeAnimationForKey:@"position"];
        [_actionsView.layer addAnimation:pActionsAnim forKey:@"position"];
        
        [_actionsView.layer setPosition:[pActionsAnim.toValue pointValue]];
    }
    [_actionsView setFrameOrigin:NSMakePoint(NSMinX(_textView.frame) + self.textViewSize.width,height - NSHeight(_actionsView.frame))];
    [_sendControlView setFrameOrigin:NSMakePoint(NSMinX(_sendControlView.frame),height - NSHeight(_sendControlView.frame))];
    [_attachView setFrameOrigin:NSMakePoint(NSMinX(_attachView.frame),height - NSHeight(_attachView.frame))];
   
    
}

- (BOOL) textViewEnterPressed:(TGModernGrowingTextView *)textView {
    
    [self performSendMessage];
    
    return YES;
}

- (void) textViewTextDidChange:(TGModernGrowingTextView *)textView {
    [_sendControlView setType:textView.string.length > 0 ? TGModernSendControlSendType : TGModernSendControlRecordType];
    
    [self saveInputText];
    
    [_messagesController recommendStickers];
    
    [self resignalActions];
}


-(void)saveInputText {
    [[_inputTemplate updateSignalText:_textView.string] startWithNext:^(NSArray *next){
        
        if(next.count == 2) {
            
            if([next[1] boolValue]) {
                [self resignalTextAttachments];
            }
            
        }
        
    }];
}


-(void)setAnimates:(BOOL)animates {
    _animates = animates;
    _textView.animates = animates;
    _actionsView.animates = animates;
    _sendControlView.animates = animates;
}

-(void)setInputTemplate:(TGInputMessageTemplate *)inputTemplate animated:(BOOL)animated {
    _inputTemplate = inputTemplate;
    
    
    BOOL oa = _animates;
    
    
    self.animates = animated;
    
    
    
    
    [self resignalTextAttachments];
    
    [_textView setString:inputTemplate.text];
    
    
    
    if(inputTemplate.type == TGInputMessageTemplateTypeSimpleText) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:_messagesController.conversation.chat.isChannel ? NSLocalizedString(@"Message.SendBroadcast", nil) : NSLocalizedString(@"Message.SendPlaceholder", nil) withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(15) forRange:attr.range];
        
        [_textView setPlaceholderAttributedString:attr];
    }
    
    self.animates = oa;
    
}


-(void)resignalTextAttachments {
    
    [_attachDispose dispose];
    
    _attachDispose = [[_attachment resignal:_messagesController.conversation animateSignal:[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(self.animates)];
        
        return nil;
        
    }]] startWithNext:^(id next) {
        
        if(_attachmentsHeight != [next intValue]) {
            _attachmentsHeight = [next intValue];
            
            if(_animates) {
                CAAnimation *animation = [TMAnimations fadeWithDuration:0.2 fromValue:_attachmentsHeight > 0  ? 0.0f : 1.0f toValue:_attachmentsHeight > 0  ? 1.0f : 0.0f];
                
                [_attachmentsContainerView.layer addAnimation:animation forKey:@"opacity"];
                
            }
            
            _attachmentsContainerView.layer.opacity = _attachmentsHeight > 0 ? 1.0f : 0.0f;
            
            [self textViewHeightChanged:_textView height:NSHeight(_textView.frame) animated:_animates];
        }
        
    }];
}

@end
