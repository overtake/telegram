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
    if(self = [super init]) {
        
        _item = item;
        _fromMessage = fromMessage;
        _replyMessage = replyMessage;
        
        assert(_fromMessage != nil || _replyMessage != nil);
        
        _containerHeight = 15+18;
        
        if(_replyMessage != nil)
            [self updateObject];
        else
            [self loadReplyMessage];
        
        
        
    }
    
    return self;
}

-(void)updateObject {
    
    if([_replyMessage isKindOfClass:[TL_localEmptyMessage class]]) {
        _item.replyObject = nil;
        return;
    }
    
    NSColor *nameColor = LINK_COLOR;
    
    NSString *name = _replyMessage.from_id == 0 ? _replyMessage.chat.title : _replyMessage.fromUser.fullName;
    
    
    NSMutableAttributedString *replyHeader = [[NSMutableAttributedString alloc] init];
    
    [replyHeader appendString:name withColor:nameColor];
    
    [replyHeader setFont:TGSystemMediumFont(13) forRange:replyHeader.range];
    
  //  [replyHeader addAttribute:NSLinkAttributeName value:[TMInAppLinks peerProfile:_replyMessage.fwd_from_id != nil ? _replyMessage.fwd_from_id : [TL_peerUser createWithUser_id:_replyMessage.from_id]] range:replyHeader.range];
    
    _replyHeader = replyHeader;
    
    
    NSMutableAttributedString *replyText = [[NSMutableAttributedString alloc] init];
    
    if((_replyMessage.media == nil || [_replyMessage.media isKindOfClass:[TL_messageMediaEmpty class]]) || [_replyMessage.media isKindOfClass:[TL_messageMediaWebPage class]]) {
        
        if(![_replyMessage isKindOfClass:[TL_localMessageService class]]) {
            [replyText appendString:[[_replyMessage.message stringByReplacingOccurrencesOfString:@"\n" withString:@" "] fixEmoji] withColor:TEXT_COLOR];
        } else {
            [replyText appendString:[MessagesUtils serviceMessage:_replyMessage forAction:_replyMessage.action] withColor:GRAY_TEXT_COLOR];
        }
        
        
        
    } else {
        [replyText appendString:[[[MessagesUtils mediaMessage:_replyMessage] stringByReplacingOccurrencesOfString:@"\n" withString:@" "] fixEmoji] withColor:GRAY_TEXT_COLOR];
    }
    
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [replyText addAttribute:NSParagraphStyleAttributeName value:style range:replyText.range];
    
    [replyText setFont:TGSystemFont(13) forRange:replyText.range];
    
    _replyText = replyText;
    
    _replyHeight = [_replyText coreTextSizeForTextFieldForWidth:INT32_MAX].height;
    
    
    _replyHeaderHeight = [replyHeader sizeForTextFieldForWidth:INT32_MAX].height;
    
    _containerHeight = 15 + _replyHeight;
    
    
    
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
        
        _replyThumb.imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), _containerHeight-2);
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaDocument class]]) {
        
        if(![_replyMessage.media.document isSticker]) {
            
            if(_replyMessage.media.document.thumb && ![_replyMessage.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                
                NSImage *thumb;
                
                if(_replyMessage.media.document.thumb.bytes) {
                    thumb = [[NSImage alloc] initWithData:_replyMessage.media.document.thumb.bytes];
                    thumb = renderedImage(thumb, strongsize(NSMakeSize(_replyMessage.media.document.thumb.w, _replyMessage.media.document.thumb.h), _containerHeight-2));
                }
                
                _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? _replyMessage.media.document.thumb.location : nil placeHolder:thumb];
                
                _replyThumb.imageSize = strongsize(NSMakeSize(_replyMessage.media.document.thumb.w, _replyMessage.media.document.thumb.h), _containerHeight-2);
                
            }
            
        }
    }
    
    
    
  
}


-(void)loadReplyMessage {
    
    id request = [TLAPI_messages_getMessages createWithN_id:[@[@(_fromMessage.reply_to_msg_id)] mutableCopy]];
    
    if([_fromMessage.to_id isKindOfClass:[TL_peerChannel class]]) {
        
        
        request = [TLAPI_channels_getMessages createWithChannel:[TL_inputChannel createWithChannel_id:_fromMessage.chat.n_id access_hash:_fromMessage.chat.access_hash] n_id:[@[@(_fromMessage.reply_to_msg_id)] mutableCopy]];
    }
    
    [RPCRequest sendRequest:request successHandler:^(id request, TL_messages_messages *response) {
        
        
        if(response.messages.count == 1 ) {
            
            
            
            NSMutableArray *messages = [response.messages mutableCopy];
            [[response messages] removeAllObjects];
            
            
            [TL_localMessage convertReceivedMessages:messages];
            
            
            if([messages[0] isKindOfClass:[TL_messageEmpty class]]) {
                messages[0] = [TL_localEmptyMessage createWithN_Id:[(TL_messageEmpty *)messages[0] n_id] to_id:_fromMessage.to_id];
            }
            
            [SharedManager proccessGlobalResponse:response];
            
            [[Storage manager] addSupportMessages:messages];
            [MessagesManager addSupportMessages:messages];
            
            
            _replyMessage = messages[0];
            _fromMessage.replyMessage = _replyMessage;
            [self updateObject];
            
            if(_item != nil) {
                [Notification perform:UPDATE_MESSAGE_ITEM data:@{@"item":_item}];
            }

        }
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        
    }];
}

-(void)dealloc {
    [_request cancelRequest];
    _request = nil;
}

@end
