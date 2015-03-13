//
//  TGReplyObject.m
//  Telegram
//
//  Created by keepcoder on 11.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGReplyObject.h"

@implementation TGReplyObject

-(id)initWithReplyMessage:(TL_localMessage *)replyMessage {
    if(self = [super init]) {
        
        _replyMessage = replyMessage;
        
        NSColor *nameColor = LINK_COLOR;
        
        static NSColor * colors[6];
        static NSMutableDictionary *cacheColorIds;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            colors[0] = NSColorFromRGB(0xce5247);
            colors[1] = NSColorFromRGB(0xcda322);
            colors[2] = NSColorFromRGB(0x5eaf33);
            colors[3] = NSColorFromRGB(0x468ec4);
            colors[4] = NSColorFromRGB(0xac6bc8);
            colors[5] = NSColorFromRGB(0xe28941);
            
            cacheColorIds = [[NSMutableDictionary alloc] init];
        });
        
        
        if(replyMessage.from_id != [UsersManager currentUserId]) {
            
            int colorMask = [TMAvatarImageView colorMask:replyMessage.fromUser];
            
            nameColor = colors[colorMask % (sizeof(colors) / sizeof(colors[0]))];
            
        }
        
        NSString *name = replyMessage.fromUser.fullName;
        
        NSMutableAttributedString *replyHeader = [[NSMutableAttributedString alloc] init];
        
        [replyHeader appendString:name withColor:nameColor];
        
        [replyHeader setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:replyHeader.range];
        
        [replyHeader addAttribute:NSLinkAttributeName value:[TMInAppLinks userProfile:replyMessage.from_id] range:replyHeader.range];
        
        _replyHeader = replyHeader;
        
        
        NSMutableAttributedString *replyText = [[NSMutableAttributedString alloc] init];
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            
            [replyText appendString:replyMessage.message withColor:NSColorFromRGB(0x060606)];
            
        }
        
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaPhoto class]]) {
            
            NSImage *thumb;
            
            TLPhoto *photo = replyMessage.media.photo;
            
            
            for(TLPhotoSize *photoSize in photo.sizes) {
                if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                    thumb = [[NSImage alloc] initWithData:photoSize.bytes];
                    break;
                }
            }
            
            TLPhotoSize *photoSize = photo.sizes[0];
            
            _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? photoSize.location : nil placeHolder:thumb];
            
            [replyText appendString:NSLocalizedString(@"ChatMedia.Photo", nil) withColor:NSColorFromRGB(0x808080)];
            
        }
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaContact class]]) {
            
            [replyText appendString:NSLocalizedString(@"ChatMedia.Contact", nil) withColor:NSColorFromRGB(0x808080)];
            
        }
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaGeo class]]) {
            
            _geoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true",replyMessage.media.geo.lat, replyMessage.media.geo.n_long, @"30x30"]];
            
            [replyText appendString:NSLocalizedString(@"ChatMedia.Location", nil) withColor:NSColorFromRGB(0x808080)];
            
        }
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaUnsupported class]]) {
            
            [replyText appendString:NSLocalizedString(@"ChatMedia.Unsupported", nil) withColor:NSColorFromRGB(0x808080)];
            
        }
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaAudio class]]) {
            
            [replyText appendString:NSLocalizedString(@"ChatMedia.Audio", nil) withColor:NSColorFromRGB(0x808080)];
            
        }
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaVideo class]]) {
            
            TLPhotoSize *photoSize = replyMessage.media.video.thumb;
            
            NSImage *thumb;
            if([photoSize isKindOfClass:[TL_photoCachedSize class]]) {
                thumb = [[NSImage alloc] initWithData:photoSize.bytes];
            }
            
            _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? photoSize.location : nil placeHolder:thumb];
            
            [replyText appendString:NSLocalizedString(@"ChatMedia.Video", nil) withColor:NSColorFromRGB(0x808080)];
            
        }
        
        if([replyMessage.media isKindOfClass:[TL_messageMediaDocument class]]) {
            
            if([replyMessage.media.document isSticker]) {
                
                TL_documentAttributeSticker *sticker = (TL_documentAttributeSticker *)  [replyMessage.media.document attributeWithClass:TL_documentAttributeSticker.class];
               
                NSString *text = NSLocalizedString(@"ChatMedia.Sticker", nil);
                
                if(sticker.alt.length > 0) {
                    text = [NSString stringWithFormat:@"%@ %@",sticker.alt,text];
                }
                
                [replyText appendString:text withColor:NSColorFromRGB(0x808080)];
                
            } else {
                if(replyMessage.media.document.thumb && ![replyMessage.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                    
                    NSImage *thumb;
                    
                    if(replyMessage.media.document.thumb.bytes) {
                        thumb = [[NSImage alloc] initWithData:replyMessage.media.document.thumb.bytes];
                        thumb = renderedImage(thumb, NSMakeSize(30, 30));
                    }
                    
                    _replyThumb = [[TGImageObject alloc] initWithLocation:!thumb ? replyMessage.media.document.thumb.location : nil placeHolder:thumb];
                    
                    self.replyThumb.imageSize = NSMakeSize(30, 30);
                    
                }
                
                
                [replyText appendString:replyMessage.media.document.file_name withColor:NSColorFromRGB(0x808080)];
            }
        }
        
        
        [replyText setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:replyText.range];
        
        _replyText = replyText;
        
    }
    
    return self;
}

@end
