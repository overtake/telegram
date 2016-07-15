//
//  TGBottomSignals.m
//  Telegram
//
//  Created by keepcoder on 13/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomSignals.h"
#import "TGWebpageAttach.h"
@implementation TGBottomSignals


+(SSignal *)actions:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [SSignal combineSignals:@[[self silentModeSignal:conversation actionType:actionType],[self botCommandSignal:conversation actionType:actionType],[self botKeyboardSignal:conversation actionType:actionType],[self scretTimerSignal:conversation actionType:actionType],[self emojiSignal:conversation actionType:actionType]]];
}

+(SSignal *)botKeyboardSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [subscriber putNext:@(NO)];
        [subscriber putCompletion];
        return nil;
        
    }];
}

+(SSignal *)botCommandSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(NO)];

        [subscriber putCompletion];
        return nil;
        
    }];
}

+(SSignal *)silentModeSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        if(actionType != TGModernSendControlRecordType)
            [subscriber putNext:@(NO)];
        else
            [subscriber putNext:@(conversation.type == DialogTypeChannel && !conversation.chat.isMegagroup)];
        
        [subscriber putCompletion];
        
        return nil;
        
    }];
}

+(SSignal *)scretTimerSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(conversation.type == DialogTypeSecretChat)];
        [subscriber putCompletion];
        
        return nil;
        
    }];
}

+(SSignal *)emojiSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(actionType == TGModernSendControlSendType || actionType == TGModernSendControlRecordType)];
        
        [subscriber putCompletion];
        
        return nil;
        
    }];
    
}

+(SSignal *)textAttachment:(TL_conversation *)conversation  {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        //priority - webpage - forward - reply
        
        TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:conversation.peer_id];
        
        id <SDisposable> disposable = [[SBlockDisposable alloc] initWithBlock:^{
            
        }];
        
        dispatch_block_t others = ^{
            if(template.forwardMessages.count > 0) {
                
                [subscriber putNext:template.forwardMessages];
                
            } else if(template.replyMessage) {
                [subscriber putNext:template.replyMessage];
            } else {
                [subscriber putNext:nil];
            }
        };
        
        if(template.webpage && !template.noWebpage) {
            
            disposable = [[self webpageSignal:template.webpage] startWithNext:^(id next) {
                
                if(![next isKindOfClass:[TL_webPageEmpty class]]) {
                    [subscriber putNext:next];
                } else {
                    others();
                }
                
                
            }];
            
        } else
            others();
        
        
        return disposable;
        
    }];
}

+(SSignal *)webpageSignal:(NSString *)link {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        __block TLWebPage *localWebpage =  [Storage findWebpage:display_url(link)];
        id <SDisposable> d;
        

        if(!localWebpage) {
            
            SSignal *requestSignal = [[MTNetwork instance] requestSignal:[TLAPI_messages_getWebPagePreview createWithMessage:link]];
            
            d = [requestSignal startWithNext:^(TL_messageMediaWebPage *response) {
                
                if(!localWebpage || (localWebpage.class != response.webpage.class || localWebpage.n_id != response.webpage.n_id)) {
                    if([response isKindOfClass:[TL_messageMediaWebPage class]]) {
                        
                        [Storage addWebpage:response.webpage forLink:display_url(link)];
                        
                        [subscriber putNext:response.webpage];
                    } else {
                        [Storage addWebpage:[TL_webPageEmpty createWithN_id:0] forLink:display_url(link)];
                        [subscriber putNext:[TL_webPageEmpty createWithN_id:0]];
                    }
  
                }
                
            }];
            
        } else {
            [subscriber putNext:localWebpage];
        }
        
            
        return [[SBlockDisposable alloc] initWithBlock:^{
            
            [d dispose];
            
        }];
        
    }];
}

@end
