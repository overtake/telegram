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

@property (nonatomic,assign) BOOL isEmojiMessage;


@end

@implementation MessageTableItemText

- (id) initWithObject:(TL_localMessage *)object {
    self = [super initWithObject:object];
    
    self.textAttributed = [[NSMutableAttributedString alloc] init];
    
    NSString *message = [[object.message trim] fixEmoji];
    
//    NSArray *emoji = [message getEmojiFromString:NO];
//    
//    if(emoji.count <= 5) {
//        NSMutableString *c = [message mutableCopy];
//        
//        [emoji enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            
//            [c replaceOccurrencesOfString:obj withString:@"" options:0 range:NSMakeRange(0, c.length)];
//            
//        }];
//        
//        _isEmojiMessage = [c trim].length == 0;
//    }
//    
    
    [self.textAttributed appendString:message withColor:TEXT_COLOR];
    
    [self.textAttributed setAlignment:NSLeftTextAlignment range:self.textAttributed.range];
    
    [self updateEntities];
    
   // [SettingsArchiver addEventListener:self];
    
    
    
    
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
        
        __block NSRange nextRange = NSMakeRange(0, self.textAttributed.string.length);
                
        [self.message.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
            
            if([obj isKindOfClass:[TL_messageEntityUrl class]] ||[obj isKindOfClass:[TL_messageEntityTextUrl class]] || [obj isKindOfClass:[TL_messageEntityMention class]] || [obj isKindOfClass:[TL_messageEntityBotCommand class]] || [obj isKindOfClass:[TL_messageEntityHashtag class]] || [obj isKindOfClass:[TL_messageEntityEmail class]] || [obj isKindOfClass:[TL_messageEntityPre class]] || [obj isKindOfClass:[TL_messageEntityCode class]]) {
                
                if([obj isKindOfClass:[TL_messageEntityBotCommand class]] && (!self.message.conversation.user.isBot && self.message.conversation.type != DialogTypeChat  && (self.message.conversation.type != DialogTypeChannel && !self.message.chat.isMegagroup)) )
                    return;
                
                if([obj isKindOfClass:[TL_messageEntityBotCommand class]] && self.message.conversation.type == DialogTypeChat) {
                    if(self.message.chat.chatFull && self.message.chat.chatFull.bot_info.count == 0)
                        return;
                }
                
                NSRange range = [self checkAndReturnEntityRange:obj];
                
                NSString *link = [self.message.message substringWithRange:range];
                
        
                //range = [self.textAttributed.string rangeOfString:link options:NSCaseInsensitiveSearch range:nextRange];
                
                
                nextRange = NSMakeRange(range.location + range.length, self.textAttributed.length - (range.location + range.length));
                
                if(range.location != NSNotFound) {
                    
                    if([obj isKindOfClass:[TL_messageEntityTextUrl class]]) {
                        link = obj.url;
                    }
                    if([obj isKindOfClass:[TL_messageEntityTextUrl class]] || [obj isKindOfClass:[TL_messageEntityUrl class]])
                        [links addObject:link];
                    
                    
                    if([obj isKindOfClass:[TL_messageEntityCode class]]) {
                        [self.textAttributed addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:range];
                        
                    } else if([obj isKindOfClass:[TL_messageEntityPre class]]) {
                         [self.textAttributed addAttribute:NSForegroundColorAttributeName value:DARK_GREEN range:range];
                    } else {
                        [self.textAttributed addAttribute:NSLinkAttributeName value:link range:range];
                        [self.textAttributed addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                    }
                    
                }
                
            }

        }];
        
    } else {
        links = (NSMutableArray *) [self.textAttributed detectAndAddLinks:URLFindTypeLinks | URLFindTypeMentions | URLFindTypeHashtags | (self.message.conversation.user.isBot || (self.message.conversation.type == DialogTypeChat || (self.message.conversation.type == DialogTypeChannel && self.message.chat.isMegagroup)) ? URLFindTypeBotCommands : 0)];
    }
    
    
    _links = links;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    
    
    [_links enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        if(idx == 0) {
            
            NSString *header = obj;
            
            if(![obj hasPrefix:@"http://"] && ![obj hasPrefix:@"https://"] && ![obj hasPrefix:@"ftp://"])
                header = obj;
            else  {
                NSURLComponents *components = [[NSURLComponents alloc] initWithString:obj];
                header = components.host;
            }
            
            
            
            NSRange r = [attr appendString:[header stringByAppendingString:@"\n\n"] withColor:TEXT_COLOR];
            [attr setCTFont:TGSystemMediumFont(13) forRange:r];
            
            NSRange range = [attr appendString:obj];
            
            [attr addAttribute:NSLinkAttributeName value:obj range:range];
            [attr addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
            [attr addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
            [attr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
            
            
            [attr addAttribute:NSFontAttributeName value:TGSystemFont(12.5) range:range];
            
            if(idx != _links.count - 1)
                [attr appendString:@"\n"];
        } else {
            *stop = YES;
        }
        
        
        
    }];
    
    
    
    _allAttributedLinks = [attr copy];
    
    
    
}

-(void)updateEntities {
    [self updateLinkAttributesByMessageEntities];
    [self updateFontAttributesByEntities];
}

-(void)updateFontAttributesByEntities {
    [self.textAttributed removeAttribute: (NSString *)kCTFontAttributeName range:self.textAttributed.range];
    
    
    [self.textAttributed setCTFont:TGSystemFont([self fontSize]) forRange:self.textAttributed.range];
    
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 0;
    style.alignment = NSLeftTextAlignment;
    
    [self.textAttributed addAttribute:NSParagraphStyleAttributeName value:style range:self.textAttributed.range];
    
    [self.message.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
        
        NSRange range = [self checkAndReturnEntityRange:obj];
        
        if([obj isKindOfClass:[TL_messageEntityBold class]]) {
            
            NSString *link = [self.message.message substringWithRange:range];
            
            range = [self.textAttributed.string rangeOfString:link];
            
            [self.textAttributed addAttribute:NSFontAttributeName value:TGSystemMediumFont([self fontSize]) range:range];
        } else if([obj isKindOfClass:[TL_messageEntityItalic class]]) {
            
            NSString *link = [self.message.message substringWithRange:range];
            
            range = [self.textAttributed.string rangeOfString:link];

            
            [self.textAttributed addAttribute:NSFontAttributeName value:TGSystemItalicFont([self fontSize]) range:range];
        } else if([obj isKindOfClass:[TL_messageEntityCode class]] || [obj isKindOfClass:[TL_messageEntityPre class]]) {
            [self.textAttributed setCTFont:[NSFont fontWithName:@"Courier" size:[self fontSize]] forRange:range];
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

    
    if(self.blockWidth != 0)
        [self makeSizeByWidth:self.blockWidth];
}

-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self updateMessageFont];
}

- (BOOL)makeSizeByWidth:(int)width {
    
    
    [super makeSizeByWidth:width];
    
    [_webpage makeSize:width - 30];
    
    width -= self.dateSize.width+10;
    
    
    if(self.isForwadedMessage) {
        width -= 6;
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
                    
                    
                    [self.message save:NO];
                    
                    if([self.message.media.webpage isKindOfClass:[TL_webPage class]]) {
                        [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(self.message.peer_id):@[@(self.message.n_id)]},KEY_WEBPAGE:self.message.media.webpage}];
                    }
                    
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




-(int)fontSize {
    if(_isEmojiMessage)
        return 36;
    else
        return [super fontSize];
}

-(void)dealloc {
    //[SettingsArchiver removeEventListener:self];
}

@end
