//
//  TGBottomSignals.m
//  Telegram
//
//  Created by keepcoder on 13/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomSignals.h"
#import "TGWebpageAttach.h"
#import "TGForwardObject.h"
#import "TGReplyObject.h"
@implementation TGBottomSignals


+(SSignal *)actions:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    
    SSignal *inlineSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        [subscriber putNext:@(actionType == TGModernSendControlInlineRequestType)];
        
        return nil;
    }];
    
    return [SSignal combineSignals:@[[self silentModeSignal:conversation actionType:actionType],[self botCommandSignal:conversation actionType:actionType],[self botKeyboardSignal:conversation actionType:actionType],[self scretTimerSignal:conversation actionType:actionType],[self emojiSignal:conversation actionType:actionType],inlineSignal]];
}

+(SSignal *)botKeyboardSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[self botKeyboardSignal:conversation] map:^id(id next) {
        return @(next != nil && actionType != TGModernSendControlInlineRequestType && actionType != TGModernSendControlEditType);
    }];
}

+(SSignal *)botCommandSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [subscriber putNext:@(NO)];

        return nil;
        
    }];
}

+(SSignal *)silentModeSignal:(TL_conversation *)conversation actionType:(TGModernSendControlType)actionType {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        if(actionType == TGModernSendControlSendType || actionType == TGModernSendControlEditType)
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
        //actionType == TGModernSendControlSendType || actionType == TGModernSendControlRecordType || actionType == TGModernSendControlInlineRequestType || actionType == TGModernSendControlInlineRequestType
        [subscriber putNext:@(YES)];
        
        [subscriber putCompletion];
        
        return nil;
        
    }];
    
}

+(SSignal *)botKeyboardSignal:(TL_conversation *)conversation {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        
        __block TL_localMessage *keyboard;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
            
            keyboard = [transaction objectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
            
        }];
        
        [subscriber putNext:keyboard];
        
        
        return nil;
    }];
}

+(SSignal *)textAttachment:(TL_conversation *)conversation template:(TGInputMessageTemplate *)template {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        //priority - webpage - forward - reply
        
        
        id <SDisposable> disposable = [[SBlockDisposable alloc] initWithBlock:^{
            
        }];
        
        dispatch_block_t others = ^{
            if(template.forwardMessages.count > 0) {
                
                [subscriber putNext:[[TGForwardObject alloc] initWithMessages:template.forwardMessages]];
                
            } else if(template.replyMessage) {
                [subscriber putNext:[[TGReplyObject alloc] initWithReplyMessage:template.replyMessage fromMessage:nil tableItem:nil]];
            } else if(template.editMessage) {
                [subscriber putNext:[[TGReplyObject alloc] initWithReplyMessage:template.editMessage fromMessage:nil tableItem:nil editMessage:YES]];
            } else  {
                [subscriber putNext:nil];
            }
        };
        
        if(template.webpage && !template.noWebpage && conversation.type != DialogTypeSecretChat) {
            
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
