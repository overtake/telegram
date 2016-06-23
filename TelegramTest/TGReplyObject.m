//
//  TGReplyObject.m
//  Telegram
//
//  Created by keepcoder on 11.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGReplyObject.h"
#import "MessagesUtils.h"
#import "NSString+Extended.h"
#import "MessageTableItem.h"
#import "TGArticleImageObject.h"
@interface TGReplyObject ()
@property (nonatomic,strong) RPCRequest *request;
@end

@implementation TGReplyObject

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item {
    return [self initWithReplyMessage:replyMessage fromMessage:fromMessage tableItem:item withoutCache:NO];
}

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item editMessage:(BOOL)editMessage {
    return [self initWithReplyMessage:replyMessage fromMessage:fromMessage tableItem:item withoutCache:YES pinnedMessage:NO editMessage:editMessage];
}

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item pinnedMessage:(BOOL)pinnedMessage {
    return [self initWithReplyMessage:replyMessage fromMessage:fromMessage tableItem:item withoutCache:YES pinnedMessage:pinnedMessage editMessage:NO];
}

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item withoutCache:(BOOL)withoutCache  {
    return [self initWithReplyMessage:replyMessage fromMessage:fromMessage tableItem:item withoutCache:withoutCache pinnedMessage:NO editMessage:NO];
}

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage fromMessage:(TL_localMessage *)fromMessage tableItem:(MessageTableItem *)item withoutCache:(BOOL)withoutCache pinnedMessage:(BOOL)pinnedMessage editMessage:(BOOL)editMessage {
    if(self = [super init]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            replyCache = [[NSCache alloc] init];
            [replyCache setCountLimit:150];
        });
        
        if(replyMessage != nil && !withoutCache) {
            TGReplyObject *cObj = [replyCache objectForKey:@(replyMessage.channelMsgId)];
            if(cObj)
                return cObj;
        }
        
        _pinnedMessage = pinnedMessage;
        _editMessage = editMessage;
        
        _item = item;
        _fromMessage = fromMessage;
        _replyMessage = replyMessage;
        
        _containerHeight = 33;
        
        if(_replyMessage != nil) {
            [self updateObject];
        }  else
            [TGReplyObject loadReplyMessage:_fromMessage completionHandler:^(TL_localMessage *message) {
                _replyMessage = message;
                _fromMessage.replyMessage = _replyMessage;
                [self updateObject];
                
                [replyCache setObject:self forKey:@(_replyMessage.channelMsgId)];
                
                if(_item != nil) {
                    [Notification perform:UPDATE_EDITED_MESSAGE data:@{KEY_MESSAGE:_fromMessage,@"nonselect":@"YES"}];
                }
            }];
        
    }
    
    return self;
}

static NSCache *replyCache;




-(void)updateObject {
    
    if([_replyMessage isKindOfClass:[TL_localEmptyMessage class]]) {
        _item.replyObject = nil;
        return;
    }
    
    NSColor *nameColor = LINK_COLOR;
    
    NSString *name = self.isPinnedMessage ? NSLocalizedString(@"PinnedHeaderMessage", nil) : self.isEditMessage ? NSLocalizedString(@"EditHeaderMessage", nil) : (_replyMessage.isPost ? _replyMessage.chat.title : _replyMessage.fromUser.fullName);
    
    
    NSMutableAttributedString *replyHeader = [[NSMutableAttributedString alloc] init];
    
    [replyHeader appendString:name withColor:nameColor];
    
    [replyHeader setFont:TGSystemMediumFont(12.5) forRange:replyHeader.range];
    
  //  [replyHeader addAttribute:NSLinkAttributeName value:[TMInAppLinks peerProfile:_replyMessage.fwd_from_id != nil ? _replyMessage.fwd_from_id : [TL_peerUser createWithUser_id:_replyMessage.from_id]] range:replyHeader.range];
    
    _replyHeader = replyHeader;
    
    
    NSMutableAttributedString *replyText = [[NSMutableAttributedString alloc] init];
    
    if((_replyMessage.media == nil || [_replyMessage.media isKindOfClass:[TL_messageMediaEmpty class]]) || [_replyMessage.media isKindOfClass:[TL_messageMediaWebPage class]]) {
        
        if(![_replyMessage isKindOfClass:[TL_localMessageService class]]) {
            [replyText appendString:[[[_replyMessage.message stringByReplacingOccurrencesOfString:@"\n" withString:@" "] fixEmoji] trim] withColor:TEXT_COLOR];
        } else {
            [replyText appendString:[MessagesUtils serviceMessage:_replyMessage forAction:_replyMessage.action] withColor:GRAY_TEXT_COLOR];
        }
        
    } else {
        if(self.isPinnedMessage) {
            NSString *caption = _replyMessage.media.caption;
            _replyMessage.media.caption = @"";
            [replyText appendString:[[[MessagesUtils mediaMessage:_replyMessage] stringByReplacingOccurrencesOfString:@"\n" withString:@" "] fixEmoji] withColor:GRAY_TEXT_COLOR];
            _replyMessage.media.caption = caption;
        } else
            [replyText appendString:[[[MessagesUtils mediaMessage:_replyMessage] stringByReplacingOccurrencesOfString:@"\n" withString:@" "] fixEmoji] withColor:GRAY_TEXT_COLOR];
    }
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [replyText addAttribute:NSParagraphStyleAttributeName value:style range:replyText.range];
    
    [replyText setFont:TGSystemFont(12.5) forRange:replyText.range];
    
    _replyText = replyText;
    
    _replyHeight = [_replyText coreTextSizeOneLineForWidth:INT32_MAX].height;
    
    _replyHeaderHeight = [replyHeader coreTextSizeOneLineForWidth:INT32_MAX].height;
    
    _containerHeight = _replyHeaderHeight + _replyHeight + 2;
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        
        NSImage *thumb;
        
        TLPhoto *photo = _replyMessage.media.photo;
        
        
        for(TLPhotoSize *photoSize in photo.sizes) {
            if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                thumb = [[NSImage alloc] initWithData:photoSize.bytes];
                break;
            }
        }
        
        TLPhotoSize *photoSize = photo.sizes[0];
        
        _replyThumb = [[TGArticleImageObject alloc] initWithLocation:!thumb ? photoSize.location : nil placeHolder:thumb];
        
        _replyThumb.imageSize = NSMakeSize(_containerHeight-2, _containerHeight-2);
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaGeo class]]) {
        
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaVideo class]]) {
        
        TLPhotoSize *photoSize = _replyMessage.media.video.thumb;
        
        NSImage *thumb;
        if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
            thumb = [[NSImage alloc] initWithData:photoSize.bytes];
        }
        
        
        
        _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? photoSize.location : nil placeHolder:thumb];
        
        
        _replyThumb.imageSize = NSMakeSize(_containerHeight-2, _containerHeight-2);
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaDocument class]] || [_replyMessage.media isKindOfClass:[TL_messageMediaDocument_old44 class]]) {
        
        if(![_replyMessage.media.document isSticker]) {
            
            if(_replyMessage.media.document.thumb && ![_replyMessage.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                
                NSImage *thumb;
                
                if(_replyMessage.media.document.thumb.bytes) {
                    thumb = [[NSImage alloc] initWithData:_replyMessage.media.document.thumb.bytes];
                    thumb = cropCenterWithSize(thumb, NSMakeSize(_containerHeight-2, _containerHeight-2));
                }
                
                _replyThumb = [[TGArticleImageObject alloc] initWithLocation:!thumb ? _replyMessage.media.document.thumb.location : nil placeHolder:thumb];
                
                _replyThumb.imageSize = NSMakeSize(_containerHeight-2, _containerHeight-2);
                
            }
            
        }
    }

     [replyCache setObject:self forKey:@(_replyMessage.channelMsgId)];
  
}


+(void)loadReplyMessage:(TL_localMessage *)fromMessage completionHandler:(void (^)(TL_localMessage *message))completionHandler {
    
    
    [[Storage manager] messages:^(NSArray *result) {
        
        if(result.count == 1) {
            [[Storage manager] addSupportMessages:result];
            
            if(completionHandler)
                completionHandler(result[0]);
            
        } else if (![fromMessage isKindOfClass:[TL_destructMessage class]]) {
            id request = [TLAPI_messages_getMessages createWithN_id:[@[@(fromMessage.reply_to_msg_id)] mutableCopy]];
            
            if([fromMessage.to_id isKindOfClass:[TL_peerChannel class]]) {
                
                
                request = [TLAPI_channels_getMessages createWithChannel:[TL_inputChannel createWithChannel_id:fromMessage.chat.n_id access_hash:fromMessage.chat.access_hash] n_id:[@[@(fromMessage.reply_to_msg_id)] mutableCopy]];
            }
            
            [RPCRequest sendRequest:request successHandler:^(id request, TL_messages_messages *response) {
                
                
                if(response.messages.count == 1 ) {
                    
                    NSMutableArray *messages = [response.messages mutableCopy];
                    [[response messages] removeAllObjects];
                    
                    
                    [TL_localMessage convertReceivedMessages:messages];
                    
                    if([messages[0] isKindOfClass:[TL_messageEmpty class]]) {
                        messages[0] = [TL_localEmptyMessage createWithN_Id:[(TL_messageEmpty *)messages[0] n_id] to_id:fromMessage.to_id];
                    }
                    
                    [SharedManager proccessGlobalResponse:response];
                    
                    [[Storage manager] addSupportMessages:messages];
                    
                    if(completionHandler)
                        completionHandler(messages[0]);
                }
                
                
            } errorHandler:^(id request, RpcError *error) {
                
                
            } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        }
        
    } forIds:@[@([fromMessage isKindOfClass:[TL_destructMessage class]] ? ((TL_destructMessage *)fromMessage).reply_to_random_id : ([fromMessage.to_id isKindOfClass:[TL_peerChannel class]] ? channelMsgId(fromMessage.reply_to_msg_id, fromMessage.peer_id) : fromMessage.reply_to_msg_id))] random:[fromMessage isKindOfClass:[TL_destructMessage class]] sync:NO queue:[ASQueue globalQueue] isChannel:[fromMessage.to_id isKindOfClass:[TL_peerChannel class]]];
    
}


-(void)dealloc {
    [_request cancelRequest];
    _request = nil;
}

@end
