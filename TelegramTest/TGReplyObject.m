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
    NSColor *nameColor = LINK_COLOR;
    
    NSString *name = [_replyMessage.to_id isKindOfClass:[TL_peerChannel class]] ? _replyMessage.chat.title : _replyMessage.fromUser.fullName;
    
    NSMutableAttributedString *replyHeader = [[NSMutableAttributedString alloc] init];
    
    [replyHeader appendString:name withColor:nameColor];
    
    [replyHeader setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:replyHeader.range];
    
    [replyHeader addAttribute:NSLinkAttributeName value:[TMInAppLinks peerProfile:_replyMessage.fwd_from_id != nil ? _replyMessage.fwd_from_id : [TL_peerUser createWithUser_id:_replyMessage.from_id]] range:replyHeader.range];
    
    _replyHeader = replyHeader;
    
    
    NSMutableAttributedString *replyText = [[NSMutableAttributedString alloc] init];
    
    if((_replyMessage.media == nil || [_replyMessage.media isKindOfClass:[TL_messageMediaEmpty class]]) || [_replyMessage.media isKindOfClass:[TL_messageMediaWebPage class]]) {
        
        NSString *str = [_replyMessage.message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        
        [replyText appendString:[str fixEmoji] withColor:TEXT_COLOR];
        
    } else {
        [replyText appendString:[[MessagesUtils mediaMessage:_replyMessage] fixEmoji] withColor:GRAY_TEXT_COLOR];
    }
    
    
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
        
        
        
        _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? photoSize.location : nil placeHolder:thumb];
        
        _replyThumb.imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), 30);
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaGeo class]]) {
        
        //  _geoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true",replyMessage.media.geo.lat, replyMessage.media.geo.n_long, @"30x30"]];
        
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaVideo class]]) {
        
        TLPhotoSize *photoSize = _replyMessage.media.video.thumb;
        
        NSImage *thumb;
        if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
            thumb = [[NSImage alloc] initWithData:photoSize.bytes];
        }
        
        
        
        _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? photoSize.location : nil placeHolder:thumb];
        
        _replyThumb.imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), 30);
        
    }
    
    if([_replyMessage.media isKindOfClass:[TL_messageMediaDocument class]]) {
        
        if(![_replyMessage.media.document isSticker]) {
            
            if(_replyMessage.media.document.thumb && ![_replyMessage.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                
                NSImage *thumb;
                
                if(_replyMessage.media.document.thumb.bytes) {
                    thumb = [[NSImage alloc] initWithData:_replyMessage.media.document.thumb.bytes];
                    thumb = renderedImage(thumb, strongsize(NSMakeSize(_replyMessage.media.document.thumb.w, _replyMessage.media.document.thumb.h), 30));
                }
                
                _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? _replyMessage.media.document.thumb.location : nil placeHolder:thumb];
                
                _replyThumb.imageSize = strongsize(NSMakeSize(_replyMessage.media.document.thumb.w, _replyMessage.media.document.thumb.h), 30);
                
            }
            
        }
    }
    
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [replyText addAttribute:NSParagraphStyleAttributeName value:style range:replyText.range];
    
    [replyText setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:replyText.range];
    
    _replyText = replyText;
    
    
    _replyHeight = [_replyText coreTextSizeForTextFieldForWidth:INT32_MAX].height;
    
    _containerHeight = 15 + _replyHeight;
}


-(void)loadReplyMessage {
    
    id request = [TLAPI_messages_getMessages createWithN_id:[@[@(_fromMessage.reply_to_msg_id)] mutableCopy]];
    
    if([_fromMessage.to_id isKindOfClass:[TL_peerChannel class]]) {
        
        
        request = [TLAPI_messages_getChannelMessages createWithPeer:[TL_inputPeerChannel createWithChannel_id:_fromMessage.chat.n_id access_hash:_fromMessage.chat.access_hash] n_id:[@[@(_fromMessage.reply_to_msg_id)] mutableCopy]];
    }
    
    [RPCRequest sendRequest:request successHandler:^(id request, TL_messages_messages *response) {
        
        
        if(response.messages.count == 1 && ![response.messages[0] isKindOfClass:[TL_messageEmpty class]]) {
            
            NSMutableArray *messages = [response.messages mutableCopy];
            [[response messages] removeAllObjects];
            
            
            [TL_localMessage convertReceivedMessages:messages];
            [SharedManager proccessGlobalResponse:response];
            
            [[Storage manager] addSupportMessages:messages];
            [MessagesManager addSupportMessages:messages];
            
            
            _replyMessage = messages[0];
            
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
