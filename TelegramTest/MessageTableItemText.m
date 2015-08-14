//
//  MessageTableItemText.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemText.h"
#import "TMElements.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessagesUtils.h"
#import "NSAttributedString+Hyperlink.h"
#import "NSString+Extended.h"
#import "TGWebpageYTObject.h"
#define MAX_WIDTH 400

@interface MessageTableItemText()<SettingsListener>
@property (nonatomic, strong) NSMutableAttributedString *nameAttritutedString;
@property (nonatomic, strong) NSMutableAttributedString *forwardAttributedString;
@property (nonatomic,strong) id requestKey;


@end

@implementation MessageTableItemText

- (id) initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    
    self.textAttributed = [[NSMutableAttributedString alloc] init];
    
    NSString *message = [[object.message trim] fixEmoji];
    
    
    [self.textAttributed appendString:message withColor:TEXT_COLOR];
    
    [self.textAttributed setAlignment:NSLeftTextAlignment range:self.textAttributed.range];
    
    [self updateEntities];
    
    [SettingsArchiver addEventListener:self];
    
    
    
    [self updateWebPage];
    
    
  //  [self makeSizeByWidth:280];
    
    return self;
}


-(void)updateLinkAttributesByMessageEntities {
    
    [self.textAttributed removeAttribute:NSLinkAttributeName range:self.textAttributed.range];
    
    _links = [[NSArray alloc] init];
    
    NSMutableArray *links = [NSMutableArray array];
    
    if(self.message.entities.count > 0)
    {
        
        [self.message.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
            
            if([obj isKindOfClass:[TL_messageEntityUrl class]] ||[obj isKindOfClass:[TL_messageEntityTextUrl class]] || [obj isKindOfClass:[TL_messageEntityMention class]] || [obj isKindOfClass:[TL_messageEntityBotCommand class]] || [obj isKindOfClass:[TL_messageEntityHashtag class]]) {
                
                if([obj isKindOfClass:[TL_messageEntityBotCommand class]] && (self.message.conversation.user.isBot || self.message.conversation.type != DialogTypeChat) )
                    return;
                    
                NSRange range = [self checkAndReturnEntityRange:obj];
                
                NSString *link = [self.message.message substringWithRange:range];
                
                range = [self.textAttributed.string rangeOfString:link];
                
                if(range.location != NSNotFound) {
                    [self.textAttributed addAttribute:NSLinkAttributeName value:link range:range];
                    [self.textAttributed addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                }
                
            }

        }];
        
    } else {
        links = (NSMutableArray *) [self.textAttributed detectAndAddLinks:URLFindTypeLinks | URLFindTypeMentions | URLFindTypeHashtags | (self.message.conversation.user.isBot || self.message.conversation.type == DialogTypeChat ? URLFindTypeBotCommands : 0)];
    }
    
    
    _links = links;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    
    [_links enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [attr appendString:obj];
        
        [attr addAttribute:NSLinkAttributeName value:obj range:range];
        [attr addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
        [attr addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
        [attr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
        
        
        if(idx != _links.count - 1)
            [attr appendString:@"\n"];
        
    }];
    
    [attr addAttribute:NSFontAttributeName value:TGSystemFont(13) range:attr.range];
    
    _allAttributedLinks = [attr copy];
    
    
    
}

-(void)updateEntities {
    [self updateLinkAttributesByMessageEntities];
    [self updateFontAttributesByEntities];
}

-(void)updateFontAttributesByEntities {
    [self.textAttributed removeAttribute:NSFontAttributeName range:self.textAttributed.range];
    
    [self.textAttributed setFont:[NSFont fontWithName:@"HelveticaNeue" size:[SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13] forRange:self.textAttributed.range];
    
    
    [self.message.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TL_messageEntityBold class]]) {
            [self.textAttributed addAttribute:NSFontAttributeName value:TGSystemMediumFont([SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13) range:[self checkAndReturnEntityRange:obj]];
        } else if([obj isKindOfClass:[TL_messageEntityItalic class]]) {
            [self.textAttributed addAttribute:NSFontAttributeName value:TGSystemItalicFont([SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13) range:[self checkAndReturnEntityRange:obj]];
        }
        
    }];
}


-(NSRange)checkAndReturnEntityRange:(TLMessageEntity *)obj {
    
    int location = MIN((int)self.message.message.length, obj.offset);
    
    int length = ((int)self.message.message.length - (location + obj.length)) >= 0 ? obj.length : 0;
    
    return NSMakeRange(location, length);
}

-(void)updateMessageFont {
   
    [self updateFontAttributesByEntities];
    
//    static NSMutableParagraphStyle *paragraph;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        paragraph = [[NSMutableParagraphStyle alloc] init];
//        
//    });
//    
//    [paragraph setLineSpacing:[SettingsArchiver checkMaskedSetting:BigFontSetting] ? 1 : 2];
//    
//    [self.textAttributed addAttribute:NSParagraphStyleAttributeName value:paragraph range:self.textAttributed.range];
    
    if(self.blockWidth != 0)
        [self makeSizeByWidth:self.blockWidth];
}

-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self updateMessageFont];
}

- (BOOL)makeSizeByWidth:(int)width {
    
    width = MAX(100,width);
    
    [super makeSizeByWidth:width];
    
    [_webpage makeSize:width];
    
    width -= self.dateSize.width+10;
    
    if(self.isForwadedMessage) {
        width -= 50;
    }


    _allAttributedLinksSize = [_allAttributedLinks coreTextSizeForTextFieldForWidth:width];
    _textSize = [_textAttributed coreTextSizeForTextFieldForWidth:width];
    
    _textSize.width = width;
    
    self.blockSize = NSMakeSize(width, _textSize.height + ([self isWebPage] ? [_webpage blockHeight] + 5 : 0));
    
    return YES;
}


-(void)updateWebPage {
    
    
    if([self isWebPage]) {
        
        remove_global_dispatcher(_requestKey);
        

        
        
        _webpage = [TGWebpageObject objectForWebpage:self.message.media.webpage]; // its only youtube.
        
        if(self.blockWidth != 0)
            [self makeSizeByWidth:self.blockWidth];
        
        
    } else if([self isWebPagePending]) {
        
        remove_global_dispatcher(_requestKey);
        
        
        _requestKey = dispatch_in_time(self.message.media.webpage.date, ^{
            
            
            [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:[@[@(self.message.n_id)] mutableCopy]] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
                
                if(response.messages.count == 1) {
                    
                    TLMessage *msg = response.messages[0];
                    
                    if(![msg isKindOfClass:[TL_messageEmpty class]]) {
                        self.message.media = msg.media;
                    }
                    
                    [[Storage manager] updateMessages:@[self.message]];
                    
                    [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_MESSAGE_ID_LIST:@[@(self.message.n_id)]}];
                    
                }
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                
            }];
            
            
            
        });
        
    }

}

-(BOOL)isWebPage {
    return [self.message.media.webpage isKindOfClass:[TL_webPage class]];
}

-(BOOL)isWebPagePending {
    return [self.message.media.webpage isKindOfClass:[TL_webPagePending class]];
}


-(BOOL)isset {
    
    if([self isWebPage]) {
        
        TLPhotoSize *s = (TLPhotoSize *)[self.message.media.webpage.photo.sizes lastObject];
        
        return [FileUtils checkNormalizedSize:s.location.path checksize:s.size]  && self.downloadItem == nil && self.messageSender == nil;
    }
    
    return YES;
}




-(void)dealloc {
    [SettingsArchiver removeEventListener:self];
}

@end
