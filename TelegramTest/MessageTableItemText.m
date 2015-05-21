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
    
    [self updateMessageFont];
    
    [SettingsArchiver addEventListener:self];
    
    
    
    [self.textAttributed detectAndAddLinks];
    
    
    
    [self updateWebPage];
    
    
  //  [self makeSizeByWidth:280];
    
    return self;
}



-(void)updateMessageFont {
    [self.textAttributed setFont:[NSFont fontWithName:@"HelveticaNeue" size:[SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13] forRange:self.textAttributed.range];
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


    _textSize = [_textAttributed coreTextSizeForTextFieldForWidth:width];
    
    _textSize.width = width;
    
    self.blockSize = NSMakeSize(width, _textSize.height + ([self isWebPage] ? [_webpage blockHeight] + 5 : 0));
    
    return YES;
}


-(void)updateWebPage {
    
    
    if([self isWebPage]) {
        
        remove_global_dispatcher(_requestKey);
        

        
        
        _webpage = [TGWebpageObject objectForWebpage:self.message.media.webpage]; // its only youtube.
        
        
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
