//
//  TGBottomTextAttachment.m
//  Telegram
//
//  Created by keepcoder on 14/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomTextAttachment.h"
#import "TGBottomSignals.h"
#import "MessageReplyContainer.h"
#import "TGAnimationBlockDelegate.h"
#import "TGWebpageAttach.h"
#import "TGForwardContainer.h"
@interface TGBottomTextAttachment ()
@end

@implementation TGBottomTextAttachment

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        //self.backgroundColor = [NSColor redColor];
    }
    
    return self;
}

-(SSignal *)resignal:(TL_conversation *)conversation animateSignal:(SSignal *)animateSignal template:(TGInputMessageTemplate *)template {
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        return [[TGBottomSignals textAttachment:conversation template:template] startWithNext:^(id next) {
            
            
            TMView *currentView = nil;

            __block BOOL animated = NO;
            
            [animateSignal startWithNext:^(id next) {
                animated = [next boolValue];
            }];
            
            
            if(self.subviews.count > 0) {
                
                TMView *view = [self.subviews lastObject];
                
                if([view isKindOfClass:[MessageReplyContainer class]] && [next isKindOfClass:[TGReplyObject class]]) {
                    
                    MessageReplyContainer *replyContainer = (MessageReplyContainer *)view;
                    
                    if(replyContainer.replyObject.replyMessage.channelMsgId == template.replyMessage.n_id) {
                        [subscriber putNext:@(view ? NSHeight(self.frame) : 0)];
                        
                        return;
                    }
                    
                } else if([view isKindOfClass:[TGForwardContainer class]] && [next isKindOfClass:[TGForwardObject class]]) {
                    
                } else if([view isKindOfClass:[TGWebpageAttach class]] && [next isKindOfClass:[TLWebPage class]]) {
                    TGWebpageAttach *webpage = (TGWebpageAttach *)view;
                    
                    if(webpage.webpage.n_id == [(TLWebPage *)next n_id]) {
                        [subscriber putNext:@(view ? NSHeight(self.frame) : 0)];
                        
                        return;
                    }
                }

                if(next) {
                    [self removeAllSubviews];
                }
                
            }
            
            if([next isKindOfClass:[TGReplyObject class]]) { // reply
                
                
                MessageReplyContainer *replyContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect(0, 0 , NSWidth(self.frame), ((TGReplyObject *)next).containerHeight)];
                
                replyContainer.deleteHandler = ^{
                    
                    if(template.type == TGInputMessageTemplateTypeSimpleText) {
                        [template setReplyMessage:nil save:YES];
                        [template performNotification];
                    } else {
                        [template setEditMessage:nil];
                        [template saveForce];
                        [template performNotification:YES];
                    }
                    
                };
                
                [replyContainer setReplyObject:next];
                
                
                currentView = replyContainer;
                
            } else if([next isKindOfClass:[TGForwardObject class]]) { // forward
                
                TGForwardContainer *container = [[TGForwardContainer alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 30)];
                
                [container setDeleteHandler:^{
                    [template setForwardMessages:nil];
                    [template performNotification];
                }];
                
                [container setFwdObject:next];
                
                
                currentView = container;
                
            } else if([next isKindOfClass:[TL_webPage class]] || [next isKindOfClass:[TL_webPagePending class]]) { // webpage
                TGWebpageAttach *webpage = [[TGWebpageAttach alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 30) webpage:next link:template.webpage inputTemplate:template];
               
                currentView = webpage;
                
            }
            
            if(currentView) {
                
                [self setFrameSize:NSMakeSize(NSWidth(self.frame), NSHeight(currentView.frame) + 10)];
                
                currentView.backgroundColor = self.backgroundColor;
                currentView.autoresizingMask = NSViewWidthSizable;
                
                [currentView setCenteredYByView:self];
                
                [self addSubview:currentView positioned:NSWindowBelow relativeTo:[self.subviews lastObject]];
                
                if(animated) {
                    CABasicAnimation *animation = (CABasicAnimation *) [TMAnimations fadeWithDuration:0.2 fromValue:0.0 toValue:1.0f];
                   
                    [currentView.layer addAnimation:animation forKey:@"opacity"];
                }
                
                
            }
            
            
            [subscriber putNext:@(currentView ? NSHeight(self.frame) : 0)];
            
        }];
        
    }];
    
    
    
    return nil;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}


@end
